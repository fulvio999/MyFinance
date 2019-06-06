import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* note: alias name must have first letter in upperCase */
import "../../js/utility.js" as Utility
import "../../js/storage.js" as Storage


/* import folder */
import "../../dialogs"


/*
  After chosing a category in this page is possible:
 -insert a new expense
 - manage sub-category
 - access at the category statistics
*/

Column {

    id: expensesTabletPageLayout
    anchors.fill: parent
    spacing: units.gu(3.5)
    anchors.leftMargin: units.gu(2)

    Rectangle{
        /* to get the background color of the curreunt theme. Necessary if default theme is not used */
        color: theme.palette.normal.background
        width: parent.width
        height: units.gu(6)
    }

    Component {
        id: operationFailureDialogue
        OperationFailInsertExpense{}
    }

    Component {
        id: operationResultDialogue
        OperationSuccessResult{msg:i18n.tr("Amount inserted successfully")}
    }

    Row{
        id: amountRow
        spacing: units.gu(3)

        //------------- Expense Amount --------------
        Label {
            id: amountLabel
            anchors.verticalCenter: amountField.verticalCenter
            text: "* "+i18n.tr("Amount")+":"
        }

        TextField {
            id: amountField
            text: ""
            placeholderText: ""
            echoMode: TextInput.Normal
            width: units.gu(15)
            hasClearButton: false
        }

        Label {
            id: currencyLabel
            anchors.verticalCenter: amountField.verticalCenter
            text: categoryExpensePage.currentCurrency
        }

        Label {
            id: expenseDateLabel
            anchors.verticalCenter: expenseDateButton.verticalCenter
            text: i18n.tr("Date")+":"
        }

        /* Create a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
           with a simple DatePicker Component
        */
        Component {
            id: popoverDatePickerComponent
            Popover {
                id: popoverDatePicker

                DatePicker {
                    id: timePicker
                    mode: "Days|Months|Years"
                    minimum: {
                        var time = new Date()
                        time.setFullYear('2000')
                        return time
                    }
                    /* when Datepicker is closed, is updated the date shown in the button */
                    Component.onDestruction: {
                        /* before inserting the value is added the current year from config param tabel */
                        expenseDateButton.text = Qt.formatDateTime(timePicker.date, "dd MMMM yyyy")
                    }
                }
            }
        }

        /* open the popOver component with DatePicker */
        Button {
            id: expenseDateButton
            width: units.gu(20)
            text: Qt.formatDateTime(new Date(), "dd MMMM yyyy")
            onClicked: {
               PopupUtils.open(popoverDatePickerComponent, expenseDateButton)
            }
        }


        //----------- Sub Category selector PopUp --------------
        ListModel{
            /* filled when the user press the choose button */
            id: modelListSubCategory
        }

       Component {
            id: popoverSubCategoryPickerComponent

            Dialog {
                id: subCategoryPickerDialog
                title: i18n.tr("SubCategory")+": "+modelListSubCategory.count +" "+i18n.tr("found")

                OptionSelector {
                    id: subCategoryOptionSelector
                    expanded: true
                    multiSelection: false
                    model: modelListSubCategory
                    containerHeight: itemHeight * 4
                }

                Row {
                    spacing: units.gu(2)

                    Button {
                        id: selectSubCategoryButton
                        text: i18n.tr("Select")
                        width: units.gu(14)
                        onClicked: {
                            var index = subCategoryOptionSelector.selectedIndex;
                            /* 'sub_cat_name' is column name of the returned dataset from the query */
                            subCatChooserButton.text = modelListSubCategory.get(index).sub_cat_name;

                            PopupUtils.close(subCategoryPickerDialog)
                        }
                    }

                    Button {
                        text: i18n.tr("Close")
                        width: units.gu(14)
                        onClicked: {
                           PopupUtils.close(subCategoryPickerDialog)
                        }
                    }

                    Component.onCompleted: {
                        if(modelListSubCategory.count === 0)
                            selectSubCategoryButton.enabled = false;
                    }
                }
            }
        }


        Label{
            anchors.verticalCenter: subCatChooserButton.verticalCenter
            text: "* "+i18n.tr("Sub Category")+":"
        }


        Button {
            id: subCatChooserButton
            text: i18n.tr("Choose...")
            width: units.gu(20)
            onClicked: {
                /* remove entry about a previously chosen subcategory an insert new ones */
                modelListSubCategory.clear();

                var subCat = Storage.getSubCategoryNameByCategoryId(categoryExpensePage.id);

                for(var i =0;i < subCat.rows.length;i++){
                    modelListSubCategory.append(subCat.rows.item(i));
                }

                PopupUtils.open(popoverSubCategoryPickerComponent, subCatChooserButton)
            }
        }
    }

    Row{
        id: noteRow
        spacing: units.gu(6)

        Label {
            id: noteLabel
            anchors.verticalCenter: noteTextArea.verticalCenter
            text: i18n.tr("Note")+":"
        }

        TextArea {
            id: noteTextArea
            textFormat:TextEdit.AutoText
            text: ""
            height: units.gu(15)
            width: amountRow.width - units.gu(10)
            readOnly: false
        }
    }

    /* Ask for confirmation about new Expense insertion */
    Component {
        id: confirmInsertDialog

        Dialog {
            id: dialogue
            title: i18n.tr("Confirmation")
            modal:true
            text:""  /* parameter passed by the caller button */
            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }

            Button {
                text: i18n.tr("Execute")
                onClicked: {
                        PopupUtils.close(dialogue)

                        var idSubCategory = Storage.getSubCategoryIdByName(subCatChooserButton.text);

                        Storage.insertExpense(categoryExpensePage.id, //idCategory
                                              idSubCategory,
                                              amountField.text,
                                              expenseDateButton.text,
                                              noteTextArea.text
                                              );

                        /* update the current report tables */
                        Storage.updateCategoryReportCurrentAmount(categoryExpensePage.id, amountField.text);
                        Storage.updateSubCategoryReportCurrentAmount(idSubCategory, amountField.text);

                        /* update category list shown with the new amount */
                        Storage.getAllCategory();

                        PopupUtils.open(operationResultDialogue)

                        /* clean form */
                        subCatChooserButton.text = i18n.tr("Choose...");
                        amountField.text="";
                        noteTextArea.text="";
                        expenseDateButton.text = Qt.formatDateTime(new Date(), "dd MMMM yyyy");
                }
            }
        }
    }

    Row{
        spacing: units.gu(2)

        /* placeholder: required to place the content under the header */
        Rectangle {
            /* to get the background color of the curreunt theme. Necessary if default theme is not used */
            color: theme.palette.normal.background
            width: units.gu(8)
            height: units.gu(1)
        }

        Button {
            id: insertButton
            objectName: "Insert"
            text: i18n.tr("Insert")
            iconName: "save"
            width: units.gu(14)
            onClicked: {
                var amountIsValid = Utility.checkinputText(amountField.text);

                if(amountIsValid && subCatChooserButton.text !== i18n.tr("Choose...") )
                   /* open a parameterized poup, with the title in argument  */
                   PopupUtils.open(confirmInsertDialog,insertButton,{text: i18n.tr("Confirm the insertion")+" ?"})
                else
                   PopupUtils.open(operationFailureDialogue)
            }
        }

        Label {
            id: fieldRequiredLabel
            anchors.verticalCenter: insertButton.verticalCenter
            text: "* "+i18n.tr("Field required")
        }
    }


    /* line separator */
    Rectangle {
          color: "grey"
          width: units.gu(100)
          anchors.horizontalCenter: parent.horizontalCenter
          height: units.gu(0.1)
    }


    Row{
        spacing: units.gu(2)

        /* placeholder: required to place the content under the header */
        Rectangle {
            /* to get the background color of the curreunt theme. Necessary if default theme is not used */
            color: theme.palette.normal.background
            width: expensesTabletPageLayout.width/4
            height: units.gu(1)
        }

        Button {
            id: editCategoryButton
            text: i18n.tr("Edit category...")
            width: units.gu(20)
            iconName: "edit"
            onTriggered: adaptivePageLayout.addPageToNextColumn(categoryExpensePage, Qt.resolvedUrl("../CategoryEditPage.qml"),
                                                                {
                                                                    /* <page-variable-name>:<property-value-to-pass> */
                                                                    categoryName:categoryExpensePage.categoryName,
                                                                    categoryId:categoryExpensePage.id
                                                                }
                                                                )
        }

        Button {
            id: findExpenseButton
            text: i18n.tr("Find Expense...")
            width: units.gu(20)
            iconName: "find"
            onClicked: adaptivePageLayout.addPageToNextColumn(categoryExpensePage, Qt.resolvedUrl("../FindExpensePage.qml"),
                                                                {
                                                                    /* <page-variable-name>:<property-value-to-pass> */
                                                                    categoryName:categoryExpensePage.categoryName,
                                                                    categoryId:categoryExpensePage.id
                                                                }
                                                                )
        }


        /* Show the statistics page for the category expense */
        Button {
            id: statisticsButton
            text: i18n.tr("Statistics")
            width: units.gu(12)
            color: UbuntuColors.orange
            onClicked: adaptivePageLayout.addPageToNextColumn(categoryExpensePage, Qt.resolvedUrl("../StatisticsPage.qml"),
                                                                {
                                                                    /* <variable-name>:<property-value> */
                                                                    categoryName:categoryExpensePage.categoryName,
                                                                    categoryId:categoryExpensePage.id
                                                                }
                                                                )

        }

    }

}

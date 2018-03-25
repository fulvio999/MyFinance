import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* note: alias name must have first letter in upperCase */
import "utility.js" as Utility
import "storage.js" as Storage

/*
  Allow to edit an already saved expense. The user can modify the amount, note and subcategory of the expense
*/
Column {

    id: editExpensesTabletPageLayout
    anchors.fill: parent
    spacing: units.gu(3.5)
    anchors.leftMargin: units.gu(2)

    Rectangle{
        color: "transparent"
        width: parent.width
        height: units.gu(6)
    }

    Component {
        id: operationFailureDialogue
        OperationFailInsertExpense{}
    }

    Component {
        id: operationResultDialogue
        OperationSuccessResult{}
    }   

    Row{
        id: amountRow
        spacing: units.gu(6)

        //------------- Expense Amount --------------
        Label {
            id: amountLabel
            anchors.verticalCenter: amountField.verticalCenter
            text: i18n.tr("Amount:")
        }

        TextField {
            id: amountField
            /* pre-filled with the values of the selected expense */
            text: editExpensePage.currentAmount
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
    }

    Row{
        spacing: units.gu(8.5)

        Label {
            id: expenseDateLabel
            anchors.verticalCenter: expenseDateButton.verticalCenter
            text: i18n.tr("Date:")
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
            text: Qt.formatDateTime(editExpensePage.currentDate, "dd MMMM yyyy")
            onClicked: {
               PopupUtils.open(popoverDatePickerComponent, expenseDateButton)
            }
        }
     }

    Row{
       spacing: units.gu(2)

       ListModel{
           /* filled when the user press the choose button */
           id: modelListSubCategory
       }

       Component {
            id: popoverSubCategoryPickerComponent

            Dialog {
                id: subCategoryPickerDialog
                title: i18n.tr("SubCategory: ")+modelListSubCategory.count +i18n.tr(" found")

                OptionSelector {
                    id: subCategoryOptionSelector
                    expanded: true
                    multiSelection: false
                    model: modelListSubCategory
                    containerHeight: itemHeight * 4
                }

                Row {
                    spacing: units.gu(1)

                    Button {
                        text: i18n.tr("Select")
                        width: units.gu(14)
                        onClicked: {
                            var index = subCategoryOptionSelector.selectedIndex;
                            /* 'sub_cat_name' is column name of the returned dataset from the query */
                            subCategoryChooserButton.text = modelListSubCategory.get(index).sub_cat_name;

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
                }
            }
        }

        //-------------------------------------
        Label{
            anchors.verticalCenter: subCategoryChooserButton.verticalCenter
            text: i18n.tr("SubCategory:")
        }

        Button {
            id: subCategoryChooserButton
            /* pref-fill with the chose subCategory of the expense to edit */
            text: editExpensePage.currentSubCategory
            width: units.gu(20)
            onClicked: {
                /* remove entry about a previously chosen subcategory an insert new ones */
                modelListSubCategory.clear();

                var subCat = Storage.getSubCategoryNameByCategoryId(categoryExpensePage.id);

                for(var i =0;i < subCat.rows.length;i++){
                    modelListSubCategory.append(subCat.rows.item(i));
                }

                PopupUtils.open(popoverSubCategoryPickerComponent, subCategoryChooserButton)
            }
        }
    }

    Row{
        id: noteRow
        spacing: units.gu(8)

        Label {
            id: noteLabel
            anchors.verticalCenter: noteTextArea.verticalCenter
            text: i18n.tr("Note:")
        }

        TextArea {
            id: noteTextArea
            textFormat:TextEdit.AutoText
            /* fill with the notes of the selected category */
            text: editExpensePage.currentNote
            height: units.gu(15)
            width: amountRow.width - units.gu(5)
            readOnly: false
        }
    }

    /* Ask for confirmation about new Expense insertion */
    Component {
        id: confirmUpdateDialog

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

                    var inputValid = Utility.checkinputText(amountField.text);

                    if(inputValid && subCategoryChooserButton.text !== "Choose...")
                    {
                        var idSubCategory = Storage.getSubCategoryIdByName(subCategoryChooserButton.text);

                        /* get the old amount, necessary to update teh reports */
                        var oldAmount = Storage.getExpenseAmount(editExpensePage.expenseId);

                        Storage.updateExpense(editExpensePage.expenseId, //id of the Expense
                                              idSubCategory,
                                              amountField.text,
                                              expenseDateButton.text,
                                              noteTextArea.text
                                              );


                        /* if diffAmount is < 0 means that the user has decreased the amount,
                           if > 0  the user has increased the amount
                        */
                        var diffAmount = amountField.text - oldAmount;

                        //console.log('Old amount is: '+oldAmount+' new Amount is:'+amountField.text+' the DIFF Amount is:'+diffAmount +' for subCategory: '+idSubCategory);

                        /* only if the user has changed amount, update current report tables: increase or decrease, depending on the 'diffAmount' value */
                        if(diffAmount != 0){

                            Storage.updateCategoryReportCurrentAmount(categoryExpensePage.id, diffAmount);
                            Storage.updateSubCategoryReportCurrentAmount(idSubCategory, diffAmount);
                        }

                        /* refresh category list and their amount */
                        Storage.getAllCategory();

                        PopupUtils.open(operationResultDialogue)

                    }else{
                         PopupUtils.open(operationFailureDialogue)
                    }
                }
            }
        }
    }

    Row{
        spacing: units.gu(2)

        /* transparent placeholder: required to place the content under the header */
        Rectangle {
            color: "transparent"
            width: units.gu(10)
            height: units.gu(1)
        }

        Button {
            id: insertButton
            objectName: "Update"
            text: i18n.tr("Update")
            iconName: "save"
            width: units.gu(20)
            onClicked: {
                PopupUtils.open(confirmUpdateDialog,insertButton,{text: i18n.tr("Confirm the modifications ?")})
            }
        }
    }


}




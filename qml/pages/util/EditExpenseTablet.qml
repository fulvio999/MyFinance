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

import "../../dialogs"

/*
  Allow to edit an already saved expense. The user can modify the amount, note and subcategory of the expense
*/
Column {

    id: editExpensesTabletPageLayout
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
        OperationSuccessResult{msg:i18n.tr("Operation executed successfully")}
    }

    Row{
        id: amountRow
        spacing: units.gu(4)

        //------------- Expense Amount --------------
        Label {
            id: amountLabel
            anchors.verticalCenter: amountField.verticalCenter
            text: i18n.tr("Amount")+":"
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
            width: units.gu(17)
            text: Qt.formatDateTime(editExpensePage.currentDate, "dd MMMM yyyy")
            onClicked: {
               PopupUtils.open(popoverDatePickerComponent, expenseDateButton)
            }
        }

       ListModel{
           /* filled when the user press the choose button */
           id: modelListSubCategory
       }

        //-------------------------------------
        Label{
            anchors.verticalCenter: subCategoryChooserButton.verticalCenter
            text: i18n.tr("Sub Category")+":"
        }

        Label{
            anchors.verticalCenter: subCategoryChooserButton.verticalCenter
            text: editExpensePage.currentSubCategory
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
            /* fill with the notes of the selected category */
            text: editExpensePage.currentNote
            height: units.gu(15)
            width: amountRow.width - units.gu(10)
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

                  if(inputValid)
                  {
                      var currentSubCategoryId = Storage.getSubCategoryIdByName(editExpensePage.currentSubCategory);

                      /* get the old amount, necessary to update the current report table */
                      var oldAmount = Storage.getExpenseAmount(editExpensePage.expenseId);
                      var diffAmount = amountField.text - oldAmount;

                      Storage.updateSubCategoryReportCurrentAmount(currentSubCategoryId, diffAmount);
                      Storage.updateCategoryReportCurrentAmount(editExpensePage.categoryId, diffAmount);
                      Storage.updateExpense(editExpensePage.expenseId,
                                                currentSubCategoryId,
                                                amountField.text,
                                                expenseDateButton.text,
                                                noteTextArea.text
                                                );

                      PopupUtils.open(operationResultDialogue)

                      /* refresh category list and their amount */
                      Storage.getAllCategory();

                  }else{
                       PopupUtils.open(operationFailureDialogue)
                  }

                }  //clicked
            }
        }
    }

    Row{
        spacing: units.gu(2)

        /* transparent placeholder: required to place the content under the header */
        Rectangle {
            /* get default backbround. to support dark theme */
            color: theme.palette.normal.background
            width: units.gu(8)
            height: units.gu(1)
        }

        Button {
            id: insertButton
            objectName: "Update"
            text: i18n.tr("Update")
            iconName: "save"
            width: units.gu(12)
            onClicked: {
                PopupUtils.open(confirmUpdateDialog,insertButton,{text: i18n.tr("Confirm the modifications")+" ?"})
            }
        }
    }


}

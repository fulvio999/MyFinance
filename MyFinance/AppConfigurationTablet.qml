import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "storage.js" as Storage

//--------------- For TABLET Page with application settings and maintenance utility ---------------


Column{
    id: appConfigurationTablet

    anchors.fill: parent
    spacing: units.gu(3.5)
    anchors.leftMargin: units.gu(2)

    /* warning popup to notify at the user that default data was already imported */
    Component{
        id: importAlreadyDoneComponent
        ImportDataAlreadyDone{}
    }

    Component{
        id: operationSuccessRestartDialog
        OperationSuccessResultRestart{}
    }

    Component{
        id: operationSuccessDialog
        OperationSuccessResult{}
    }

    Component{
        id: invalidInputDialog
        InvalidInputPopUp{}
    }

     /* Dialog to Ask a confirmation for a delete operation for OLD expense */
    Component{

        id: confirmDeleteDialogueComponent
        Dialog {
            id: confirmDeleteDialogue
            title: "Confirmation"
            modal:true
            text:"Remove Expenses in the range (no restore) ?"

            Label{
                id: deleteSuccessLabel
                text: ""
                color: UbuntuColors.green
            }

            Button {
               text: i18n.tr("Cancel")              
               onClicked: PopupUtils.close(confirmDeleteDialogue)
            }

            Button {
                id: executeDeleteButton
                text: i18n.tr("Execute")
                onClicked: {

                    var idCategory = Storage.getCategoryIdByName(categoryChooserButton.text);
                    /* remove the expense in the range and update the data used to generate the reports */
                    var deletedExpense = Storage.deleteExpenseByCategoryAndTime(dateFromButton.text,dateToButton.text,idCategory);

                    deleteSuccessLabel.text = i18n.tr("Done, deleted")+": "+deletedExpense+" expense(s)"
                    executeDeleteButton.enabled = false;
                    /* refresh */
                    Storage.getAllCategory();
                }
            }
        }
    }

    /* transparent placeholder: required to place the content under the header */
    Rectangle {
        color: "transparent"
        width: parent.width
        height: units.gu(6)
    }

    Row{
         id: headerCurrencyRow

         Label{
             text: "<b>GENERAL SETTINGS (** Restart required after update ** )</b>"
         }
    }

    Row{
        id: currencyRow
        spacing: units.gu(5)

        Label {
            id: currencyLabel
            anchors.verticalCenter: currencyField.verticalCenter
            text: "* "+i18n.tr("Currency (ISO format):")
        }

        TextField {
            id: currencyField
            text: configurationPage.currentCurrency
            placeholderText: ""
            echoMode: TextInput.Normal
            readOnly: false
            maximumLength: 3  /* currency ISO code have only three letters */
            width: units.gu(15)
        }

        Button{
            id: updateGeneralSettingsButton           
            width: units.gu(14)
            text: i18n.tr("Update")           
            onClicked: {
                if(currencyField.text.length > 0 )
                {
                  Storage.updateConfigParam('currency',currencyField.text);
                  PopupUtils.open(operationSuccessRestartDialog);

                } else {
                   PopupUtils.open(invalidInputDialog);
                }
            }
        }

        Label {
            id: fieldRequiredLabel
            anchors.verticalCenter: updateGeneralSettingsButton.verticalCenter
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
         id: headerDefaultConfigurationRow
         spacing: units.gu(7)

         Label{
             id: defaultDataImportLabel
             text: "<b>DATA:</b> Load default category and SubCategory"
         }

         Button {
            id: loadDefaultDataButton
            width: units.gu(14)
            text: i18n.tr("Load Data")
            onClicked: {
                var result = Storage.insertDefaultData();

                if(!result){                    
                    PopupUtils.open(importAlreadyDoneComponent);
                }else{
                    settings.defaultDataAlreadyImported = true;                   
                    PopupUtils.open(operationSuccessRestartDialog);
                    Storage.getAllCategory(); //refresh
                }
            }
        }

        Label{
            id: importDefaultDataLabel
            text: ""
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
        id: maintenanceRow
        spacing: units.gu(5)

        Label{
            text: "<b>MAINTENANCE:</b> Remove expences for a category (and his subCategory). There is NO restore !"
        }
    }

    Row{
        id: dateRow       
        spacing: units.gu(2)

        //------------------ Date from ------------------
        Label {
            id: fromDateLabel
            anchors.verticalCenter: dateFromButton.verticalCenter
            text: i18n.tr("From:")
        }

        /* Create a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
           with a simple DatePicker Component
        */
        Component {
            id: popoverDateFromPickerComponent
            Popover {
                id: popoverDateFromPicker

                DatePicker {
                    id: fromTimePicker
                    mode: "Days|Months|Years"
                    minimum: {
                        var time = new Date()
                        time.setFullYear('2000')
                        return time
                    }
                    /* when Datepicker is closed, is updated the date shown in the button */
                    Component.onDestruction: {
                        dateFromButton.text = Qt.formatDateTime(fromTimePicker.date, "dd MMMM yyyy")
                    }
                }
            }
        }

        /* open the popover component with DatePicker */
        Button {
            id: dateFromButton
            text: Qt.formatDateTime(new Date(), "dd MMMM yyyy")
            width: units.gu(20)
            onClicked: {
               PopupUtils.open(popoverDateFromPickerComponent, dateFromButton)
            }
        }

        //------------------ Date to ------------------
        Label {
            id: toDateLabel
            anchors.verticalCenter: dateToButton.verticalCenter
            text: i18n.tr("To:")
        }

        /* Create a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
           with a simple DatePicker Component
        */
        Component {
            id: popoverDateToPickerComponent
            Popover {
                id: popoverDateToPicker

                DatePicker {
                    id: toTimePicker
                    mode: "Days|Months|Years"

                    /* when Datepicker is closed, is updated the date shown in the button */
                    Component.onDestruction: {
                        dateToButton.text = Qt.formatDateTime(toTimePicker.date, "dd MMMM yyyy")
                    }
                }
            }
        }

        /* open the popOver component with DatePicker */
        Button {
            id: dateToButton
            text: Qt.formatDateTime(new Date(), "dd MMMM yyyy")
            width: units.gu(20)
            onClicked: {
               PopupUtils.open(popoverDateToPickerComponent, dateToButton)
            }
        }

        //----------- category selector --------------
        Label{
            anchors.verticalCenter: categoryChooserButton.verticalCenter
            text: "* "+i18n.tr("Category:")
        }

        Button {
            id: categoryChooserButton
            text: i18n.tr("Choose...")
            width: units.gu(20)
            onClicked: {

                /* remove entry about a previously chosen subcategory and insert new ones */
                reportCategoryListModel.clear();

                var subCat = Storage.getAllCategoryNames();
                for(var i =0;i < subCat.rows.length;i++){
                    reportCategoryListModel.append(subCat.rows.item(i));
                }

                PopupUtils.open(popoverSubCategoryPickerComponent, categoryChooserButton)
            }
        }

        Button {
            id: confirmDeleteButton         
            text:  i18n.tr("Delete")
            iconName: "delete"
            width: units.gu(14)
            onClicked: {

               if(categoryChooserButton.text !== "Choose..."){
                  PopupUtils.open(confirmDeleteDialogueComponent, confirmDeleteButton)
               }else{
                   PopupUtils.open(invalidInputDialog)
               }
            }
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
        /* Show the help page */
        Button {
            id: statisticsButton
            text:  i18n.tr("Help")
            width: units.gu(14)
            color: UbuntuColors.orange
            onTriggered: adaptivePageLayout.addPageToNextColumn(categoryListPage, helpPage)
        }
    }

    //----------- Category selector PopUp --------------
    ListModel{
        /* filled when the user press the choose category button */
        id: reportCategoryListModel
    }

    Component {
         id: popoverSubCategoryPickerComponent
         Dialog {
             id: categoryPickerDialog

             OptionSelector {
                 id: categoryOptionSelector
                 expanded: true
                 multiSelection: false
                 model:  reportCategoryListModel
                 containerHeight: itemHeight * 4
             }

             Button {
                 text: i18n.tr("Confirm")
                 onClicked: {
                     var index = categoryOptionSelector.selectedIndex;
                     /* 'cat_name' is column name of the returned data-set from the query  */
                     categoryChooserButton.text = reportCategoryListModel.get(index).cat_name;
                     PopupUtils.close(categoryPickerDialog)
                 }
             }

             Button {
                 text: i18n.tr("Close")
                 onClicked: {
                     PopupUtils.close(categoryPickerDialog)
                 }
             }
         }
     }

}



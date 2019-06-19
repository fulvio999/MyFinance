import QtQuick 2.4

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* Thanks to: https://github.com/jwintz/qchart.js for QML bindings for Charts.js, */
import "."
import "./js/QChart.js" as Charts
import "./js/QChartGallery.js" as ChartsData

import "./js/storage.js" as Storage
import "./js/utility.js" as Utility

/*
  Content of the Dialog shown when the user want an expense report with a custom time range
*/
Row{
    id: criteriaRow
    spacing: units.gu(3)

    /* ----------  Date From ------ */
    Label {
        id: expenseDateFromLabel
        anchors.verticalCenter: expenseDateFromButton.verticalCenter
        text: i18n.tr("Date from")+":"
    }

    /* Create a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
       with a simple DatePicker Component
    */
    Component {
        id: popoverDateFromPickerComponent
        Popover {
            id: popoverDateFromPicker

            DatePicker {
                id: timeFromPicker
                mode: "Days|Months"
                minimum: {
                    var time = new Date()
                    time.setFullYear(time.getFullYear())
                    return time
                }
                /* when Datepicker is closed, is updated the date shown in the button */
                Component.onDestruction: {
                    expenseDateFromButton.text = Qt.formatDateTime(timeFromPicker.date, "dd MMMM")
                }
            }
        }
    }

    /* open the popOver component with a DatePicker */
    Button {
        id: expenseDateFromButton
        text: Qt.formatDateTime(new Date(), "dd MMMM")
        onClicked: {
           PopupUtils.open(popoverDateFromPickerComponent, expenseDateFromButton)
        }
    }

    /* ----------  Date To ------ */
    Label {
        id: expenseDateToLabel
        anchors.verticalCenter: expenseDateToButton.verticalCenter
        text: i18n.tr("Date To")+":"
    }

    /* Create a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
       with a simple DatePicker Component
    */
    Component {
        id: popoverDateToPickerComponent
        Popover {
            id: popoverDateToPicker

            DatePicker {
                id: timeToPicker
                mode: "Days|Months"
                minimum: {
                    var time = new Date()
                    time.setFullYear(time.getFullYear())
                    return time
                }
                /* when Datepicker is closed, is updated the date shown in the button */
                Component.onDestruction: {
                    expenseDateToButton.text = Qt.formatDateTime(timeToPicker.date, "dd MMMM")
                }
            }
        }
    }

    /* open the popOver component with a DatePicker */
    Button {
        id: expenseDateToButton
        text: Qt.formatDateTime(new Date(), "dd MMMM")
        onClicked: {
           PopupUtils.open(popoverDateToPickerComponent, expenseDateToButton)
        }
    }

    //----------- Category selector PopUp --------------
    ListModel{
        /* filled when the user press the choose category button */
        id: reportCategoryListModel
    }

    Component {
        id: popoverCategoryPickerComponent
        Dialog {
            id: categoryPickerDialog

            OptionSelector {
                id: categoryOptionSelector
                expanded: true
                multiSelection: false
                model:reportCategoryListModel
                containerHeight: itemHeight * 4
            }


            /* when Picker is closed, is updated the date shown in the button */
            Component.onDestruction: {
                var index = categoryOptionSelector.selectedIndex;
                /* 'cat_name' is column name of the returned dataset for the query  */
                categoryChooserButton.text = reportCategoryListModel.get(index).cat_name;
            }

            Button {
                id: subCategoryChooserButton
                text: i18n.tr("Confirm")
                onClicked: {
                    onClicked: PopupUtils.close(categoryPickerDialog)
                }
            }
        }
    }


    //----------- Report Type selector PopUp --------------
    Component {
        id: popoverReportPickerComponent
        Dialog {
            id: reportPickerDialog

            OptionSelector {
                id: reportOptionSelector
                expanded: true
                multiSelection: false
                model: [i18n.tr("Monthly"),
                        i18n.tr("weekly")]
                containerHeight: itemHeight * 4
            }


            /* when Report Type Picker is closed, is updated the date shown in the button */
            Component.onDestruction: {
                var index = reportOptionSelector.selectedIndex;
                var model = reportOptionSelector.model;
                reportTypeChooserButton.text = model[index]
            }

            Button {
                text: i18n.tr("Confirm")
                onClicked: PopupUtils.close(reportPickerDialog)
            }
        }
    }
    //-------------------------------------


    Button {
        id: categoryChooserButton
        text: i18n.tr("Choose a Category...")
        width: units.gu(20)
        onClicked: {

            /* remove entry about a previously chosen subcategory an insert new ones */
            reportCategoryListModel.clear();

            var subCat = Storage.getAllCategoryNames();
            for(var i =0;i < subCat.rows.length;i++){
                reportCategoryListModel.append(subCat.rows.item(i));
            }
            /* at runtime appned a new entry not present in the database */
            reportCategoryListModel.insert(0,{"cat_name": i18n.tr("ALL Category")});

            PopupUtils.open(popoverCategoryPickerComponent, categoryChooserButton)
        }
    }


    Button {
        id: reportTypeChooserButton
        text: i18n.tr("Report Type...")
        width: units.gu(20)
        onClicked: {
           PopupUtils.open(popoverReportPickerComponent, reportTypeChooserButton)
        }
    }

    Button {
        id: generateReportButton
        text: i18n.tr("Generate")
        color: UbuntuColors.orange
        onClicked: {
//                loadingPageActivity.running = true
//
//                loadingPageActivity.running = false
        }

     }



}

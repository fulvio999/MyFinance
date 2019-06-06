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
import "../../js/categoryUtils.js" as CategoryUtils
import "../../js/storage.js" as Storage

/* import folder */
import "../../dialogs"

Column{
     id: searchExpenseColum
     anchors.fill: parent
     spacing: units.gu(3.5)


//    Component.onCompleted: {
//         searchExpenseButton.clicked.connect(send)
//    }

    /* placeholder: required to place the content under the header */
    Rectangle {
        /* to get the background color of the curreunt theme. Necessary if default theme is not used */
        color: theme.palette.normal.background
        width: parent.width
        height: units.gu(5)
    }

    /* label to show search result */
    Row{
        id: expenseFoundTitle
        x: searchExpenseColum.width/3
        Label{
            id: expenseFoundLabel
            text:" " /* empty spaces as placeholder */
        }
    }

    Row{
        id: searchCriteriaRow
        spacing: units.gu(2)
        x: units.gu(3)
        Label {
            id: expenseDateFromLabel
            anchors.verticalCenter: expenseDateFromButton.verticalCenter
            text: i18n.tr("Date from")+":"
        }

        /*
           a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
           with a simple DatePicker Component
       */
       Component {
            id: popoverDateFromPickerComponent
            Popover {
                id: popoverDateFromPicker

                DatePicker {
                    id: timeFromPicker
                    mode: "Days|Months|Years"
                    minimum: {
                        var time = new Date()
                        time.setFullYear('2000')
                        return time
                    }
                    /* when Datepicker is closed, is updated the date shown in the button */
                    Component.onDestruction: {
                        expenseDateFromButton.text = Qt.formatDateTime(timeFromPicker.date, "dd MMMM yyyy")
                    }
                }
            }
        }

        /* open the popOver component with a DatePicker */
        Button {
            id: expenseDateFromButton
            width: units.gu(18)
            text: Qt.formatDateTime(new Date(), "dd MMMM yyyy")
            onClicked: {
                PopupUtils.open(popoverDateFromPickerComponent, expenseDateFromButton)
            }
        }

        Label {
            id: expenseDateToLabel
            anchors.verticalCenter: expenseDateToButton.verticalCenter
            text: i18n.tr("Date To")+":"
        }

        /* a PopOver containing a DatePicker, necessary use a PopOver a container due to a bug on setting minimum date
           with a simple DatePicker Component
        */
        Component {
            id: popoverDateToPickerComponent
            Popover {
                id: popoverDateToPicker

                DatePicker {
                    id: timeToPicker
                    mode: "Days|Months|Years"
                    minimum: {
                        var time = new Date()
                        time.setFullYear(time.getFullYear())
                        return time
                    }
                    /* when Datepicker is closed, is updated the date shown in the button */
                    Component.onDestruction: {
                        expenseDateToButton.text = Qt.formatDateTime(timeToPicker.date, "dd MMMM yyyy")
                    }
                }
            }
        }

        /* open the popOver component with a DatePicker */
        Button {
            id: expenseDateToButton
            width: units.gu(18)
            text: Qt.formatDateTime(new Date(), "dd MMMM yyyy")
            onClicked: {
                PopupUtils.open(popoverDateToPickerComponent, expenseDateToButton)
            }
        }

        /* -------- model for subcategory chooser --------- */
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
                 }
             }
         }


         Label{
             anchors.verticalCenter: subCatChooserButton.verticalCenter
             text: i18n.tr("Filter")+":"
         }


         Button {
             id: subCatChooserButton
             text: i18n.tr("All SubCategory")

             width: units.gu(20)
             onClicked: {
                 /* remove entry about a previously chosen subcategory an insert new ones */
                 modelListSubCategory.clear();

                 var subCat = Storage.getSubCategoryNameByCategoryId(findExpensePage.categoryId);

                 for(var i =0;i < subCat.rows.length;i++){
                     modelListSubCategory.append(subCat.rows.item(i));
                 }
                 /* fake subCategory */
                 modelListSubCategory.insert(0,{"sub_cat_name":"All SubCategory"})

                 PopupUtils.open(popoverSubCategoryPickerComponent, subCatChooserButton)
             }
         }

         Button {
            id: searchExpenseButton
            text: i18n.tr("Search/Reload")
            color: UbuntuColors.orange
            onClicked: {

                //console.log("Searching expense with SubCategory Filter: "+ subCatChooserButton.text);

                if(subCatChooserButton.text != i18n.tr("All SubCategory"))
                    Storage.searchExpense(expenseDateFromButton.text,expenseDateToButton.text,findExpensePage.categoryId, subCatChooserButton.text );
                else
                    Storage.searchExpense(expenseDateFromButton.text,expenseDateToButton.text,findExpensePage.categoryId, -1 );

                expenseFoundLabel.text = "<b>Found: </b>"+ expenseModel.count +"<b> expense in the date range</b>"
            }
        }
      }

      //-- Thanks to: gajdos.sk/ubuntuapps/dynamically-filled-listview-in-qml/ for the idea
      Row{
          id: expenseFoundRow
          anchors.topMargin: searchCriteriaRow.height
          height: parent.height - searchCriteriaRow.height
      }
}

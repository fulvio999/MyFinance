import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../js/utility.js" as Utility
import "../js/categoryUtils.js" as CategoryUtils
import "../js/storage.js" as Storage
import "../js/subCategoryReportChart.js" as SubCategoryReportChart

/* import folder */
import "../dialogs"
import "./util"


/*
  Find Expenses Page for a given category
*/
Page{
        id:findExpensePage

        /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
           Are the details vaules of the selected person in the people list used to fill the TextField
           See Delegate Object of the ListView
        */
        property string categoryName;
        property int categoryId;
        property string currency: Storage.getConfigParamValue('currency');

        header: PageHeader {
           title: i18n.tr("Find Expense for category") +": "+ "<b>"+findExpensePage.categoryName +"</b>"
        }

        ListModel {
            id: expenseModel
        }

        onCategoryIdChanged: {
            /* clean previous result search for a different category */
            expenseModel.clear();
        }

        UbuntuListView {
            id: expenseSearchResultList
            /* necessary, otherwise hide the search criteria row */
            anchors.topMargin: units.gu(33) //units.gu(searchReloadRow.height + expenseFoundTitle.height + searchCriteriaRow.height + dateFilterRow.height + categoryFilterRow.height)
            anchors.fill: parent
            focus: true
            /* nececessary otherwise the list scroll under the  */
            clip: true
            model: expenseModel
            boundsBehavior: Flickable.StopAtBounds
            highlight:
                Component {
                    id: highlightComponent

                    Rectangle {
                        width: 180; height: 44
                        color: "blue";

                        radius: 2
                        /* move the Rectangle on the currently selected List item with the keyboard */
                        y: expenseSearchResultList.currentItem.y

                        /* show an animation on change ListItem selection */
                        Behavior on y {
                            SpringAnimation {
                                spring: 5
                                damping: 0.1
                            }
                        }
                    }
                }

            delegate: ExpenseFoundDelegate{}
        }

        /* Show the details of the selected person */
        Layouts {
            id: layoutsFindExpense
            width: parent.width
            height: parent.height
            layouts:[

                ConditionalLayout {
                    name: "findExpenseLayout"
                    when: root.width > units.gu(120)

                       FindExpenseTablet{}
                 }
            ]
            //else
            FindExpensePhone{}
        }

    Scrollbar {
        flickableItem: expenseSearchResultList
        align: Qt.AlignTrailing
    }
}

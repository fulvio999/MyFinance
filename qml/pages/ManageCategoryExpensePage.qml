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
   Main page to manage expenses for a selected CATEGORY
*/
Page{
    id:manageCategoryExpensePage

    anchors.fill: parent

    /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
       Are the details vaules of the selected person in the people list used to fill the TextField
       See Delegate Object of the ListView
    */
    property string id  /* id of the category (not shown) */
    property string categoryName
    property string currentCurrency : Storage.getConfigParamValue('currency');
    property string currentExpenseAmount  /* current expense amout for a category */

    header: PageHeader {
        id: headerDetailsPage
        title: i18n.tr("Manage expenses for")+": " + "<b>" +manageCategoryExpensePage.categoryName +"</b>"
    }

    /* to have a scrollable column when the keyboard cover some input field */
    Flickable {
        id: expesneDetailsFlickable
        clip: true
        contentHeight: Utility.getContentHeight()
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: manageCategoryExpensePage.bottom
            bottomMargin: units.gu(2)
        }

        /* Show the details of the selected person */
        Layouts {
            id: layoutsDetailsContact
            width: parent.width
            height: parent.height
            layouts:[

                ConditionalLayout {
                    name: "detailsContactLayout"
                    when: root.width > units.gu(120)
                         ExpensesTablet{ }
                }
            ]
            //else
            ExpensesPhone{}
        }
    }

    /* To show a scrollbar on the side */
    Scrollbar {
        flickableItem: expesneDetailsFlickable
        align: Qt.AlignTrailing
    }

}

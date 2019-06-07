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


//------------- ADD NEW CATEGORY and SUBCATEGORY PAGE ---------------
Page {
    id: addCategoryPage

    header: PageHeader {
        title: i18n.tr("Add new Category and subcategory")
    }

    Flickable {
        id: newCategoryPageFlickable
        clip: true
        contentHeight: Utility.getContentHeight() - units.gu(20)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: addCategoryPage.bottom
            bottomMargin: units.gu(2)
        }

        /* Show a form to add a new contact */
        Layouts {
            id: layouts
            width: parent.width
            height: parent.height
            layouts:[

                ConditionalLayout {
                    name: "addContactLayout"
                    when: root.width > units.gu(120) // && Screen.orientation === Qt.LandscapeOrientation
                    AddCategoryTablet{}
                }
            ]
            //else
            AddCategoryPhone{}
        }
    }

    /* To show a scrolbar on the side */
    Scrollbar {
        flickableItem: newCategoryPageFlickable
        align: Qt.AlignTrailing
    }
}

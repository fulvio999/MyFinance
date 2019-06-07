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

//---------------- Edit Category Page--------------
Page{
    id:categoryEditPage

    /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
       Are the details vaules of the selected person in the people list used to fill the TextField
       See Delegate Object of the ListView
    */
    property string categoryName;
    property int categoryId;

    /* keep the updated List of subcategory edited by the user (initially contains the saved subcategory) */
    ListModel {
       id: categoryListModelToSave
    }

    /* currently saved subcategory */
    ListModel {
       id: categoryListModelSaved
    }

    /* Custom event based on a custom page property change (ie: the user has chosen another Category
       Necessary to update the associated subcategory to be shown in the subcategory edit popup)
    */
    onCategoryNameChanged: {
        CategoryUtils.initCategoryListModelToSave(categoryEditPage.categoryId);
    }

    header: PageHeader {
       title: i18n.tr("Edit category") +": <b>"+categoryEditPage.categoryName +"</b>"
    }

    /* to have a scrollable column when the keyboard cover some input field */
    Flickable {
        id: editCategoryFlickable
        clip: true
        contentHeight: Utility.getContentHeight() - units.gu(20)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: categoryEditPage.bottom
            bottomMargin: units.gu(2)
        }

        /* Show the details of the selected person */
        Layouts {
            id: layoutsEditCategory
            width: parent.width
            height: parent.height
            layouts:[

                ConditionalLayout {
                    name: "detailsCategoryLayout"
                    when: root.width > units.gu(120)

                       EditCategoryTablet{}
                }
            ]
            //else
            EditCategoryPhone{}
        }
    }

    /* To show a scrollbar on the side */
    Scrollbar {
        flickableItem: editCategoryFlickable
        align: Qt.AlignTrailing
    }
}

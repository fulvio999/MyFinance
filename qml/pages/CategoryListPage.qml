import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* note: alias name must have first letter in upperCase */
import "../js/utility.js" as Utility
import "../js/categoryUtils.js" as CategoryUtils
import "../js/storage.js" as Storage
import "../js/subCategoryReportChart.js" as SubCategoryReportChart

/* import folder */
import "../dialogs"
import "./util"

/*
  List the currently available Category
 */
Page{
    id: categoryListPage

    header: PageHeader {
        title: "MyFinance"

        /* leadingActionBar is the bar on the left side */
        leadingActionBar.actions: [
            Action {
                id: aboutPopover
                /* note: icons names are file names under: /usr/share/icons/suru/actions/scalable */
                iconName: "info"
                text: i18n.tr("About")
                onTriggered:{
                    PopupUtils.open(aboutComponentDialog)
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "list-add"
                text: i18n.tr("Add")
                onTriggered:{                                                //sintax: (current-page, page to add)
                    adaptivePageLayout.addPageToNextColumn(categoryListPage, Qt.resolvedUrl("AddCategoryPage.qml"));
                }
            },

            Action {
                iconName: "delete"
                text: i18n.tr("Delete")
                onTriggered:{
                    PopupUtils.open(dataBaseEraser)
                }
            },

            Action {
                iconName: "settings"
                text: i18n.tr("Settings")
                onTriggered:{

                     adaptivePageLayout.addPageToNextColumn(categoryListPage, Qt.resolvedUrl("ConfigurationPage.qml"),
                                                            {
                                                                /* <pag-variable-name>:<property-value from db> */
                                                                currentCurrency: Storage.getConfigParamValue('currency')
                                                            }

                                                            )
                }
            }
        ]
    }



    /* A list of Category currently saved in the database */
    UbuntuListView {
        id: listView
        anchors.fill: parent
        model: modelListCategory
        delegate: CategoryListDelegate{}

        /* disable the dragging of the model list elements */
        boundsBehavior: Flickable.StopAtBounds
        highlight:
            Component {
                id: highlightComponent

                Rectangle {
                    width: 180; height: 44
                    color: "blue";

                    radius: 2
                    /* move the Rectangle on the currently selected List item with the keyboard */
                    y: listView.currentItem.y

                    /* show an animation on change ListItem selection */
                    Behavior on y {
                        SpringAnimation {
                            spring: 5
                            damping: 0.1
                        }
                    }
                }
            }

        focus: true

        /* header for the list. Is declared here, inside at the ListView, to access at the List items width */
        Component{
            id: listHeader

            Item {
                id: listHeaderItem
                width: parent.width
                height: units.gu(24)
                //x: 5; y: 2;
                x: 5; y: 8;

                Column{
                    id: clo1
                    spacing: units.gu(1)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    /* placeholder */
                    Rectangle {
                        color: "transparent"
                        width: parent.width
                        height: units.gu(5)
                    }

                    Row{
                        id:row1
                        spacing: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextField{
                            id: searchField
                            placeholderText: i18n.tr("category to search")
                            onTextChanged: {
                                if(text.length == 0 ) {
                                    Storage.getAllCategory();
                                }
                            }
                        }

                        Button{
                            id: filterButton
                            objectName: "Search"
                            width: units.gu(10)
                            text: i18n.tr("Search")
                            onClicked: {
                                if(searchField.text.length > 0 )
                                {
                                    modelListCategory.clear();

                                    var categoryFound = Storage.searchCategoryByName(searchField.text);

                                    for(var i =0;i < categoryFound.length;i++){
                                        modelListCategory.append(categoryFound[i]);
                                    }

                                } else {
                                    Storage.getAllCategory()
                                }
                            }
                        }
                    }

                    Row{
                        id:row2
                        spacing: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        Label{
                            id: categoryFoundLabel
                            text: i18n.tr("Total category found")+": " + listView.count
                            font.bold: false
                            font.pointSize: units.gu(1.2)
                        }
                    }

                    Row{
                        id:row3
                        spacing: units.gu(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width

                        Button{
                            id: showReportbutton
                            text: i18n.tr("Global Reports")
                            color: UbuntuColors.green
                            height: units.gu(4)
                            anchors.centerIn: parent.Center
                            width: parent.width

                            onClicked: {
                                adaptivePageLayout.addPageToNextColumn(categoryListPage, Qt.resolvedUrl("GlobalReportPage.qml"));
                            }
                        }
                    }
                }
            }
        }

        header: listHeader
    }

    Scrollbar {
        flickableItem: listView
        align: Qt.AlignTrailing
    }
}

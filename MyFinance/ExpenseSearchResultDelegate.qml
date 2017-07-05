import QtQuick 2.4

import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem


 Component {
        id: categoryListDelegate      

        Item {
            id: personItem
            anchors.fill: parent
            width: expenseSearchResultList.width
            height: units.gu(10) //the heigth of the rectangle

            Rectangle {
                id: background
                x: 2; y: 2; width: parent.width - x*2; height: parent.height - y*2
                color: "ivory"
                border.color: "black"
                radius: 5
            }

            /* This mouse region covers the entire delegate */
            MouseArea {
                id: selectableMouseArea
                anchors.fill: parent
                onClicked: {
                    /* move the highlight component to the currently selected item */
                    expenseSearchResultList.currentIndex = index
                }
            }

            /* crete a row for each entry in the Model */
            Row {
                id: topLayout               
                x: 10; y: 10; height: background.height;
                width: parent.width

                spacing: units.gu(6)

                Column {                    
                    width: background.width - 20; height: personItem.height                   
                    spacing: 1

                    Label {
                        text: amount
                        fontSize: "large"
                    }

                    Label {
                        text: date
                        fontSize: "small"
                    }

                    Label {
                        text: note
                        fontSize: "small"
                    }

                    Label {
                        text: cat_name
                        fontSize: "small"
                    }

                    Label {
                        text: sub_cat_name
                        fontSize: "small"
                    }
                }
            }
        }
    }

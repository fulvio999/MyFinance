import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import "utility.js" as Utility
import "storage.js" as Storage

/*
    Delegate component that display the category saved in the DB as ListItem (See Main.qml)
*/
Component {   
    id: categoryListDelegate

    Item {
        id: categoryItem

        width: listView.width
        height: units.gu(8) //heigth of the rectangle

        /* create a container for each category */
        Rectangle {
            id: background
            x: 2; y: 2; width: parent.width - x*2; height: parent.height - y*1
            border.color: "black"
            radius: 5
        }

        /* This mouse region covers the entire delegate */
        MouseArea {
            id: selectableMouseArea
            anchors.fill: parent

            onClicked: {
                loadingPageActivity.running = true
                adaptivePageLayout.addPageToNextColumn(categoryListPage, categoryExpensePage,
                                                       {                                                         
                                                           /* <page-variable-name>:<property-value from db> */
                                                           id:id, /* id of the category */
                                                           categoryName:cat_name,
                                                           currentExpenseAmount: current_amount
                                                       }

                                                       )


                /* move the highlight component to the currently selected item */
                listView.currentIndex = index
                loadingPageActivity.running = false
            }
        }


        /* crete a row for each entry in the Model */
        Row {
            id: topLayout
            x: 10; y: 7; height: background.height; width: parent.width
            spacing: units.gu(6)

            Column {
                //my new width: (background.width - 20)/2; height: categoryItem.height
                width: background.width - 20; height: categoryItem.height
                anchors.verticalCenter: topLayout.Center
                spacing: 1               

                Label {                   
                    text: cat_name
                    fontSize: "large"
                }

                Label {
                    text: "Expense (at "+Qt.formatDateTime(new Date(), "dd MMMM yyyy")+ " ): "+Number(current_amount).toFixed(2)+ " "+currency
                    fontSize: "small"
                }
            }
        }
    }
}

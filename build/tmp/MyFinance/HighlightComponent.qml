import QtQuick 2.0


/*
 Used by the ListView in Main.qml to highlight the currently selected Item in the Category List
*/
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


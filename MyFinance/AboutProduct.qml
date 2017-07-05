import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3



/* General info about the application */
Dialog {
       id: aboutDialogue
       title: i18n.tr("Product Info")
       text: "MyFinance: version 1.0 <br> Author: fulvio"
       Button {
           text: "Close"
           onClicked: PopupUtils.close(aboutDialogue)
       }
}

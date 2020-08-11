import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3



/* General info about the application */
Dialog {
       id: aboutDialogue
       title: i18n.tr("Product Info")
       text: "MyFinance: "+ i18n.tr("version")+ "1.2.3 <br>"+ i18n.tr("Author")+": "+"fulvio"
       Button {
           text:  i18n.tr("Close")
           onClicked: PopupUtils.close(aboutDialogue)
       }
}

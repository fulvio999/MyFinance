import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Dialog {

    id: operationFailNewExpenseDialog
    title: i18n.tr("Operation Result")
    contentWidth: units.gu(42) /* the width of the Dialog */

     Label{
        anchors.horizontalCenter: operationFailNewExpenseDialog.Center
        text: i18n.tr("Missing required value, or invalid 'Amount'")+" <br/><b> "+i18n.tr("Note: decimal separator is . ")+"</b>"
        color: UbuntuColors.red
    }

    Button {
        text: "Close"
        onClicked:
            PopupUtils.close(operationFailNewExpenseDialog)
    }
}

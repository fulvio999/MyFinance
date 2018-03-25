import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

/* Notify an operation failed */
Dialog {

    id: invalidInputDialog
    title: i18n.tr("Operation Result")

    Label{
        text: i18n.tr("Invalid input value(s)")
        color: UbuntuColors.red
    }

    Button {
        text: i18n.tr("Close")
        onClicked:
            PopupUtils.close(invalidInputDialog)
    }
}

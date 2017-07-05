import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Dialog {
    id: operationResult
    title: i18n.tr("Operation Result")
    text: i18n.tr("No People Found !")
    Button {
        text: "Close"
        onClicked: PopupUtils.close(operationResult)
    }
}

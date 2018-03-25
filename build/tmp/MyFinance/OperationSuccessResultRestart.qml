import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


/* Notify an operation executed successfully and notify that a Restart is required*/
Dialog {   
    id: operationSuccessRestartDialog
    title: i18n.tr("Operation Result")

    Label{
        text: i18n.tr("Operation executed successfully: <br/> <b> ATTENTION: RESTART IS REQUIRED </b>")
        color: UbuntuColors.green
    }

    Button {
        text: "Close"
        onClicked:
            PopupUtils.close(operationSuccessRestartDialog)
    }
}

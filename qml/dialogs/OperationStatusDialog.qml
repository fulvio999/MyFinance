import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0


import QtQuick.LocalStorage 2.0

/* note: alias name must have first letter in upperCase */
import "./js/utility.js" as Utility
import "./js/storage.js" as Storage


/* The first time that user open the application is shown this informative popup
 to notify that default data and currency was set */
Dialog {
        id: operationStatusDialog
        title: i18n.tr("Informations")

        property string currency

        Component.onCompleted: {
            currency = Storage.getConfigParamValue('currency');
        }

        Row {
            spacing: units.gu(1)
            TextArea {
                width: parent.width
                height: units.gu(20)
                enabled: false
                autoSize: true
                horizontalAlignment: TextEdit.AlignHCenter
                placeholderText: i18n.tr("* Database created: OK")+"<br/>"+i18n.tr("* Default data imported: OK")+"<br/>"+i18n.tr("* Currency set to: ")+currency+"  <br/><b>"+i18n.tr("Use configuration menu to change default settings")+"<b/>"
            }
        }

        Row{
            spacing: units.gu(1)

            Rectangle {
                /* get default backbround. to support dark theme */
                color: theme.palette.normal.background
                width: units.gu(8)
                height: units.gu(3)
            }
            Button {
                text: "Close"
                onClicked: {
                    //not ; at the end of the assignement
                    settings.isFirstUse = false
                    settings.defaultDataAlreadyImported = true
                    PopupUtils.close(operationStatusDialog)
                }
            }
        }
    }

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

/* to replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import "./js/storage.js" as Storage


/* Show a Dialog where the user can choose to delete ALL the saved expense */
Dialog {
        id: dataBaseEraserDialog
        text: "<b>"+ i18n.tr("Remove ALL Expenses and Category")+" ?"+"<br/>"+i18n.tr("(there is no restore)")+"</b>"

        Row{
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: units.gu(1)

              Button {
                    id: closeButton
                    text: i18n.tr("Close")
                    onClicked: PopupUtils.close(dataBaseEraserDialog)
              }

              Button {
                    id: importButton
                    text: i18n.tr("Delete")
                    color: UbuntuColors.orange
                    onClicked: {
                          loadingPageActivity.running = true
                          Storage.cleanAllDatabase();

                          deleteOperationResult.text = i18n.tr("Succesfully Removed ALL data")
                          closeButton.enabled = true

                          /* blank settings flag that notify default data already imported.
                               So that the user can import them again with the option in
                               the configuration page.
                          */
                          settings.defaultDataAlreadyImported = false

                          Storage.getAllCategory(); //refresh to empty ListModel
                          adaptivePageLayout.removePages(Qt.resolvedUrl("./pages/CategoryExpensePage.qml"))
                          adaptivePageLayout.removePages(Qt.resolvedUrl("./pages/ConfigurationPage.qml"))

                          loadingPageActivity.running = false
                    }
                }
          }

          Row{
            anchors.horizontalCenter: parent.horizontalCenter
                Label{
                    id: deleteOperationResult
                }
          }
    }

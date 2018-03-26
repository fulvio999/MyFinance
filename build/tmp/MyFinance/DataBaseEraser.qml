import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

/* to replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import "storage.js" as Storage


/* Show a Dialog where the user can choose to delete ALL the saved expense */
Dialog {
    id: dataBaseEraserDialog
    text: "<b>"+ i18n.tr("Remove ALL Expenses and Category")+" ?"+"<br/>"+i18n.tr("(there is no restore)")+"</b>"

    Rectangle {
        width: 180;
        height: 50
        Item{

            Column{

                spacing: units.gu(1)

                Row{
                    spacing: units.gu(1)

                    /* placeholder */
                    Rectangle {
                        color: "transparent"
                        width: units.gu(3)
                        height: units.gu(3)
                    }

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
                            adaptivePageLayout.removePages(categoryExpensePage)
                            adaptivePageLayout.removePages(configurationPage)

                            loadingPageActivity.running = false
                        }
                    }
                }

                Row{
                    Label{
                        id: deleteOperationResult
                    }
                }
            }
        }
    }
}

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

/*
  Dialog opened when the user try to move an expense to a different SubCategory and at the same time.
  Notify that this operation is not allowed: must be performed in two parts
*/
Dialog {

      id: operationNotAllowedDialog
      title: i18n.tr("Operation not allowed")

      Row{
           TextArea {
              width: parent.width
              height: units.gu(20)
              enabled: false
              autoSize: true
              horizontalAlignment: TextEdit.AlignHCenter
              placeholderText: i18n.tr("Is not possible move an expense to a different SubCategory AND change his amount at the same time.")+"<br/>"+
                               i18n.tr("Change the SubCategory and after edit the expense amount")
           }
      }

      Row{
          x: operationNotAllowedDialog.width/5

          Button {
              text: "Close"
              onClicked:
                  PopupUtils.close(operationNotAllowedDialog)
          }
     }
}

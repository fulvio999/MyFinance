import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* note: alias name must have first letter in upperCase */
import "utility.js" as Utility
import "storage.js" as Storage

/*
    A little help page for the application
*/
Column {

    id: helpPageColumn
    anchors.fill: parent
    spacing: units.gu(2)
    anchors.leftMargin: units.gu(2)

    property color linkColor: "blue"
    property string website : "http://www.xe.com/iso4217.php"

    function colorLinks(text) {
            return text.replace(/<a(.*?)>(.*?)</g, "<a $1><font color=\"" + linkColor + "\">$2</font><")
    }

    Rectangle{
        color: "transparent"
        width: parent.width
        height: units.gu(6)
    }

    Component {
        id: operationFailureDialogue
        OperationFailInsertExpense{}
    }

    Row{
        id: headerRow
        spacing: units.gu(6)

        Label {
            id: headerLabel
            text: "<b>"+ i18n.tr("Application Help Page") +"</b>"
        }
    }

    Row{
        id: amountRow
        spacing: units.gu(4)

        TextArea {
            id: noteTextArea
            width: helpPageColumn.width
            height: helpPageColumn.height

            textFormat:TextEdit.RichText
            text: "MyFinance is a simple expenses manager/tracker for personal use. <br/><br/> "+"<b>"+" How it works"+"</b>"+"<br/>"+
                  "Is based on the concept of 'Category' of Expense (eg: Travel, Home, ....) and his subCategory to define a classification of the expense"+"<br/>"+
                  "(eg: plane,train,car for 'Travel' category)."+"<br/>"+
                  "Users can add his custom category and subCategory or edit the default one created during the installation."+"<br/>"+
                  "The default currency is set to EUR, but can be changed in the configuration page."+"<br/>"+
                  "The database is located under the hidden folder: ~phablet/.local/share/myfinance.fulvio/"+"<br/><br/>"+

                  "<b>NOTE:</b>The accepted currency values, MUST be in ISO format (<b>3 letters</b>, eg: EUR,USD) <br/> (See: "+  colorLinks(i18n.tr("<a href=\"%1\">http://www.xe.com/iso4217.php</a>").arg(website))+" <br/> After his modification, is necessary restart the application !"+"<br/><br/>"+

                  "<b>Reports</b>"+"<br/>"+
                  "There are two type of report:"+"<br/>"+
                  "<i>Instant Report</i> : is a progressive report that show the expense situation from the begin at today <br/> (based on the currently saved expenses)"+"<br/>"+
                  "<i>History Report</i> : show expense situation for the last month or for a custom period."+"<br/>"


            readOnly: true
        }
     }
}

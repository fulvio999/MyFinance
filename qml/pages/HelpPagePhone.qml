import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../js/utility.js" as Utility
import "../js/categoryUtils.js" as CategoryUtils
import "../js/storage.js" as Storage
import "../js/subCategoryReportChart.js" as SubCategoryReportChart

/* import folder */
import "../dialogs"
import "./util"

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
        /* to get the background color of the curreunt theme. Necessary if default theme is not used */
        color: theme.palette.normal.background
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
            text: i18n.tr("MyFinance is a simple expenses manager/tracker")+
                  "<br/><br/> "+
                  i18n.tr("Is based on the concept of 'Category' of expense (example: Travel, Home, ....) and his subCategory to define a classification")
                  +"<br/>"+
                  i18n.tr("(example: plane,train,car for 'Travel' category)")
                  +"<br/>"+
                  i18n.tr("Users can add custom category and subCategory or edit the default ones")+
                  "<br/>"+
                  i18n.tr("The default currency is set to EUR, but can be changed in the configuration page")+
                  "<br/>"+

                  i18n.tr("NOTE: Currency values, MUST be in ISO format (3 letters, examle: EUR,USD)")+
                  " <br/>"+
                  i18n.tr("See")+" "+  colorLinks(i18n.tr("<a href=\"%1\">http://www.xe.com/iso4217.php</a>").arg(website))+
                  "<br/>"+
                  i18n.tr("After his modification, restart the application !")
                  +"<br/><br/>"+

                  "<b>"+i18n.tr("Reports types")+"</b>"+
                  "<br/>"+
                  i18n.tr("There are two type of report")+":<br/>"+
                  i18n.tr("Instant Report: a progressive report that show the expense from the begin at today")+
                  "<br/>"+
                  i18n.tr("History Report: expenses situation for the last month or for a custom period")+
                  "<br/>"

            readOnly: true
        }
     }
}

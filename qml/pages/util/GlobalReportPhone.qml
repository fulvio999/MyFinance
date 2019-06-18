import QtQuick 2.4

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* Thanks to: github.com/jwintz/qchart.js for QML bindings for Charts.js, */
import "../../js/storage.js" as Storage
import "../../js/utility.js" as Utility
import "../../js/globalReportChart.js" as GlobalReportChart
import "../../js/QChart.js" as Charts
import "../../js/QChartGallery.js" as ChartsData


/*
  Content of the global reports Page. Global reports are the ones about ALL the category
  This is the content for Phone devices
 */
Column{
    id: globalReportPageColumn
    anchors.fill: parent
    spacing: units.gu(3.5)

    /* properties used inside this file */
    property string currency : Storage.getConfigParamValue('currency');
    property int currentReportItemSelected : 0;

    /* transparent placeholder: required to place the content under the header */
    Rectangle {
        /* to get the background color of the curreunt theme. Necessary if default theme is not used */
        color: theme.palette.normal.background
        width: parent.width
        height: units.gu(3)
    }

    Component {
        id: reportTypeSelectorDelegate
        OptionSelectorDelegate { text: name; subText: description; }
    }

    /* The available reports shown in the combo box */
    ListModel {
        id: reportTypeModel
    }

    /* fill listmodel using this method because allow you to use i18n */
    Component.onCompleted: {
          reportTypeModel.append( { name: "<b>"+i18n.tr("Instant Report")+"</b>", description: i18n.tr("expenses amount at current date"), value:1 } );
          reportTypeModel.append( { name: "<b>"+i18n.tr("Last Month Report")+"</b>", description: i18n.tr("expenses in the last month"), value:2 } );
          reportTypeModel.append( { name: "<b>"+i18n.tr("Custom Report")+"</b>", description: i18n.tr("expenses in a custom range"), value:3 } );
    }

    Row{
        id: reporTypeSelectorrow
        anchors.horizontalCenter: globalReportPageColumn.horizontalCenter

        Label {
            id: reportTypeItemSelectorLabel
            anchors.verticalCenter: reportTypeItemSelector.Center
            text: "<b>"+i18n.tr("Report Types")+"</b>"
        }
    }

    Row{
        spacing: units.gu(2)
        Rectangle{
            id: reportSelectorContainer
            width: globalReportPageColumn.width - units.gu(17)
            height:units.gu(7)
            /* to get the background color of the curreunt theme. Necessary if default theme is not used */
            color: theme.palette.normal.background

            ListItem.ItemSelector {
                id: reportTypeItemSelector
                x:units.gu(1)
                anchors.rightMargin: units.gu(1)
                delegate: reportTypeSelectorDelegate
                model: reportTypeModel
                containerHeight: itemHeight * 3

                /* ItemSelectionChange event is not built-in with ItemSelector component: use a workaround */
                onDelegateClicked:{

                    if(reportTypeItemSelector.currentlyExpanded.toString() != 'false'){

                        if(currentReportItemSelected !== selectedIndex){
                            currentReportItemSelected = selectedIndex;

                            /*  hide all until the user choose a report and press 'Show' button */
                            categoryInstantReportChartRow.visible = false;
                            categoryLastMonthChartRow.visible = false
                            categoryCustomRangeChartRow.visible = false
                            chartTitleLabelContainer.visible = false
                        }
                    }
                }
            }
        }

        Button {
            id: showChartButton          
            text: i18n.tr("Show/Refresh")
            onClicked: {

                /* the charts are already generated, but are shown/hidden according with the chose type in the combo */
                if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).value === 1) { /* instant report */

                    GlobalReportChart.getLegendDataInstantReport();

                    if(instantReportTableListModel.count === 0){
                        chartTitleLabel.text= "<b>"+i18n.tr("NO DATA FOUND")+ "</b>"+i18n.tr("at")+": "+ Qt.formatDateTime(new Date(), "dd MMMM yyyy")+" (date format is yyyy-mm-dd)"
                        chartTitleLabelContainer.visible = true;

                    }else{

                        category_report_current_chart.chartData = GlobalReportChart.getChartDataInstantReport();
                        category_report_current_chart.repaint();

                        categoryInstantReportChartRow.visible = true;
                        categoryLastMonthChartRow.visible = false;
                        categoryCustomRangeChartRow.visible = false;
                        chartTitleLabel.text= "<b>"+i18n.tr("Situation at")+": "+ Qt.formatDateTime(new Date(), "dd MMMM yyyy")
                        chartTitleLabelContainer.visible = true;
                    }

                } else if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).value === 2) {  /* last month report */

                    /* calculates last month time range */
                    var today = Utility.getTodayDate();
                    var monthAgo = Utility.addDaysToDate(today, -30);
                    //console.log('Today is: ' + today.toISOString().replace('Z',''));

                    GlobalReportChart.getLegendDataForLastMonthReport( Utility.formatDateToString(monthAgo), Utility.formatDateToString(today) );

                    if(lastMonthChartListModel.count === 0){

                        chartTitleLabel.text= "<b>"+i18n.tr("NO DATA FOUND")+ "</b><br/> "+i18n.tr("for Monthly report from")+": "+Utility.formatDateToString(monthAgo)+ "  to: "+Utility.formatDateToString(today)+"</b><br/> "+i18n.tr("(date format is yyyy-mm-dd)")
                        chartTitleLabelContainer.visible = true;

                    }else{
                        category_report_history_chart.chartData = GlobalReportChart.getChartDataLastMonthReport(Utility.formatDateToString(monthAgo),Utility.formatDateToString(today));
                        category_report_history_chart.repaint();

                        categoryInstantReportChartRow.visible = false;
                        categoryCustomRangeChartRow.visible = false;
                        categoryLastMonthChartRow.visible = true;
                        chartTitleLabel.text= "<b>"+i18n.tr("Monthly report from")+": "+Utility.formatDateToString(monthAgo)+" "+ i18n.tr("to")+": "+Utility.formatDateToString(today)+"</b><br/> "+i18n.tr("(date format is yyyy-mm-dd)")
                        chartTitleLabelContainer.visible = true;
                    }

                } else if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).value === 3) { /* custom range */

                     /* allow to specify the time range and load data for chart legend */
                     PopupUtils.open(popoverTimeRangeChooserComponentGlobal, showChartButton)

                     categoryInstantReportChartRow.visible = false;
                     categoryLastMonthChartRow.visible = false;
                     categoryCustomRangeChartRow.visible = true;
                     chartTitleLabelContainer.visible = true;
                }
            }
        }
    }

    //------------ Time Range chooser Component used for Custom Report ---------
    Component {
         id: popoverTimeRangeChooserComponentGlobal

         Dialog {

            id: timeRangePickerDialog
            contentWidth: units.gu(42)

            Column{
                 spacing: units.gu(1)
                 width: globalReportPageColumn.width

                 Row{
                     Label{
                         text: "<b>"+i18n.tr("From:")+"</b>"
                     }
                 }

                 Row{
                     DatePicker {
                         id: timeFromPickerGlobal
                         mode: "Days|Months|Years"
                         minimum: {
                             var time = new Date()
                             time.setFullYear('2000')
                             return time
                         }
                     }
                 }

                 Row{
                     Label{
                         text: "<b>"+i18n.tr("To:")+"</b>"
                     }
                 }

                 Row{
                     DatePicker {
                         id: timeToPickerGlobal
                         mode: "Days|Months|Years"
                         minimum: {
                             var time = new Date()
                             time.setFullYear(time.getFullYear())
                             return time
                         }
                     }
                 }

                 Row {
                     width: globalReportPageColumn.width/3
                     spacing: units.gu(2)

                     Button {
                         text: i18n.tr("Confirm")
                         width: units.gu(17)
                         onClicked: {

                             var to = new Date (timeToPickerGlobal.date);
                             var from = new Date (timeFromPickerGlobal.date);

                             chartTitleLabel.text= "<b>"+i18n.tr("Custom report from")+": "+Utility.formatDateToString(from)+ i18n.tr("to")+": "+Utility.formatDateToString(to)+"</b><br/> "+i18n.tr("(date format is yyyy-mm-dd)")

                             GlobalReportChart.getLegendDataForCustomRangeReport(Utility.formatDateToString(from),Utility.formatDateToString(to));

                             if(customRangeChartListModel.count === 0){
                                chartTitleLabel.text= "<b>"+i18n.tr("NO DATA FOUND")+" </b>"+i18n.tr("from")+": "+Utility.formatDateToString(from)+" "+i18n.tr("to")+": "+Utility.formatDateToString(to)+"<br/>"+i18n.tr("(date format is yyyy-mm-dd)")
                             }else{
                                 category_report_history_custom_chart.chartData = GlobalReportChart.getChartDataCustomRangeReport(Utility.formatDateToString(from),Utility.formatDateToString(to));
                                 category_report_history_custom_chart.repaint();
                             }

                             PopupUtils.close(timeRangePickerDialog)
                         }
                     }

                     Button {
                         text: i18n.tr("Close")
                         width: units.gu(18)
                         onClicked: {
                            PopupUtils.close(timeRangePickerDialog)
                         }
                     }
                 }
            }
         }
    }
    //-----------------------------------------

    /* Chart Title */
    Rectangle {
        id: chartTitleLabelContainer
        visible: false
        color: "transparent"
        width: parent.width
        height: units.gu(2)
        Label{
            id: chartTitleLabel
            anchors.centerIn: parent
        }
    }


    /* Note: using GridLayout or create Columns is not possible have to chart on the same row
       See: http://askubuntu.com/questions/531472/how-to-create-charts-in-qml  for charts Array building form query
    */

    //------------- Instant report chart ---------------------
    Grid {
        id: categoryInstantReportChartRow
        visible: false
        columns:2
        columnSpacing: units.gu(1)
        width: parent.width;
        height: parent.height

        QChart{
            id: category_report_current_chart;
            width: parent.width/2 + units.gu(3);
            height: parent.height - reporTypeSelectorrow.height - units.gu(26);
            chartAnimated: false;
            //chartData: GlobalReportChart.getChartDataInstantReport();
            chartType: Charts.ChartType.BAR;
        }

        /* model for the chart table legend */
        ListModel {
            id: instantReportTableListModel
        }

        /* Chart data legend */
        ListView {
            width: parent.width
            height: parent.height
            model: instantReportTableListModel
            delegate:

                Component{
                    id: instantReportChartLegend
                    Rectangle {
                        id: wrapper
                        height: legendRow.height + units.gu(1)
                        border.color: UbuntuColors.lightGrey
                        border.width:units.gu(1)

                        Label {
                            anchors.horizontalCenter: wrapper.Center
                            id: legendRow
                            text: "<b>"+cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"
                        }
                    }
                }
         }
    }


    //------------- Last month chart ---------------------
    Grid {
        id: categoryLastMonthChartRow
        visible: false
        columns:2
        columnSpacing: units.gu(1)
        width: parent.width;
        height: parent.height

        QChart{
            id: category_report_history_chart;
            width: parent.width/2 + units.gu(3);
            height: parent.height - reporTypeSelectorrow.height - units.gu(26);
            chartAnimated: false;
            chartType: Charts.ChartType.BAR;
        }

        /* model for the chart table legend */
        ListModel {
            id: lastMonthChartListModel
        }

        /* Chart data legend */
        ListView {
            width: parent.width
            height: parent.height
            model: lastMonthChartListModel
            delegate:

                Component{
                id: lastMonthChartLegend
                Rectangle {
                    id: wrapper
                    height: legendEntry.height + units.gu(1)
                    border.color: UbuntuColors.lightGrey
                    border.width:units.gu(1)

                    Label {
                        anchors.horizontalCenter: wrapper.Center
                        id: legendEntry
                        text: "<b>"+cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"
                    }
                }
            }
        }
    }


    //------------- Custom range chart ---------------
    Grid {
        id: categoryCustomRangeChartRow
        visible: false
        columns:2
        columnSpacing: units.gu(1)
        width: parent.width;
        height: parent.height

        QChart{
            id: category_report_history_custom_chart;
            width: parent.width/2 + units.gu(3);
            height: parent.height - reporTypeSelectorrow.height - units.gu(26);
            chartAnimated: false;
            chartType: Charts.ChartType.BAR;
        }

        /* model for the chart table legend */
        ListModel {
            id: customRangeChartListModel
        }

        /* Chart data legend */
        ListView {
            width: parent.width
            height: parent.height
            model: customRangeChartListModel
            delegate:

                Component{
                id: customReportChartLegend
                Rectangle {
                    id: wrapper
                    height: legendEntry.height + units.gu(1)
                    border.color: UbuntuColors.lightGrey
                    border.width:units.gu(1)

                    Label {
                        anchors.horizontalCenter: wrapper.Center
                        id: legendEntry
                        text: "<b>"+cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"
                    }
                }
            }
        }
    }


}

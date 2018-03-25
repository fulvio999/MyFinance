import QtQuick 2.4

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "."
import "storage.js" as Storage
import "utility.js" as Utility
import "subCategoryReportChart.js" as SubCategoryReportChart
import "QChart.js" as Charts

//--------------- Display statistics reports (charts) for the chosen SUB-Category -------

Column{
    id: reportPageColumn
    anchors.fill: parent
    spacing: units.gu(3.5)

    /* properties used inside this file */
    property string currency : Storage.getConfigParamValue('currency');
    property int currentReportItemSelected : 0;
    /* a local properties used to intercept selected category changes event */
    property int selectedCategoryId: statisticsPage.categoryId

    /* transparent placeholder: required to place the content under the header */
    Rectangle {
        color: "transparent"
        width: parent.width
        height: units.gu(3)
    }

    Component {
        id: reportTypeSelectorDelegate
        OptionSelectorDelegate { text: name; subText: description; }
    }

    onSelectedCategoryIdChanged: {
        /* hide all charts beacuse the user has choose a different category */
        subCategoryInstantReportChartRow.visible = false;
        subCategoryLastMonthChartRow.visible = false
        subCategoryCustomRangeChartRow.visible = false
        chartTitleLabelContainer.visible = false
    }

    ListModel {
        id: reportTypeModel
        ListElement { name: "<b>Instant Report</b>"; description: "show the subcategory expenses current amount"; }
        ListElement { name: "<b>Last Month Report</b>"; description: "show the subcategory expenses in the last month"; }
        ListElement { name: "<b>Custom Report</b>"; description: "show the subcategory expenses in a custom range"; }
    }

    Row{
        id: reporTypeSelectorrow
        anchors.horizontalCenter: reportPageColumn.horizontalCenter

        Label {
            id: reportTypeItemSelectorLabel
            anchors.verticalCenter: reportTypeItemSelector.Center
            text: "<b>"+i18n.tr("Available Reports")+"</b>"
        }
    }

    Row{
        spacing: units.gu(2)

        Rectangle{
            width: reportPageColumn.width - units.gu(17)
            height:units.gu(7)

            ListItem.ItemSelector {
                id: reportTypeItemSelector
                x:units.gu(1)
                anchors.rightMargin: units.gu(1)
                delegate: reportTypeSelectorDelegate
                model: reportTypeModel
                containerHeight: itemHeight * 3

                /* ItemSelectionChange event is not built-in with ItemSelector: use a workaround */
                onDelegateClicked:{

                    if(reportTypeItemSelector.currentlyExpanded.toString() != 'false'){

                        if(currentReportItemSelected !== selectedIndex){
                            currentReportItemSelected = selectedIndex;

                            /* hide all until the user choose a report and press 'Show' button */
                            subCategoryInstantReportChartRow.visible = false;
                            subCategoryLastMonthChartRow.visible = false
                            subCategoryCustomRangeChartRow.visible = false
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

                    if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).name === "<b>Instant Report</b>") {

                        SubCategoryReportChart.getLegendDataInstantReport(statisticsPage.categoryId);

                        sub_category_report_current_chart.chartData = SubCategoryReportChart.getChartDataInstantReport(statisticsPage.categoryId);

                        subCategoryInstantReportChartRow.visible = true;
                        subCategoryLastMonthChartRow.visible = false;
                        subCategoryCustomRangeChartRow.visible = false;
                        chartTitleLabel.text= "<b>"+i18n.tr("Situation at: ")+ Qt.formatDateTime(new Date(), "dd MMMM yyyy")
                        chartTitleLabelContainer.visible = true;

                    } else if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).name === "<b>Last Month Report</b>") {

                        var today = Utility.getTodayDate();  //eg: Wed Mar 29 00:00:00 2017 GMT
                        var monthAgo = Utility.addDaysToDate(today, -30);

                        SubCategoryReportChart.getLegendDataForLastMonthReport( Utility.formatDateToString(monthAgo), Utility.formatDateToString(today),statisticsPage.categoryId );

                        /* true if no data found */
                        if(lastMonthChartListModel.count === 0){

                           chartTitleLabel.text= "<b>"+i18n.tr("NO DATA FOUND")+"</b><br/>"+i18n.tr("for Monthly report from: ")+Utility.formatDateToString(monthAgo)+ "  to: "+Utility.formatDateToString(today)+"</b><br/>"+" (date format is yyyy-mm-dd)"
                           chartTitleLabelContainer.visible = true;

                        }else{

                            sub_category_report_history_chart.chartData = SubCategoryReportChart.getChartDataLastMonthReport(Utility.formatDateToString(monthAgo), Utility.formatDateToString(today), statisticsPage.categoryId);

                            subCategoryInstantReportChartRow.visible = false;
                            subCategoryCustomRangeChartRow.visible = false;
                            subCategoryLastMonthChartRow.visible = true;
                            chartTitleLabel.text= "<b>"+"Monthly report from: "+Utility.formatDateToString(monthAgo)+ "  to: "+Utility.formatDateToString(today)+"</b><br/>"+" (date format is yyyy-mm-dd)"
                            chartTitleLabelContainer.visible = true;
                        }

                    } else if (reportTypeModel.get(reportTypeItemSelector.selectedIndex).name === "<b>Custom Report</b>") {

                         /* allow to specify the time range and load data for chart legend */
                         PopupUtils.open(popoverTimeRangeChooserComponent, showChartButton)

                         subCategoryInstantReportChartRow.visible = false;
                         subCategoryLastMonthChartRow.visible = false;
                         subCategoryCustomRangeChartRow.visible = true;
                         chartTitleLabelContainer.visible = true;
                    }
              }
          }
    }

    //------------ Time Range chooser Component used for Custom Report ---------
    Component {
         id: popoverTimeRangeChooserComponent

         Dialog {

             id: timeRangePickerDialog
             contentWidth: units.gu(42)

             Column{
                 spacing: units.gu(1)
                 width: reportPageColumn.width

                 Row{
                     Label{
                         text: "<b>"+i18n.tr("From:")+"</b>"
                     }
                 }

                 Row{
                     DatePicker {
                         id: timeFromPicker
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
                         id: timeToPicker
                         mode: "Days|Months|Years"
                         minimum: {
                             var time = new Date()
                             time.setFullYear(time.getFullYear())
                             return time
                         }
                     }
                 }

                 Row {
                     width: reportPageColumn.width/3
                     spacing: units.gu(1)

                     Button {
                         text: i18n.tr("Confirm")
                         width: units.gu(17)
                         onClicked: {

                             var to = new Date (timeToPicker.date);
                             var from = new Date (timeFromPicker.date);

                             chartTitleLabel.text= "<b>"+i18n.tr("Custom report from: ")+Utility.formatDateToString(from)+ "  to: "+Utility.formatDateToString(to)+"</b>"+"<br/> (date format is yyyy-mm-dd)"

                             SubCategoryReportChart.getLegendDataForCustomRangeReport(Utility.formatDateToString(from),Utility.formatDateToString(to),statisticsPage.categoryId);

                             /* if no data found create an empty chart legend */
                             if(customRangeChartListModel.count === 0){
                                 chartTitleLabel.text= "<b>"+i18n.tr("NO DATA FOUND")+"</b>"+i18n.tr("from: ")+Utility.formatDateToString(from)+ " to: "+Utility.formatDateToString(to)+"<br/> (date format is yyyy-mm-dd)"
                             }else{
                                sub_category_report_history_custom_chart.chartData = SubCategoryReportChart.getChartDataCustomRangeReport(Utility.formatDateToString(from),Utility.formatDateToString(to),statisticsPage.categoryId);
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

   /* Chart Title/Header */
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


   //------------- Instant report chart ---------------------
   Grid {
       id: subCategoryInstantReportChartRow
       visible: false
       columns:2
       columnSpacing: units.gu(1)
       width: parent.width;
       height: parent.height

       QChart{
           id: sub_category_report_current_chart;
           width: parent.width/2 + units.gu(3);
           height: parent.height - reporTypeSelectorrow.height - units.gu(26);
           chartAnimated: false;
           //chartData: SubCategoryReportChart.getChartDataInstantReport(statisticsPage.categoryId);
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

                       Text {
                           anchors.horizontalCenter: wrapper.Center
                           id: legendRow
                           text: "<b>"+sub_cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"

                       }
                   }
               }
        }
   }


   //------------- Last month chart ---------------------
   Grid {
       id: subCategoryLastMonthChartRow
       visible: false
       columns:2
       columnSpacing: units.gu(1)
       width: parent.width;
       height: parent.height

       QChart{
           id: sub_category_report_history_chart;
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

                   Text {
                       anchors.horizontalCenter: wrapper.Center
                       id: legendEntry
                       text: "<b>"+sub_cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"
                   }
               }
           }
       }
   }


   //------------- Custom range chart ---------------
   Grid {
       id: subCategoryCustomRangeChartRow
       visible: false
       columns:2
       columnSpacing: units.gu(1)
       width: parent.width;
       height: parent.height

       QChart{
           id: sub_category_report_history_custom_chart;
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

                   Text {
                       anchors.horizontalCenter: wrapper.Center
                       id: legendEntry
                       text: "<b>"+sub_cat_name+"</b> :  "+current_amount +" <i>"+currency+ "</i>"
                   }
               }
           }
       }
   }

}

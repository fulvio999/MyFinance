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

//--------------- Statistics Page for a category ---------------
Page {
    id: statisticsPage
    property string categoryName;
    property int categoryId;
    property string toRefresh;

    header: PageHeader {
       title: i18n.tr("Statistics for category")+": "+ "<b>"+statisticsPage.categoryName +"</b>"
    }

    Layouts {
        id: layoutsReportPage
        width: parent.width
        height: parent.height
        layouts:[

            ConditionalLayout {
                name: "layoutsReportLayout"
                when: root.width > units.gu(80)
                    SubCategoryReportTablet{}
            }
        ]
        //else
        SubCategoryReportPhone{}
    }
}

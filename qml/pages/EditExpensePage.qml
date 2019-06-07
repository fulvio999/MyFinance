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


//---------------- EDIT Expense Page--------------

  Page{
      id: editExpensePage
      anchors.fill: parent

      /* values that the user can't modify */
      property string categoryId;
      property string expenseId;
      property string categoryName;

      /*vaues that the user can edit, modify */
      property string currentSubCategory;
      property string currentAmount;
      property string currentNote;
      property string currentDate;

      header: PageHeader {
          id: headerEditExpensePage
          title: i18n.tr("Edit Expense for category") +": "+ "<b>" +editExpensePage.categoryName +"</b>"
      }

      /* Show the details of the selected person */
      Layouts {
              id: layoutEditExpensePage
              width: parent.width
              height: parent.height
              layouts:[

                  ConditionalLayout {
                      name: "editExpenseContactLayout"
                      when: root.width > units.gu(120)
                           EditExpenseTablet{}
                  }
              ]
              //else
              EditExpensePhone{}
      }
  }

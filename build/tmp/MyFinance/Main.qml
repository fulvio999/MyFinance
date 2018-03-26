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
import "categoryUtils.js" as CategoryUtils
import "storage.js" as Storage
import "subCategoryReportChart.js" as SubCategoryReportChart


MainView {

    id: root

    objectName: "mainView"
    automaticOrientation: true
    anchorToKeyboard: true

    property string currency;

    /* applicationName needs to match the "name" field in the application manifest
       Note:' applicationName' value sets the DB storage path if using U1DB api (remove the blank spaces in the url):
       eg: ~phablet/.local/share/<applicationName>/file:/opt/<click.ubuntu.com>/<applicationName>/<version-number>/MyPeople/MyPeople_db
    */
    applicationName: "myfinance.fulvio"
    width: units.gu(160)
    height: units.gu(90)

    /* phone */
    //width: units.gu(50)
    //height: units.gu(96)

    /* Settings file is saved in ~user/.config/<applicationName>/<applicationName>.conf  File */
    Settings {
        id:settings
        /* to show or not the configuration Wizard popup */
        property bool isFirstUse : true;
        property bool defaultDataAlreadyImported : false;
    }

    ActivityIndicator {
        id: loadingPageActivity
    }

    /* Executed at application startup */
    Component.onCompleted: {

       if(settings.isFirstUse == true){

            Storage.createTables();
            Storage.insertDefaultData();

            /* refresh the category list shown */
            Storage.getAllCategory();

            /* show wizard to say that default values can be changed in the App configuration page */
            Utility.showOperationStatusDialog();

            settings.isFirstUse = false

        }else{
           currency = Storage.getConfigParamValue('currency');
           Storage.getAllCategory();
        }
    }

    Component {
        id: dataBaseEraser
        DataBaseEraser{}
    }

    /* On first use, show a popup with some base informations */
    Component {
        id: operationStatusDialog
        OperationStatusDialog{}
    }

    Component {
        id: itemNotFoundResultDialogue
        ItemNotFound{}
    }

    /* PopUp with Application info */
    Component {
        id: aboutComponentDialog
        AboutProduct{}
    }


    /* AdaptivePageLayout provides a flexible way of viewing a stack of pages in one or more columns */
    AdaptivePageLayout {

        id: adaptivePageLayout
        anchors.fill: parent

        /* mandatory */
        primaryPage: categoryListPage

        Page{
            id: categoryListPage

            header: PageHeader {
                title: "MyFinance"

                /* leadingActionBar is the bar on the left side */
                leadingActionBar.actions: [
                    Action {
                        id: aboutPopover
                        /* note: icons names are file names under: /usr/share/icons/suru/actions/scalable */
                        iconName: "info"
                        text: i18n.tr("About")
                        onTriggered:{
                            PopupUtils.open(aboutComponentDialog)
                        }
                    }
                ]

                trailingActionBar.actions: [
                    Action {
                        iconName: "list-add"
                        text: i18n.tr("Add")
                        onTriggered:{                           //sintax: (current-page, page to add)
                            adaptivePageLayout.addPageToNextColumn(categoryListPage, addCategoryPage)
                        }
                    },

                    Action {
                        iconName: "delete"
                        text: i18n.tr("Delete")
                        onTriggered:{
                            PopupUtils.open(dataBaseEraser)
                        }
                    },

                    Action {
                        iconName: "settings"
                        text: i18n.tr("Settings")
                        onTriggered:{

                             adaptivePageLayout.addPageToNextColumn(categoryListPage,configurationPage,
                                                                    {
                                                                        /* <pag-variable-name>:<property-value from db> */
                                                                        currentCurrency: Storage.getConfigParamValue('currency')
                                                                    }

                                                                    )
                        }
                    }
                ]
            }


            /* the list of category saved. Loaded onComplete event */
            ListModel{
                id: modelListCategory
            }

            /* A list of Category saved in the database */
            UbuntuListView {
                id: listView
                anchors.fill: parent
                model: modelListCategory
                delegate: CategoryListDelegate{}

                /* disable the dragging of the model list elements */
                boundsBehavior: Flickable.StopAtBounds
                highlight: HighlightComponent{}
                focus: true

                /* header for the list. Is declared here, inside at the ListView, to access at the List items width */
                Component{
                    id: listHeader

                    Item {
                        id: listHeaderItem
                        width: parent.width
                        height: units.gu(24)
                        //x: 5; y: 2;
                        x: 5; y: 8;

                        Column{
                            id: clo1
                            spacing: units.gu(1)
                            anchors.verticalCenter: parent.verticalCenter

                            /* placeholder */
                            Rectangle {
                                color: "transparent"
                                width: parent.width
                                height: units.gu(5)
                            }

                            Row{
                                id:row1
                                spacing: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter

                                TextField{
                                    id: searchField
                                    placeholderText: i18n.tr("category to search")
                                    onTextChanged: {
                                        if(text.length == 0 ) {
                                            Storage.getAllCategory();
                                        }
                                    }
                                }

                                Button{
                                    id: filterButton
                                    objectName: "Search"
                                    width: units.gu(10)
                                    text: i18n.tr("Search")
                                    onClicked: {
                                        if(searchField.text.length > 0 )
                                        {
                                            modelListCategory.clear();

                                            var categoryFound = Storage.searchCategoryByName(searchField.text);

                                            for(var i =0;i < categoryFound.length;i++){
                                                modelListCategory.append(categoryFound[i]);
                                            }

                                        } else {
                                            Storage.getAllCategory()
                                        }
                                    }
                                }
                            }

                            Row{
                                id:row2
                                spacing: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                Label{
                                    id: categoryFoundLabel
                                    text: i18n.tr("Total category found")+": " + listView.count
                                    font.bold: false
                                    font.pointSize: units.gu(1.2)
                                }
                            }

                            Row{
                                id:row3
                                spacing: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width

                                Button{
                                    id: showReportbutton
                                    text: i18n.tr("Global Reports")
                                    color: UbuntuColors.green
                                    height: units.gu(4)
                                    anchors.centerIn: parent.Center
                                    width: parent.width

                                    onClicked: {
                                        adaptivePageLayout.addPageToNextColumn(categoryListPage, globalReportPage);
                                    }
                                }
                            }
                        }
                    }
                }

                header: listHeader
            }

            Scrollbar {
                flickableItem: listView
                align: Qt.AlignTrailing
            }
        }

        //-------------------- EXPENSE CATEGORY PAGE ----------------------
        Page{
            id:categoryExpensePage

            anchors.fill: parent

            /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
               Are the details vaules of the selected person in the people list used to fill the TextField
               See Delegate Object of the ListView
            */
            property string id  /* id of the category (not shown) */
            property string categoryName
            property string currentCurrency : Storage.getConfigParamValue('currency');
            property string currentExpenseAmount  /* current expense amout for a category */

            header: PageHeader {
                id: headerDetailsPage
                title: i18n.tr("Manage expenses for")+": " + "<b>" +categoryExpensePage.categoryName +"</b>"
            }

            /* to set default values on category changes */
            onIdChanged: {

                //TODO: blank all chart models....

                //SubCategoryReportChart.clearModels();


            }


            /* to have a scrollable column when the keyboard cover some input field */
            Flickable {
                id: expesneDetailsFlickable
                clip: true
                contentHeight: Utility.getContentHeight()
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: categoryExpensePage.bottom
                    bottomMargin: units.gu(2)
                }

                /* Show the details of the selected person */
                Layouts {
                    id: layoutsDetailsContact
                    width: parent.width
                    height: parent.height
                    layouts:[

                        ConditionalLayout {
                            name: "detailsContactLayout"
                            when: root.width > units.gu(80)
                                 ExpensesTablet{ }
                        }
                    ]
                    //else
                    ExpensesPhone{}
                }
            }

            /* To show a scrollbar on the side */
            Scrollbar {
                flickableItem: expesneDetailsFlickable
                align: Qt.AlignTrailing
            }

        }
        //---------------- END EXPENSE PAGE --------------------



        //------------- ADD NEW CATEGORY and SUBCATEGORY PAGE ---------------
        Page {
            id: addCategoryPage

            header: PageHeader {
                title: i18n.tr("Add new Category and subcategory")
            }

            Flickable {
                id: newCategoryPageFlickable
                clip: true
                contentHeight: Utility.getContentHeight() - units.gu(20)
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: addCategoryPage.bottom
                    bottomMargin: units.gu(2)
                }

                /* Show a form to add a new contact */
                Layouts {
                    id: layouts
                    width: parent.width
                    height: parent.height
                    layouts:[

                        ConditionalLayout {
                            name: "addContactLayout"
                            when: root.width > units.gu(80) // && Screen.orientation === Qt.LandscapeOrientation
                            AddCategoryTablet{}
                        }
                    ]
                    //else
                    AddCategoryPhone{}
                }
            }

            /* To show a scrolbar on the side */
            Scrollbar {
                flickableItem: newCategoryPageFlickable
                align: Qt.AlignTrailing
            }
        }


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


        //---------------- Edit Category Page--------------
        Page{
            id:categoryEditPage

            /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
               Are the details vaules of the selected person in the people list used to fill the TextField
               See Delegate Object of the ListView
            */
            property string categoryName;
            property int categoryId;

            /* keep the updated List of subcategory edited by the user (initially contains the saved subcategory) */
            ListModel {
               id: categoryListModelToSave
            }

            /* currently saved subcategory */
            ListModel {
               id: categoryListModelSaved
            }

            /* Custom event based on a custom page property change (ie: the user has chosen another Category
               Necessary to update the associated subcategory to be shown in the subcategory edit popup)
            */
            onCategoryNameChanged: {
                CategoryUtils.initCategoryListModelToSave(categoryEditPage.categoryId);
            }

            header: PageHeader {
               title: i18n.tr("Edit category") +": <b>"+categoryEditPage.categoryName +"</b>"
            }

            /* to have a scrollable column when the keyboard cover some input field */
            Flickable {
                id: editCategoryFlickable
                clip: true
                contentHeight: Utility.getContentHeight() - units.gu(20)
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: categoryEditPage.bottom
                    bottomMargin: units.gu(2)
                }

                /* Show the details of the selected person */
                Layouts {
                    id: layoutsEditCategory
                    width: parent.width
                    height: parent.height
                    layouts:[

                        ConditionalLayout {
                            name: "detailsCategoryLayout"
                            when: root.width > units.gu(80)

                               EditCategoryTablet{}
                        }
                    ]
                    //else
                    EditCategoryPhone{}
                }
            }

            /* To show a scrollbar on the side */
            Scrollbar {
                flickableItem: editCategoryFlickable
                align: Qt.AlignTrailing
            }
        }

        //------------------------------------------------------



        //---------------- Find Expense Page--------------
        Page{
                id:findExpensePage

                /* Values passed as input properties when the AdaptiveLayout add the details page (See: CategoryListDelegate.qml)
                   Are the details vaules of the selected person in the people list used to fill the TextField
                   See Delegate Object of the ListView
                */
                property string categoryName;
                property int categoryId;
                property string currency: Storage.getConfigParamValue('currency');

                header: PageHeader {
                   title: i18n.tr("Find Expense for category") +": "+ "<b>"+findExpensePage.categoryName +"</b>"
                }

                ListModel {
                    id: expenseModel
                }

                onCategoryIdChanged: {
                    /* clean previous result search for a different category */
                    expenseModel.clear();
                }

                Component {
                    id: expenseFoundDelegate
                    ExpenseFoundDelegate{}
                }

                UbuntuListView {
                    id: expenseSearchResultList
                    /* necessary, otherwise hide the search criteria row */
                    anchors.topMargin: units.gu(33) //units.gu(searchReloadRow.height + expenseFoundTitle.height + searchCriteriaRow.height + dateFilterRow.height + categoryFilterRow.height)
                    anchors.fill: parent
                    focus: true
                    /* nececessary otherwise the list scroll under the  */
                    clip: true
                    model: expenseModel
                    boundsBehavior: Flickable.StopAtBounds
                    highlight: HighlightComponent{}
                    delegate: expenseFoundDelegate
                }

                /* Show the details of the selected person */
                Layouts {
                    id: layoutsFindExpense
                    width: parent.width
                    height: parent.height
                    layouts:[

                        ConditionalLayout {
                            name: "findExpenseLayout"
                            when: root.width > units.gu(80)

                               FindExpenseTablet{}
                         }
                    ]
                    //else
                    FindExpensePhone{}
                }

            Scrollbar {
                flickableItem: expenseSearchResultList
                align: Qt.AlignTrailing
            }
      }

      //---------------- EDIT Expense Page--------------

        Page{
            id: editExpensePage
            anchors.fill: parent

            /* values that the user can't modify */
            property string expenseId;
            property string categoryName;

            /*vaues that the user can edit, modify */
            property string currentSubCategory;
            property string currentAmount;
            property string currentNote;
            property string currentDate;

            header: PageHeader {
                id: headerEditExpensePage
                title: i18n.tr("Edit Expense for category") +": "+ "<b>" +categoryExpensePage.categoryName +"</b>"
            }

            /* Show the details of the selected person */
            Layouts {
                    id: layoutEditExpensePage
                    width: parent.width
                    height: parent.height
                    layouts:[

                        ConditionalLayout {
                            name: "editExpenseContactLayout"
                            when: root.width > units.gu(80)
                                 EditExpenseTablet{}
                        }
                    ]
                    //else
                    EditExpensePhone{}
            }
        }

        //---------------------------------------------------




        //----------------- Configuration page -----------------
        Page {
            id: configurationPage

            property string categoryName;
            property string currentCurrency;

            header: PageHeader {
               title: i18n.tr("Application Configuration")
            }

            Layouts {
                id: layoutConfigurationPage
                width: parent.width
                height: parent.height
                layouts:[

                    ConditionalLayout {
                        name: "layoutsConfiguration"
                        when: root.width > units.gu(50)
                            AppConfigurationTablet{}
                    }
                ]
                //else
                AppConfigurationPhone{}
            }
       }
       //-------------------------------------------------------



       //----------------- Global Report Page -----------------
       Page {
            id: globalReportPage

            header: PageHeader {
               title: i18n.tr("Category Global Report")
            }

            Layouts {
                id: layoutGlobalReportPage
                width: parent.width
                height: parent.height
                layouts:[

                    ConditionalLayout {
                        name: "layoutsConfiguration"
                        when: root.width > units.gu(50)
                            GlobalReportTablet{}
                    }
                ]
                //else
                GlobalReportPhone{}
            }
       }
       //-------------------------------------------------------


       //---------------------- Help page ----------------------
       Page {
            id: helpPage

            header: PageHeader {
               title: i18n.tr("Help Page")
            }

            Layouts {
                id: layoutHelpPage
                width: parent.width
                height: parent.height
                layouts:[

                    ConditionalLayout {
                        name: "helpPageLayout"
                        when: root.width > units.gu(80)
                            HelpPageTablet{}
                    }
                ]
                //else
                HelpPagePhone{}
            }
       }
       //--------------------------------------------------------


    }  //adaptive


}

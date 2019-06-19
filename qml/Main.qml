import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

/* note: alias name must have first letter in upperCase */
import "./js/utility.js" as Utility
import "./js/categoryUtils.js" as CategoryUtils
import "./js/storage.js" as Storage
import "./js/subCategoryReportChart.js" as SubCategoryReportChart

/* import folder */
import "./pages"
import "./dialogs"

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

    /* enable to test with dark theme */
    //theme.name: "Ubuntu.Components.Themes.SuruDark"

    /* to test themes others then default one */
    //theme.name: "Ubuntu.Components.Themes.SuruDark"

    /*------- Tablet (width >= 110) -------- */
    //vertical
    //width: units.gu(75)
    //height: units.gu(111)

    //horizontal (rel)
    width: units.gu(100)
    height: units.gu(75)

    //Tablet horizontal
    //width: units.gu(128)
    //height: units.gu(80)

    //Tablet vertical
    //width: units.gu(80)
    //height: units.gu(128)

    /* ----- phone 4.5 (the smallest one) ---- */
    //vertical
    //width: units.gu(50)
    //height: units.gu(96)

    //horizontal
    //width: units.gu(96)
    //height: units.gu(50)
    /* -------------------------------------- */

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

            console.log("First Use");

            Storage.createTables();
            Storage.insertDefaultData();

            /* refresh the category list shown */
            Storage.getAllCategory();

            settings.isFirstUse = false

        }else{
           currency = Storage.getConfigParamValue('currency');
           Storage.getAllCategory();
        }
    }

    /* the list of category saved. Loaded onComplete event. Included iherein root page to be used dy sub-pages */
    ListModel{
        id: modelListCategory
    }

    Component {
        id: dataBaseEraser
        DataBaseEraser{}
    }

    /* On first use, show a popup with some base informations */
   /* Component {
        id: operationStatusDialog
        OperationStatusDialog{}
    }
    */

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

        /* mandatory: first page to load */
        primaryPage: CategoryListPage{}
    }
}

TEMPLATE = aux
TARGET = MyFinance

RESOURCES +=

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  MyFinance.apparmor \
               MyFinance.png

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)               

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               MyFinance.desktop

#specify where the qml/js files are installed to
qml_files.path = /MyFinance
#qml_files.path += /MyFinance/util
#qml_files.path += /MyFinance/js
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /MyFinance
config_files.files += $${CONF_FILES}

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /MyFinance
desktop_file.files = $$OUT_PWD/MyFinance.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files desktop_file

DISTFILES += \
    OperationFailureResult.qml \
    reports/ReportPageTablet.qml \
    reports/ReportPagePhone.qml \
    ConfigurationPage.qml \
    EditCategory.qml \
    HelpPageTablet.qml \
    HelpPagePhone.qml \
    util/ImportDataAlreadyDone.qml \
    util/InvalidInputPopUp.qml \
    util/OperationSuccessResultRestart.qml \
    ReportSelectorForm.qml \
    FindExpenseTablet.qml \
    FindExpensePhone.qml \
    GlobalReportTablet.qml \
    GlobalReportPhone.qml \
    ExpenseSearchResultDelegate.qml \
    EditExpenseTablet.qml \
    EditExpensePhone.qml \
    js/globalReportChart.js \
    js/subCategoryReportChart.js \
    ExpenseFoundDelegate.qml

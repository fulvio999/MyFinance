import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0

/* replace the 'incomplete' QML API U1db with the low-level QtQuick API */
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "utility.js" as Utility
import "categoryUtils.js" as CategoryUtils
import "storage.js" as Storage


/*
 Used in Main.qml to show the details of a selectd Person/contact in the contacts List. Used for Tablet

 NOTE: All the TextField have set 'hasClearButton: false'. If 'hasClearButton: true' is shown a clear button
 in the field, and when is used there are refresh problem of the TextField when another person is chosen in the list
*/
Column {

    id: editCategoryPageLayout

    anchors.fill: parent
    spacing: units.gu(3.5)
    anchors.leftMargin: units.gu(2)

    Rectangle{
        color: "transparent"
        width: parent.width
        height: units.gu(6)
    }

    /* A PopUp that display the operation result */
    Component {
        id: subcategoryAddedInListSuccessDialogue
        OperationSuccessResult{msg:"SubCategory added in list"}
    }

    Component {
        id: saveOperationSuccessDialogue
        OperationSuccessResult{msg:"Category and SubCategory Saved"}
    }

    /* create instances of the same Object but with different messages */
    Component {
        id: categoryInvalidDialogue
        OperationFailSubCategory{msg:"Category value is invalid"}
    }

    Component {
        id: categoryDuplicatedDialogue
        OperationFailSubCategory{msg:"Category already Exist"}
    }

    Component {
        id: subCategoryInvalidDialogue
        OperationFailSubCategory{msg:"SUBCategory invalid or duplicated"}
    }

    Component {
        id: noSubCategoryFoundDialogue
        OperationFailSubCategory{msg:"No SUBCategory found in List"}
    }


    //-------- Category Name ------------
    Row{
        id: newCategoryRow
        spacing: units.gu(9.5)

        Label {
            id: newCategoryLabel
            anchors.verticalCenter: newCategoryField.verticalCenter
            text: "* "+i18n.tr("Category Name:")
        }

        TextField {
            id: newCategoryField
            text: ""
            placeholderText: ""
            echoMode: TextInput.Normal
            readOnly: false
            width: units.gu(35)
        }
      }

      Row{
            spacing: units.gu(8)

            Label {
                id: newSubCategoryLabel
                anchors.verticalCenter: newSubCategoryField.verticalCenter
                text: "* "+i18n.tr("Add Subcategory:")
            }

            TextField {
                id: newSubCategoryField
                text: ""
                placeholderText: ""
                echoMode: TextInput.Normal
                readOnly: false
                width: units.gu(35)
            }

            Button {
                id: addSubCategoryButton
                objectName: "Add"
                text: i18n.tr("Add to List")
                width: units.gu(14)
                onClicked: {

                    /* check if category is invalid or empty */
                    var isCategoryValid = Utility.checkinputText(newCategoryField.text);
                    /* check if category already exist */
                    var isCategoryDuplicated = Storage.searchCategoryByName(newCategoryField.text);
                     /* check if SUBcategory is valid */
                    var isSubCategoryValid = CategoryUtils.checkAndAddSubCategory(newSubCategoryField.text);

                    if(!isCategoryValid){
                       PopupUtils.open(categoryInvalidDialogue)

                    }else if(isCategoryDuplicated.length !== 0){
                       PopupUtils.open(categoryDuplicatedDialogue)

                    }else if(! isSubCategoryValid){
                        PopupUtils.open(subCategoryInvalidDialogue)

                    }else{
                         PopupUtils.open(subcategoryAddedInListSuccessDialogue)
                         newSubCategoryField.text = ""
                         newCategoryField.readOnly = true /* to prevent modifications */
                    }
                }
            }
     }

    /* Subcategory List selector */
    Row{
          spacing: units.gu(10)
          width: newSubCategoryField.width

          Label{
              id: curSubCategoryListLabel
              anchors.verticalCenter: subCategoryChooserButton.verticalCenter
              text: i18n.tr("Subcategory List:")
          }

          //----------- Sub Category selector PopUp --------------
          Component {
               id: popoverSubCategoryPickerComponent

               Dialog {

                   id: subCategoryPickerDialog
                   text: i18n.tr("Select the subcategory to remove")
                   title: "Subcategories: "+categoryListModelToSave.count

                   OptionSelector {
                       id: subCategoryOptionSelector
                       expanded: true
                       multiSelection: false
                       model: categoryListModelToSave
                       containerHeight: itemHeight * 4
                   }

                   Component.onCompleted: {

                       /* manage popup buttons */
                       if(categoryListModelToSave.count === 0) {
                          removeItemButton.enabled = false
                       }else{
                          removeItemButton.enabled = true
                       }
                   }

                   //-------- Command buttons ------------
                   Row{
                       id: removeSubCategoryRow
                       spacing: units.gu(2)

                       Button {
                           id: removeItemButton
                           objectName: "removeItem"
                           text: i18n.tr("Remove")
                           width: units.gu(14)
                           onClicked: {
                               CategoryUtils.removeSubCategory(subCategoryOptionSelector)

                               /* manage popup buttons */
                               if(categoryListModelToSave.count === 0) {
                                  removeItemButton.enabled = false
                               }else{
                                  removeItemButton.enabled = true
                               }

                               subCategoryPickerDialog.title = "Subcategories: "+categoryListModelToSave.count
                           }
                       }

                       Button {
                           text: i18n.tr("Close")
                           width: units.gu(14)
                           onClicked: PopupUtils.close(subCategoryPickerDialog)
                       }
                   }
               }
          }

          //--------------------

          /* new subCategories added by the user and NOT stored in the databse */
          ListModel {
             id: categoryListModelToSave
          }

          Button {
              id: subCategoryChooserButton
              text: i18n.tr( "Edit...")
              width: units.gu(20)
              onClicked: {
                  PopupUtils.open(popoverSubCategoryPickerComponent,subCategoryChooserButton)
              }
          }

          Label {
              id: fieldRequiredLabel
              anchors.verticalCenter: newSubCategoryField.verticalCenter
              text: "* "+i18n.tr("Field required")
          }
     }


     /* line separator */
     Rectangle {
          color: "grey"
          width: units.gu(100)
          anchors.horizontalCenter: parent.horizontalCenter
          height: units.gu(0.1)
     }

     Row{
        id: removeSubCategoryRow
        spacing: units.gu(2)

        /* transparent placeholder: required to place the content under the header */
        Rectangle {
            color: "transparent"
            width: editCategoryPageLayout.width/3
            height: units.gu(1)
        }

        /* Save to database the new Category and subcategory */
        Button {
            id: addButton
            objectName: "Save"
            text: i18n.tr("Save")
            width: units.gu(14)
            color: UbuntuColors.orange
            onClicked: {
                PopupUtils.open(confirmAddNewCategory)
            }
        }

        /* Clear All form */
        Button {
            id: resetAllButton
            text: i18n.tr("Reset All")
            width: units.gu(14)
            onClicked: {
                /* clean fields */
                newCategoryField.readOnly = false
                newCategoryField.text = ""
                newSubCategoryField.text = ""
                categoryListModelToSave.clear();

                Storage.getAllCategory();
            }
        }
    }

    //-------------- Confirm Insert new Categry and associated Subcategory ----------
    Component {
        id: confirmAddNewCategory

        Dialog {
            id: confirmDialogue
            title: i18n.tr("Confirmation")
            text: i18n.tr("Save Category ?")

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(confirmDialogue)
            }

            Button {
                text: i18n.tr("Save")
                onClicked: {
                    PopupUtils.close(confirmDialogue)

                    var isCategoryDuplicated = Storage.searchCategoryByName(newCategoryField.text);

                    if(isCategoryDuplicated.length !== 0){
                       PopupUtils.open(categoryDuplicatedDialogue)

                    /* at least one SubCategory should be present */
                    } else if(categoryListModelToSave.count === 0){
                        PopupUtils.open(PopupUtils.open(noSubCategoryFoundDialogue))

                    } else {
                        Storage.insertCategory(newCategoryField.text);
                        var categoryId = Storage.getLastId('category');

                        for (var i = 0; i < categoryListModelToSave.count; i++)
                        {
                           Storage.insertSubCategory(categoryId, categoryListModelToSave.get(i).sub_cat_name)
                           var lastSubCategoryId = Storage.getLastId('sub_category');
                           Storage.insertSubCategoryCurrentReport(lastSubCategoryId,0); /* init Subcategory report */
                        }

                        Storage.insertCategoryCurrentReport(categoryId,0);

                        /* clean fields */
                        newCategoryField.readOnly = false
                        newCategoryField.text = ""
                        newSubCategoryField = ""
                        categoryListModelToSave.clear();

                        Storage.getAllCategory();

                        PopupUtils.open(saveOperationSuccessDialogue)
                    }
                }
            }
        }
    }

}

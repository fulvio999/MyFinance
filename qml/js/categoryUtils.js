 /*
     Function used in teh EditCategory page to
     add a new SubCategory in the ListModel, but before checks if is valid and not already exist.
     Return true if the SubCategory is inserted successfully, false otherwise
 */
function checkAndAddSubCategory(subCategory)
{
    var subCategoryValid = true;

    if (subCategory.length <= 0) {       
        subCategoryValid = false;
    }

    /* check if the new SubCategory already exist in the SubCategory list show in the popup */
    for (var n=0; n < categoryListModelToSave.count; n++) {

        if (categoryListModelToSave.get(n).sub_cat_name.toUpperCase() === subCategory.toUpperCase()) {
            subCategoryValid = false;
            break;
        }
    }

    if(subCategoryValid){
        /* insert always in firts position: so that the user can see it */
        categoryListModelToSave.insert(0,{"sub_cat_name":subCategory})
    }

    return subCategoryValid;
}


/*
   Called when the use select a Category in the List to clean old values and initialize the ListModel with the
   subcategory associated at the chosen Category (ie: remove some old values).
*/
function initCategoryListModelToSave(categoryId){

     clearSubCategoryToSave();
     var subCat = Storage.getSubCategoryNameByCategoryId(categoryId);

     for(var i =0;i < subCat.rows.length;i++){
         categoryListModelToSave.append(subCat.rows.item(i));
         categoryListModelSaved.append(subCat.rows.item(i));
     }
}


/* DEBUG utility: print the content of the SubCategory Option selector */
function printSubCategoryList(){

    for (var n=0; n < categoryListModel.count; n++) {
        console.log("new sub-category already present"+categoryListModel.get(n).sub_cat_name);
    }
}


/* Utility that clean the ListModel containing the SubCategory to save/update */
function clearSubCategoryToSave()
{  
    categoryListModelToSave.clear();
}


/* Remove the currently selected SubCategory ONLY from the OptionSelector ListModel */
function removeSubCategory(subCategoryOptionSelector)
{
    var curIndex = subCategoryOptionSelector.selectedIndex;
    //console.log("Removing sub-category: "+ subCategoryOptionSelector.selectedIndex);
    categoryListModelToSave.remove(curIndex);

}

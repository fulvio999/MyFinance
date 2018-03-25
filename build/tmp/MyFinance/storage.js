/*
   Full Application DAO (TODO: split to dedicated DAO objects)
*/


//------------------------------------ UTILITY QUERY -----------------------------

/* Utility function that return the last inserted ID in the table whose name is in argument (ie: the last value of the PK field)
  TODO: insert, update operation already return the total affected row or last inserted id,
  so that in future this function will be deprecated
*/
function getLastId(tableName) {
    var db = getDatabase();
    var res ="";
    db.transaction(function(tx) {        
        var rs = tx.executeSql('SELECT seq FROM sqlite_sequence WHERE name=?;', [tableName]);
        res = rs.rows.item(0).seq;
    }
    );

    return res;
}

/* To manage Database Versions, SEE: http://www.gajdos.sk/ubuntuapps/qml-sqlite-upgradedb-change-db-version-using-changeversion/ */

/* See: http://doc.qt.io/qt-5/qtquick-localstorage-qmlmodule.html */
function getDatabase() {
    return LocalStorage.openDatabaseSync("MyFinanceApp_db", "1.0", "StorageDatabase", 1000000);
}



//------------------------------------ CREATE QUERY -----------------------------

    /* create the necessary tables */
    function createTables() {
    
        var db = getDatabase();
        db.transaction(
           function(tx) {
               tx.executeSql('CREATE TABLE IF NOT EXISTS configuration(id INTEGER PRIMARY KEY AUTOINCREMENT, param_name TEXT, param_value TEXT)');
               tx.executeSql('CREATE TABLE IF NOT EXISTS category(id INTEGER PRIMARY KEY AUTOINCREMENT, cat_name TEXT)');
               tx.executeSql('CREATE TABLE IF NOT EXISTS sub_category(id INTEGER PRIMARY KEY AUTOINCREMENT, id_category INT, sub_cat_name TEXT)');
               tx.executeSql('CREATE TABLE IF NOT EXISTS expense(id INTEGER PRIMARY KEY AUTOINCREMENT, id_category INT, id_subcategory INT, amount TEXT, date TEXT, note TEXT )');
               tx.executeSql('CREATE TABLE IF NOT EXISTS category_report_current(id INTEGER PRIMARY KEY AUTOINCREMENT, id_category INT, current_amount REAL)');
               tx.executeSql('CREATE TABLE IF NOT EXISTS subcategory_report_current(id INTEGER PRIMARY KEY AUTOINCREMENT, id_sub_category INT, current_amount REAL)');
    
           });
    }


    /* Delete a table whose name is in argument */
    function deleteTable(tableName) {

        var db = getDatabase();
        db.transaction(
           function(tx) {
                tx.executeSql('DELETE FROM '+tableName);
           });
    }


    /* Insert in the configuration table the key-value pair in argument */
    function insertConfigParam(param_name, param_value){

        var db = getDatabase();
        var res = "";
        db.transaction(function(tx) {
            
            var rs = tx.executeSql('INSERT INTO configuration (param_name, param_value) VALUES (?,?);', [param_name, param_value ]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }


    /* Update a configuration parameter value */
    function updateConfigParam(param_name, param_value){

        var db = getDatabase();
        var res = "";
        
        db.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE configuration SET param_value=? WHERE param_name=?;', [param_value, param_name ]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }


    /* Insert a new expense.
       Note: the date received is in the format DD-MMMM-yyyy (eg: 22 September 2016) to have a human readable format "Cross country"
       But the stored date is like: 2017-04-26. The format conversion is done in this function
    */
    function insertExpense(id_category, id_subcategory, amount, date, note ) {

        var db = getDatabase();
        var res = "";
        var fullDate = new Date (date);

        /* return a formatted date like: 2017-04-30 (yyyy-mm-dd) */
        var expenseDateFormatted = formatDateToString(fullDate);

        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO expense (id_category, id_subcategory, amount, date, note) VALUES (?,?,?,?,?);', [id_category, id_subcategory, amount, expenseDateFormatted, note ]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        
        return res;
    }


    /* Insert a new SubCategory associated at the category in argument */
    function insertSubCategory(id_category, sub_cat_name) {
        
        var db = getDatabase();
        var res = "";
        
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO sub_category (id_category, sub_cat_name) VALUES (?,?);', [id_category, sub_cat_name]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        
        return res;
    }


    /* Insert a New category with the name provide in argument */
    function insertCategory(cat_name) {
        
        var db = getDatabase();
        var res = "";
        
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO category (cat_name) VALUES (?);', [cat_name]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }


    /* Insert in the 'category_report_current' table (a table for Category related statistics) the provided expense amount */
    function insertCategoryCurrentReport(id_category, amount) {

        var db = getDatabase();
        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO category_report_current (id_category, current_amount) VALUES (?,?);', [id_category, amount]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }


    /* Insert in the 'subcategory_report_current' table (a table for SubCategory related statistics) the provided expense amount */   
    function insertSubCategoryCurrentReport(id_sub_category, amount) {

        var db = getDatabase();
        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT INTO subcategory_report_current (id_sub_category, current_amount) VALUES (?,?);', [id_sub_category, amount]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        
        return res;
    }


    /* Update an existing report value for the given Category ID in argument. (eg: the user has inserted a new expense or edited an exisitng one)
       The decimal separator for the amount is '.' and is check before call this function */
    function updateCategoryReportCurrentAmount(id_category, amount){

        var db = getDatabase();
        var oldAmount = "";

        /* get the previous amout */
        db.transaction(function(tx) {
            oldAmount = tx.executeSql('SELECT current_amount FROM category_report_current where id_category='+id_category);
           }
        );

        /* note: without javascript 'Number' function  */
        var newAmount = oldAmount.rows.item(0).current_amount + Number(amount);

        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE category_report_current SET current_amount=?  WHERE id_category=?;', [newAmount, id_category]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        
        return res;
    }


    /* Update an existing report value for the given SUBcategory ID in argument. 
       Note: the decimal separator is '.' and is check before call this function */
    function updateSubCategoryReportCurrentAmount(id_sub_category, amount){

        var db = getDatabase();
        var oldAmount = "";

        /* get the previous amout */
        db.transaction(function(tx) {
            oldAmount = tx.executeSql('SELECT current_amount FROM subcategory_report_current where id_sub_category='+id_sub_category);
           }
        );

        var newAmount = oldAmount.rows.item(0).current_amount +  Number(amount);
        //console.log("Updating 'subcategory_report_current' table, oldAmount was:"+ oldAmount.rows.item(0).current_amount +" new one is: "+newAmount)

        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE subcategory_report_current SET current_amount=?  WHERE id_sub_category=?;', [newAmount, id_sub_category]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }


    /*
       Update and already saved expense because the user have edited it
       Input date coming from the front-end are like: dd-mmmm-yyyy (eg: 23 September 2016)
    */
    function updateExpense(expenseId, id_subcategory, amount, date, note) {

        //console.log('Updating and expense, with expenseId:'+expenseId+', id_subcategory:'+id_subcategory+', with new amount: '+amount+', new date: '+date+', new note: '+note);

        var db = getDatabase();
        var res = "";                
        var fullDate = new Date (date);

        /* return a formatted date like: 2017-04-30 (yyyy-mm-dd) */
        var expenseDateFormatted = formatDateToString(fullDate);

        db.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE expense SET id_subcategory=?, amount=?, date=?, note=? WHERE id=? ;', [id_subcategory, amount, expenseDateFormatted, note, expenseId ]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
        );
        return res;
    }

    /* Load all the stored category with their current expense amount to show them in the left panel of the application: the category List */
    function getAllCategory(){

           modelListCategory.clear();
           var db = getDatabase();
        
           db.transaction(function(tx) {
             var rs = tx.executeSql('select c.id, c.cat_name, r.current_amount from category c left join category_report_current r where r.id_category = c.id');
               for(var i =0;i < rs.rows.length;i++){
                   modelListCategory.append(rs.rows.item(i));
               }
            }
          );
    }

    /* Return all the stored category Names */
    function getAllCategoryNames(){

           var db = getDatabase();
           var rs = "";
           db.transaction(function(tx) {
           rs = tx.executeSql('SELECT cat_name FROM category');

            }
          );

       return rs;
    }

    /* Return all the configuration parameters names */
    function getAllConfigParamNames(){        
        var db = getDatabase();
        var rs = "";
        db.transaction(function(tx) {
        rs = tx.executeSql('SELECT param_name FROM configuration');

            }
        );

        return rs;
    }


    /* Search for a Category whose name is like the provide text. Used in the Category search box */
    function searchCategoryByName(searchedText) {

        var db = getDatabase();
        var foundCategory = [];

        db.transaction(function(tx) {

            var rs = tx.executeSql('select c.id, c.cat_name, r.current_amount from category c left join category_report_current r where r.id_category = c.id and cat_name like ? ORDER BY cat_name DESC;',['%'+searchedText+'%']);
            for(var i =0;i < rs.rows.length;i++){
                foundCategory.push(rs.rows.item(i));
            }
        }
        );
        return foundCategory;
    }


    /* Return all the SubCategory for the given category in argument */
    function getSubCategoryByCategoryId(catedoryId){

        var db = getDatabase();
        var res = "";

        db.transaction(function(tx) {
              res = tx.executeSql('SELECT * FROM sub_category where id_category='+catedoryId);
            }
        );

        return res;
    }


     /* Return the expense amount given the expenseId */
     function getExpenseAmount(expenseId){

          var db = getDatabase();
          var res = "";

          db.transaction(function(tx) {
                res = tx.executeSql('SELECT amount FROM expense where id='+expenseId);
            }
          );

          try {
              return res.rows.item(0).amount;
          } catch (e) {
              return "undefined";
          }
    }


    /* Get the total expense amount for a given subCategoryId in argument  */
    function getExpsenseAmountForSubCategory(subCategoryId){

        var db = getDatabase();
        var res = "";

        db.transaction(function(tx) {
              res = tx.executeSql('SELECT sum(amount) as totalAmount FROM expense where id_subcategory='+subCategoryId);
          }
        );

        try {
            return res.rows.item(0).totalAmount;
        } catch (e) {
            return "undefined";
        }

    }


    /* Insert the Default data: category, subCategory, configuration. Used on first application use */
    function insertDefaultData() {

       if(settings.defaultDataAlreadyImported == false) {

          var lastCategoryId = "";
          var lastSubCategoryId = "";

           /* configuration table can be already filled if the user has deleted by hand each category  with the trash icon */
           if(getAllConfigParamNames().rows.length === 0 )
           {
              insertConfigParam('currency', 'EUR');
           }

           //--- category 1
           insertCategory('Home');
           lastCategoryId = getLastId("category");          

           insertSubCategory(lastCategoryId, "Rent")
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertSubCategory(lastCategoryId, "Light")
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertSubCategory(lastCategoryId, "Heating")
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertSubCategory(lastCategoryId, "Foods")
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertCategoryCurrentReport(lastCategoryId,0);


            //--- category 2
           insertCategory("Travel");
           lastCategoryId = getLastId("category");

           insertSubCategory(lastCategoryId, "Train");
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertSubCategory(lastCategoryId, "Plane");
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertCategoryCurrentReport(lastCategoryId,0);


           //--- category 3
           insertCategory("Fun");
           lastCategoryId = getLastId("category");

           insertSubCategory(lastCategoryId, "Pub");
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertSubCategory(lastCategoryId, "Disco");
           lastSubCategoryId = getLastId("sub_category");
           insertSubCategoryCurrentReport(lastSubCategoryId,0);

           insertCategoryCurrentReport(lastCategoryId,'0');

           return true;

       } else
           return false; //import default data already done

    }


    /* Return the SubCategory names for the catgoryId in argument */
    function getSubCategoryNameByCategoryId(id_category){

        var db = Storage.getDatabase();
        var rs = "";
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT sub_cat_name FROM sub_category WHERE id_category =?;',[id_category] );

            }
        );

        return rs;
    }


    /* Return the SubCategory id for the SubCategory whose name is in argument */
    function getSubCategoryIdByName(sub_category_name){        

        var db = Storage.getDatabase();
        var rs = "";
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT id FROM sub_category WHERE sub_cat_name =?;',[sub_category_name] );

            }
        );

        try {
            return rs.rows.item(0).id;
        } catch (e) {
            return "undefined";
        }
    }


    /* Return the categoryId whose name is in argument */
    function getCategoryIdByName(category_name){

        var db = Storage.getDatabase();
        var rs = "";
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT id FROM category WHERE cat_name =?;',[category_name] );

            }
        );

        try {
            return rs.rows.item(0).id;
        } catch (e) {
            return "undefined";
        }
    }


    /* load the set currency in the application configuration for the target year */
    function getConfigParamValue(paramName){

        //console.log("Loading param_value for param_name: "+paramName);

        var db = Storage.getDatabase();
        var rs = "";
        db.transaction(function(tx) {
             rs = tx.executeSql('SELECT param_value FROM configuration WHERE param_name =?;',[paramName] );
            }
        );

        return rs.rows.item(0).param_value;
    }


    /* delete the category with the id in argument */
    function deleteCategory(categoryId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM category WHERE id =?;',[categoryId]);
           }
        );
    }

    /* delete ALL the SubCategory associated at category with the id in argument*/
    function deleteAllSubCategoryForCategory(categoryId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM sub_category WHERE id_category =?;',[categoryId]);
           }
        );
    }

     /* delete the SubCategory with the given name and that are associated at the category with the id in argument */
    function deleteSubCategory(categoryName, categoryId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM sub_category WHERE sub_cat_name =? AND id_category=?;',[categoryName,categoryId]);
           }
        );
    }


    /*
        Delete ALL the Expenses for the category with the id in argument and all his associated subCategory.
        The deleted expense must be inside the time range provided in argument.

        Also update the report table for the SubCategory (that table are used to generate SubCategory reports.
        (input dates are like: 28-September-2017)

        return the number of Deleted rows in the expense table.
    */
    function deleteExpenseByCategoryAndTime(dateFrom, dateTo, categoryId){

        //console.log('Deleting expense from date:'+dateFrom + ' to date:'+dateTo+ ' for categoryId: '+categoryId);

        var db = getDatabase();

        var to = new Date (dateTo);
        var from = new Date (dateFrom);

        /* return a formatted date like: 2017-04-30 (yyyy-mm-dd) */
        var fullDateFrom = formatDateToString(from);
        var fullDateTo = formatDateToString(to);

        //console.log("Input formatted date, fullDateFrom: "+fullDateFrom+" fullDateTo: "+fullDateTo);

        /* Before update the expense tables, calculate the expenses amount to remove from the report tables */

        /* 1a) get the amount of expense for the category */
        var rs1 = ""
        db.transaction(function(tx) {
              /* for each subCategory calculate the amount to remove from the 'subcategory_report_current' table */
              rs1 = tx.executeSql("select id_subcategory, sum(amount) as totAmountSubCategory from expense e where id_category =? and date(e.date) <= date('"+fullDateTo+"') and date(e.date) >= date('"+fullDateFrom+"') group by  id_subcategory;",[categoryId]);
            }
        );

        /* 1b) update 'subcategory_report_current' table removing the expense amount calculated a step 1a */
        for(var i = 0; i < rs1.rows.length; i++) {
            //console.log("From 'subcategory_report_current table', must remove the amount: "+ rs1.rows.item(i).totAmountSubCategory + ", for id_subcategory:" + rs1.rows.item(i).id_subcategory);
            updateSubCategoryReportCurrentAmount(rs1.rows.item(i).id_subcategory,(-1 * rs1.rows.item(i).totAmountSubCategory));
        }

        /* 2a) get the expense amount to remove from the 'category_report_current' table that contains the expense amount for each category */
        var rs2 = ""
        db.transaction(function(tx) {
              rs2 = tx.executeSql("select sum(amount) as totAmountCategory from expense e where id_category =? and date(e.date) <= date('"+fullDateTo+"') and date(e.date) >= date('"+fullDateFrom+"');",[categoryId]);
            }
        );

        /* 2b) update 'category_report_current'  table removing the expense amount calculated a step 2a */
        for(var j = 0; j < rs2.rows.length; j++) {
            //console.log("From 'category_report_current table', must remove the amount: "+ rs2.rows.item(j).totAmountCategory + ", for categoryId:" + categoryId);
            updateCategoryReportCurrentAmount(categoryId,(-1 * rs2.rows.item(j).totAmountCategory));
        }

        /* as last step remove the expense */
        var rs = "";
        db.transaction(function(tx) {
              rs = tx.executeSql("DELETE FROM expense where date(date) <= date('"+fullDateTo+"') and date(date) >=  date('"+fullDateFrom+"') and id_category=?;",[categoryId]);
            }
        );

        return rs.rowsAffected;
    }


    /* delete ALL the expenses for a SubCategory whose id is in argument */
    function deleteAllExpenseForSubCategory(subCategoryId){

        var db = getDatabase();

        var rs = "";
        db.transaction(function(tx) {
              rs = tx.executeSql("DELETE FROM expense where id_subcategory=?;",[subCategoryId]);
            }
        );
    }


   /* delete ALL the expenses for a category whose id is in argument */
   function deleteAllExpenseForCategory(categoryId){

       var db = getDatabase();

       var rs = "";
       db.transaction(function(tx) {
             rs = tx.executeSql("DELETE FROM expense where id_category=?;",[categoryId]);
           }
       );

   }

    /* delete a Report (from table 'category_report_current') associated at category with the id in argument*/
    function deleteCategoryReport(categoryId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM category_report_current WHERE id_category =?;',[categoryId]);
           }
        );
    }


    /* delete a Report (from table 'subcategory_report_current') associated at SUBcategory whose id is in argument */
    function deleteSubCategoryReport(subCategoryId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM subcategory_report_current WHERE id_sub_category =?;',[subCategoryId]);
           }
        );
    }


    /* clean ALL teh database: expenses, category, SubCategory.
       This function is called when the user click on the 'trash' icon in the Application menu.
       NOTE: The currency value in the Configuration table is not removed due to a refresh problem/bug that happen on startup.
    */
    function cleanAllDatabase(){

         var db = getDatabase();

         db.transaction(function(tx) {
             var rs = tx.executeSql('DELETE FROM category;');
            }
         );

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM expense;');
           }
        );

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM category_report_current;');
           }
        );

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM subcategory_report_current;');
           }
        );

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM sub_category;');
           }
        );
    }


    /* Search the expense(s) for a given category inside the specified time range.
       If input param 'subCategoryNameFilter' is provided, the result is filtered by SubCategory.
       (Input dates are like: 28-September-2017 and converted in fully numeric format )
    */
    function searchExpense(dateFrom, dateTo, categoryId, subCategoryNameFilter){

        //console.log("Searching Expenses from: "+dateFrom+" to: "+dateTo+" for SubCatedory: "+subCategoryNameFilter);

        expenseModel.clear();

        var db = Storage.getDatabase();
        var rs = "";

        var to = new Date (dateTo);
        var from = new Date (dateFrom);

        /* return a formatted date like: 2017-04-30 (yyyy-mm-dd) */
        var fullDateFrom = formatDateToString(from);
        var fullDateTo = formatDateToString(to);

        //console.log("Input dates formatted are fullDateFrom: "+fullDateFrom+" Formatted fullDateTo: "+fullDateTo);

        var query;

        /* true if no subCategory filter was choosen */
        if(subCategoryNameFilter !== -1){
            var idSubCategoryFilter = getSubCategoryIdByName(subCategoryNameFilter);
            query = "select e.id, e.amount, e.date, e.note, c.cat_name, sb.sub_cat_name from expense e left join category c left join sub_category sb where date(e.date)  <= date('"+fullDateTo+"') and  date(e.date)  >=  date('"+fullDateFrom+"') and c.id = e.id_category and e.id_subcategory = sb.id and e.id_category="+categoryId+" and e.id_subcategory="+idSubCategoryFilter;

        }else{
            query = "select e.id, e.amount, e.date, e.note, c.cat_name, sb.sub_cat_name from expense e left join category c left join sub_category sb where date(e.date)  <= date('"+fullDateTo+"') and  date(e.date)  >=  date('"+fullDateFrom+"') and c.id = e.id_category and e.id_subcategory = sb.id and e.id_category="+categoryId;
        }

        //console.log('Searching expense from date: '+fullDateFrom + ' to date: '+fullDateTo+' for CategoryId: '+categoryId+' and SubCategory: '+subCategoryNameFilter);

        db.transaction(function(tx) {  
              rs = tx.executeSql(query);
           }
        );       

        /* fill the expense ListmMdel to show in the result page */
        for (var i = 0; i < rs.rows.length; i++) {
             expenseModel.append( {
                                  "id": rs.rows.item(i).id,
                                  "amount": rs.rows.item(i).amount,
                                  "date": (rs.rows.item(i).date).split('T')[0],
                                  "note": rs.rows.item(i).note,
                                  "cat_name": rs.rows.item(i).cat_name,
                                  "sub_cat_name": rs.rows.item(i).sub_cat_name,
                              });
        }

        return rs;
    }


    /* delete the expense with the id in argument */
    function deleteExpenseById(expenseId){
        var db = getDatabase();

        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM expense WHERE id =?;',[expenseId]);
           }
        );
    }


    /* utility function to format the javascript data to have double digit for day and month (default is one digit in js)
       return date like: YYYY-MM-DD
    */
    function formatDateToString(date)
    {
       var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
       var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
       var yyyy = date.getFullYear();

       return (yyyy + "-" + MM + "-" + dd);
    }


    /* Insert the new SubCategory in argument (the check for SubCategory duplicate was already made) */
    function insertNewSubCategory(subCatName,idCategory){

        insertSubCategory(idCategory, subCatName);
    }


    /*
       return true if the provided SubCatName already exist in the provided ListModel. Used to check for SubCategory duplicated
       inserted by the user in the Subcategory editing page
    */
    function subCatNameExist(subCatName,listModeltoCheck) {

        var contains = false;
        for (var i = 0; i < listModeltoCheck.count; i++)
        {
            if (listModeltoCheck.get(i).sub_cat_name.toUpperCase() === subCatName.toUpperCase()) {
                contains = true;
                break;
            }
        }
        return contains;
    }


    /* Utility method to print to the console the list of Category to be saved  after the user editing */
    function printSubCategoryListModelToSave(listModeltoPrint) {

        for (var i = 0; i < categoryListModelToSave.count; i++)
        {
           //console.log('To save List model value: '+categoryListModelToSave.get(i).sub_cat_name);
        }
    }


    /* Utility method to print to the console the list of Category currently saved in the database */
    function printSubCategoryListModelSaved(listModeltoPrint) {

        for (var i = 0; i < categoryListModelSaved.count; i++)
        {
           //console.log('Saved List model value: '+categoryListModelSaved.get(i).sub_cat_name);
        }
    }


    /* See: http://doc.qt.io/qt-5/qtquick-localstorage-qmlmodule.html */
    function getDatabase() {
        return LocalStorage.openDatabaseSync("MyFinanceApp_db", "1.0", "StorageDatabase", 1000000);
    }


/*

 Functions used to get the datasets for the Statistics charts about the SUBCATEGORY expesnes

*/



/* A) INSTANT REPORT: a graphical view of the report table 'subcategory_report_current' */

    /* return the XY dataSet to create the chart for SUB-Category INSTANT report: the expenses at the current date */
    function getChartDataInstantReport(idCategory){

        console.log("Chart Data for instant report for idCategory: "+idCategory)

        var ChartBarData = {
            labels: getXaxisSubCategoryNames(idCategory),

            datasets: [{
                    fillColor: "rgba(220,220,220,0.5)",
                    strokeColor: "rgba(220,220,220,1)",
                    data: getYaxisSubCatExpense(idCategory)
                }
            ]
        }

        return ChartBarData;
    }


    /* Y axis: get the current expense amount for the provided SubCategory */
    function getYaxisSubCatExpense(idCategory){

        //console.log("Loading Y data for SubCategory instant report for categoryId: "+idCategory);

        var db = getDatabase();
        var rs = "";
        db.transaction(function(tx) {
             rs = tx.executeSql('select r.current_amount from sub_category c left join subcategory_report_current r where r.id_sub_category = c.id and c.id_category=?;', [idCategory]);
            }
        );

        var expenses = [];
        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).current_amount);
            //console.log('current_amount: '+parseFloat(rs.rows.item(i).current_amount).toFixed(3) );
        }

        /* There is Chart library bug: chart not drawed if there is only one bar. workaround: ad a fake bar with zero value */
        if(expenses.length ===1)
           expenses.push(0);

        return expenses;
    }


    /* X axis: get the sub_category names associated at the category with the id in argument */
    function getXaxisSubCategoryNames(idCategory){

         //console.log("Loading X data for SubCategory instant chart for idCategory: "+idCategory);

         var db = getDatabase();
         var rs = "";

         db.transaction(function(tx) {
               rs = tx.executeSql('select sub_cat_name from sub_category where id_category=?;', [idCategory]);
            }
         );
         /* build the array */
         var subCategoryNames = [];
         for(var i =0;i < rs.rows.length;i++) {
             subCategoryNames.push(rs.rows.item(i).sub_cat_name);
             //console.log("sub_cat_name: "+rs.rows.item(i).sub_cat_name);
         }

         /* There is Chart library bug: chart not drawed if there is only one bar. workaround: add a fake bar with empty name */
         if(subCategoryNames.length ===1)
            subCategoryNames.push(" ");

         return subCategoryNames;
    }


    /* get the Y data for sub_category current report chart legend */
    function getLegendDataInstantReport(idCategory){

           console.log("Loading legend data for instant chart for idCategory: "+idCategory);

           instantReportTableListModel.clear();
           var db = getDatabase();
           db.transaction(function(tx) {
           var rs = tx.executeSql('select sub_cat_name, current_amount from sub_category c left join subcategory_report_current r where r.id_sub_category = c.id and c.id_category=?;', [idCategory]);

               for(var i =0;i < rs.rows.length;i++){
                  instantReportTableListModel.append({ "sub_cat_name" : rs.rows.item(i).sub_cat_name,  "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
                  //console.log("sub_cat_name:"+rs.rows.item(i).sub_cat_name+ " amount: "+rs.rows.item(i).current_amount);
               }
            }
          );
    }


/* B) LAST MONTH REPORT: SubCategory expenses situation during the last month (from 30 days ago to today) */

    /* Called by the Chart Component to get the XY dataSet to draw the chart */
    function getChartDataLastMonthReport(dateFrom,dateTo,idCategory){

            var x = getXaxisLastMonthReport(dateFrom,dateTo,idCategory);
            var y = getYaxisLastMonthReport(dateFrom,dateTo,idCategory);

            var allSubCatName = getSubCategoryNameByCategoryId(idCategory);

            for(var i =0;i < allSubCatName.length;i++) {

                /* Chart library have a bug: chart not drawed if there is only one bar. workaround: ad an empty bar for the missing subCategory
                   for example if only one category have expenses in the time range */
                if(x.indexOf(allSubCatName[i]) === -1){
                    //console.log("Missing SubCategory: "+allSubCatName[i] +" adding it with zero value");
                    x.push(allSubCatName[i]);
                    y.push(0);
                }
            }

            /* There is Chart library bug: chart not drawed if there is only one bar. workaround: ad a fake bar with empty name */
            if(x.length ===1 && y.length ===1){
               x.push(" ");
               y.push(0);
             }

            var ChartBarData = {
                labels: x,

                datasets: [{
                        fillColor: "rgba(220,220,220,0.5)",
                        strokeColor: "rgba(220,220,220,1)",
                        data: y
                    }
                ]
            }

            return ChartBarData;
    }


    /* X axis: the stored SubCategory Names*/
    function getXaxisLastMonthReport(dateFrom,dateTo,idCategory){

         //console.log("SubCategory Monthly report loading X data from: "+dateFrom+" to: "+dateTo +" for idCategory: "+idCategory);

         var db = getDatabase();
         var rs = "";

         db.transaction(function(tx) {
             /* note:the 'in' clusole is necessary to don't load the subcategory with NO expense in the range. Otherwise X and Y dataset have different size */
             rs = tx.executeSql("select sub_cat_name,id from sub_category where id_category='"+idCategory+"' and id in (select e.id_subcategory from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and id_category='"+idCategory+"' group by id_subcategory)");
            }
         );

         /* build the array */
         var subCategoryNames = [];

         for(var i =0;i < rs.rows.length;i++) {
             subCategoryNames.push(rs.rows.item(i).sub_cat_name);
             //console.log("SubCategory: "+rs.rows.item(i).sub_cat_name);
         }

         return subCategoryNames;
    }


    /* Y axis: the current expense amount for each SubCategory */
    function getYaxisLastMonthReport(dateFrom,dateTo,idCategory) {

        //console.log("SubCategory Monthly report loading Y data from: " + dateFrom+", to: "+dateTo+ " for idCategory: "+idCategory);

        var db = getDatabase();
        var rs = "";
           db.transaction(function(tx) {
               rs = tx.executeSql("select sum(amount) as totalMonthlyAmount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and id_category='"+idCategory+"' group by id_subcategory");
            }
          );

        var expenses = [];
        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).totalMonthlyAmount);
            //console.log("Found amount: "+rs.rows.item(i).totalMonthlyAmount);
        }

        return expenses;
    }

    /* get the Y data for monthly chart for the chart Legend */
    function getLegendDataForLastMonthReport(dateFrom, dateTo, idCategory){

           //console.log("SubCategory Monthly report loading Legend data, from: " + dateFrom+", to: "+dateTo+" for categoryId: "+idCategory );

           lastMonthChartListModel.clear();
           var db = getDatabase();
           db.transaction(function(tx) {

               var rs = tx.executeSql("select a.current_amount, c.sub_cat_name from (select id_subcategory, sum(amount) as current_amount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and e.id_category='"+idCategory+"' group by e.id_subcategory) a left join sub_category c where a.id_subcategory = c.id");
               for(var i =0;i < rs.rows.length;i++){
                   //lastMonthChartListModel.append(rs.rows.item(i));
                   lastMonthChartListModel.append({ "sub_cat_name" : rs.rows.item(i).sub_cat_name,  "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
                   //console.log("Found amount: "+rs.rows.item(i).current_amount + " for SubCategory: "+rs.rows.item(i).sub_cat_name);
               }
             }
          );
    }



/* C) CUSTOM RANGE REPORT: SubCategory expenses situation during a custom time range */


    /* Called by the Chart Component to get the  XY dataSet to draw the chart */
    function getChartDataCustomRangeReport(dateFrom,dateTo,idCategory){

           var x = getXaxisCustomRangeReport(dateFrom,dateTo,idCategory);
           var y = getYaxisCustomRangeReport(dateFrom,dateTo,idCategory);

            /* There is Chart library bug: chart not drawed if there is only one bar.
               for example if only one SubCategory have expenses in the time range.
               Workaround: ad an empty bar for the missing SubCategory */
           var allSubCatName = getSubCategoryNameByCategoryId(idCategory);

           for(var i =0;i < allSubCatName.length;i++) {

                 if(x.indexOf(allSubCatName[i]) === -1){
                     //console.log("Missing SubCategory: "+allSubCatName[i] +" adding it with zero value");
                     x.push(allSubCatName[i]);
                     y.push(0);
                 }
           }

           /* There is Chart library bug: chart not drawed if there is only one bar. workaround: ad a fake bar with empty name */
           if(x.length ===1 && y.length ===1){
              x.push(" ");
              y.push(0);
            }

           var ChartBarData = {
                labels: x,

                datasets: [{
                        fillColor: "rgba(220,220,220,0.5)",
                        strokeColor: "rgba(220,220,220,1)",
                        data: y
                    }
                ]
           }

           return ChartBarData;
    }


    /* X axis:the stored SubCategory names*/
    function getXaxisCustomRangeReport(dateFrom,dateTo,idCategory){

         //console.log("SubCategory custom report loading X data from: "+dateFrom+" to: "+dateTo+ " for categoryId: "+idCategory);

         var db = getDatabase();
         var rs = "";

         db.transaction(function(tx) {
             /* note:the 'in' clusole is necessary to don't load the subcategory with NO expense in the range. Otherwise X and Y dataset have different size */
             rs = tx.executeSql("select sub_cat_name,id from sub_category where id_category='"+idCategory+"' and id in (select e.id_subcategory from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and id_category='"+idCategory+"' group by id_subcategory)");

             // rs = tx.executeSql('SELECT sub_cat_name FROM sub_category where id_category=?;', [idCategory]);
            }
         );
         /* build the array */
         var categoryNames = [];

         for(var i =0;i < rs.rows.length;i++) {
             categoryNames.push(rs.rows.item(i).sub_cat_name);
             //console.log("Found SubCategory name: "+rs.rows.item(i).sub_cat_name);
         }

         return categoryNames;
    }


    /* Y axis: the expense amount for each category in the provide time range */
    function getYaxisCustomRangeReport(dateFrom,dateTo,idCategory) {

        //console.log("SubCategory Custom report, loading Y data from: "+dateFrom+" to: "+dateTo+ " and idCategory: "+idCategory);

        var db = getDatabase();
        var rs = "";
           db.transaction(function(tx) {
              rs = tx.executeSql("select sum(amount) as totalMonthlyAmount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and id_category='"+idCategory+"' group by id_subcategory");
            }
          );

        var expenses = [];

        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).totalMonthlyAmount);
            //console.log("found amount: "+rs.rows.item(i).totalMonthlyAmount);
        }

        return expenses;
    }

    /* get the Y data for custom Chart legend */
    function getLegendDataForCustomRangeReport(dateFrom, dateTo, idCategory){

           //console.log("SubCategory custom report loading legend date, from: " + dateFrom+", to: "+dateTo +" and idCategory: "+idCategory);

           customRangeChartListModel.clear();
           var db = getDatabase();
           db.transaction(function(tx) {

               var rs = tx.executeSql("select a.current_amount, c.sub_cat_name from (select id_subcategory, sum(amount) as current_amount from expense e where  date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') and id_category="+idCategory+" group by id_subcategory) a left join sub_category c where a.id_subcategory = c.id");
               for(var i =0;i < rs.rows.length;i++){
                   //customRangeChartListModel.append(rs.rows.item(i));
                   customRangeChartListModel.append({ "sub_cat_name" : rs.rows.item(i).sub_cat_name,  "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
               }
            }
          );
    }

//-----------------------------------------------------------------------------------------

    /* Utility function used in this script to get the All the SubCategory names owned
       by the Category with the given categoryId
    */
    function getSubCategoryNameByCategoryId(idCategory){

        var db = Storage.getDatabase();
        var rs = "";

        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT sub_cat_name FROM sub_category WHERE id_category =?;',[idCategory] );

            }
        );

        var names = [];
        for(var i =0;i < rs.rows.length;i++) {
            names.push(rs.rows.item(i).sub_cat_name);
        }

        return names;
    }

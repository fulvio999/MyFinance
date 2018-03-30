
    function getDatabase() {
        return LocalStorage.openDatabaseSync("MyFinanceApp_db", "1.0", "StorageDatabase", 1000000);
    }


    /* Load all the stored category Names to show them in the left panel */
    function getAllCategoryNames(){

           var db = getDatabase();
           var rs = "";
           db.transaction(function(tx) {
           rs = tx.executeSql('SELECT cat_name FROM category');

            }
          );

       return rs.rows;
    }

//----------------------------------- EXPENSES REPORTS FOR ALL THE CATEGORY ------------------------------------


/* A) INSTANT REPORT: is a graphical view of the report table 'category_report_current' */

    function getChartDataInstantReport(){

        var ChartBarData = {
            labels: getXaxisInstantReport(),

            datasets: [{
                    fillColor: "rgba(220,220,220,0.5)",
                    strokeColor: "rgba(220,220,220,1)",
                    data: getYaxisInstantReport()
                }
            ]
        }
        return ChartBarData;
    }


    /* Y axis: the current expense amount for each category */
    function getYaxisInstantReport(){

         var db = getDatabase();
         var rs = "";
           db.transaction(function(tx) {
             rs = tx.executeSql('select r.current_amount from category c left join category_report_current r where r.id_category = c.id');
            }
          );

        var expenses = [];
        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).current_amount);
        }

        return expenses;
    }


    /* X axis: all the category names
       http://askubuntu.com/questions/700852/display-column-values-from-sqlite-db
    */
    function getXaxisInstantReport(){

         var db = getDatabase();
         var rs = "";

         db.transaction(function(tx) {
                rs = tx.executeSql('SELECT cat_name FROM category');
            }
         );
         /* build the array */
         var categoryNames = [];
         for(var i =0;i < rs.rows.length;i++) {
             categoryNames.push(rs.rows.item(i).cat_name);
         }

         return categoryNames;
    }

    /* get the Y data to be shown in the chart legend */
    function getLegendDataInstantReport(){

           instantReportTableListModel.clear();

           var db = getDatabase();
           db.transaction(function(tx) {
             var rs = tx.executeSql('select cat_name, current_amount from category c left join category_report_current r where r.id_category = c.id');
               for(var i =0;i < rs.rows.length;i++){
                   //instantReportTableListModel.append(rs.rows.item(i));
                   instantReportTableListModel.append({ "cat_name" : rs.rows.item(i).cat_name,  "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
               }
            }
          );
    }



/* B) LAST MONTH REPORT: expenses situation for the last month (from 30 day ago to today) */

    /* Used by the Chart Component to get the XY dataSet */
    function getChartDataLastMonthReport(dateFrom,dateTo){

            //console.log("Loading xy data for last month Global report, from: "+dateFrom+" to: "+dateTo);

            var x = getXaxisLastMonthReport(dateFrom,dateTo);
            var y = getYaxisLastMonthReport(dateFrom,dateTo)

            /* There is Chart library bug: chart is not drawed if there is only one bar to draw. Workaround: add a fake empty bar */
            if(x.length ===1 && y.length ===1){
               x.push(" ");
               y.push(0);
             }

            var ChartBarData = {
                labels:x,

                datasets: [{
                        fillColor: "rgba(220,220,220,0.5)",
                        strokeColor: "rgba(220,220,220,1)",
                        data: y
                    }
                ]
            }

            return ChartBarData;
    }


    /* X axis: the Category names with expenses in the target time range */
    function getXaxisLastMonthReport(dateFrom,dateTo){

         var db = getDatabase();
         var rs = "";

         db.transaction(function(tx) {
             /* note:the 'in' clusole is necessary to don't load the category names with NO expense in the range. Otherwise X and Y dataset have different size */
             rs = tx.executeSql("select cat_name,id from category where id in (select e.id_category from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category)");

            }
         );
         /* build the array */
         var categoryNames = [];
         for(var i =0;i < rs.rows.length;i++) {
             categoryNames.push(rs.rows.item(i).cat_name);
         }

         return categoryNames;
    }


    /* Y axis: the expense amount for each category in the target time range */
    function getYaxisLastMonthReport(dateFrom,dateTo) {

        var db = getDatabase();
        var rs = "";
           db.transaction(function(tx) {
              rs = tx.executeSql("select sum(amount) as totalMonthlyAmount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category");
            }
          );

        var expenses = [];
        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).totalMonthlyAmount);
        }

        return expenses;
    }

    /* Y data for monthly chart legend */
    function getLegendDataForLastMonthReport(dateFrom, dateTo){

           //console.log("Global Report get data for monthly legend, from: " + dateFrom+", to: "+dateTo);

           lastMonthChartListModel.clear();
           var db = getDatabase();
           db.transaction(function(tx) {

               var rs = tx.executeSql("select a.current_amount , c.cat_name from (select id_category, sum(amount) as current_amount from expense e where  date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category) a left join category c where a.id_category = c.id");
               for(var i =0;i < rs.rows.length;i++){
                   //lastMonthChartListModel.append(rs.rows.item(i));
                   lastMonthChartListModel.append({ "cat_name" : rs.rows.item(i).cat_name, "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
               }
            }
          );
    }


/* C) CUSTOM RANGE REPORT: expenses situation during a custom time range user defined */


    /* Called by the Chart Component to get the XY dataSet */
    function getChartDataCustomRangeReport(dateFrom,dateTo){

        var x = getXaxisCustomRangeReport(dateFrom,dateTo);
        var y = getYaxisCustomRangeReport(dateFrom,dateTo);

        /* There is Chart library bug: chart not drawed if there is only one bar to draw. Workaround: add a fake empty bar */
        if(x.length ===1 && y.length ===1){
           x.push(" ");
           y.push(0);
         }

           var ChartBarData = {
                labels: x ,

                datasets: [{
                        fillColor: "rgba(220,220,220,0.5)",
                        strokeColor: "rgba(220,220,220,1)",
                        data: y
                    }
                ]
           }

           return ChartBarData;
    }


    /* X axis: the stored category Names with expenses in the provided time range*/
    function getXaxisCustomRangeReport(dateFrom,dateTo){

         var db = getDatabase();
         var rs = "";

         //console.log("Global Report loading X chart data for custom report, from: "+dateFrom+" to: "+dateTo);

         db.transaction(function(tx) {

              /* note:the 'in' clusole is necessary to don't load the category with NO expense in the range. Otherwise X and Y dataset have different size */
              rs = tx.executeSql("select cat_name,id from category where id in (select e.id_category from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category)");

            }
         );

         /* build the X values array */
         var categoryNames = [];
         for(var i =0;i < rs.rows.length;i++) {
             categoryNames.push(rs.rows.item(i).cat_name);
             //console.log('Category name: '+rs.rows.item(i).cat_name);
         }

         return categoryNames;
    }


    /* Y axis: the expense total amount for each category in the provide time range */
    function getYaxisCustomRangeReport(dateFrom,dateTo) {

        //console.log("Global Report loading Y chart data for custom report, from: "+dateFrom+" to: "+dateTo);

        var db = getDatabase();
        var rs = "";
           db.transaction(function(tx) {
              rs = tx.executeSql("select sum(amount) as totalMonthlyAmount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category");
            }
          );

        var expenses = [];
        for(var i =0;i < rs.rows.length;i++) {
            expenses.push(rs.rows.item(i).totalMonthlyAmount);
            //console.log(' Expense amount: '+rs.rows.item(i).totalMonthlyAmount);
        }

        return expenses;
    }

    /* get the Y data for monthly Chart Legend */
    function getLegendDataForCustomRangeReport(dateFrom, dateTo){

           //console.log("Global Report get Y data for custom chart Legend, from: " + dateFrom+", to: "+dateTo);

           customRangeChartListModel.clear();
           var db = getDatabase();
           db.transaction(function(tx) {

               var rs = tx.executeSql("select a.current_amount, c.cat_name from (select id_category, sum(amount) as current_amount from expense e where date(e.date) <= date('"+dateTo+"') and date(e.date) >= date('"+dateFrom+"') group by id_category) a left join category c where a.id_category = c.id");
               for(var i =0;i < rs.rows.length;i++){
                   //customRangeChartListModel.append(rs.rows.item(i));
                   customRangeChartListModel.append({ "cat_name" : rs.rows.item(i).cat_name, "current_amount": parseFloat(rs.rows.item(i).current_amount).toFixed(3)} );
               }
            }
          );
    }

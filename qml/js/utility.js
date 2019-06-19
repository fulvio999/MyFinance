
/* -------------------- Various utility functions -------------------- */

    /* utility functions to decide what value display in case of missing field value from DB */
    function getValueTodisplay(val) {

       if (val === undefined)
          return ""
       else
          return val;
    }

    /* used to check if a mandatory field is provided by the user */
    function isInputTextEmpty(fieldTxtValue)
    {
        if (fieldTxtValue.length <= 0 )
           return true
        else
           return false;
    }

    /* check if mandatory field is valid and present */
    function checkinputText(fieldTxtValue)
    {
        if (fieldTxtValue.length <= 0 || hasSpecialChar(fieldTxtValue))
           return false
        else
           return true;
    }

    /* return true if the input parametr contains comma sign */
    function containsComma(fieldTxtValue) {
        return /[,]|&#/.test(fieldTxtValue) ? true : false;
    }

    /* If regex matches, then string contains (at least) one special char. NOTE: '.' is allowed, is the decimal separators */
    function hasSpecialChar(fieldTxtValue) {
        /* dot sign is allowed because is the decimal separator */
        return /[<>?%#,;]|&#/.test(fieldTxtValue) ? true : false;
    }

    /* Show a information popup when the user open for the first time the application */
    function showOperationStatusDialog(){

         if(settings.isFirstUse){
            PopupUtils.open(operationStatusDialog)
         }
    }

    /* Depending on the Pagewidht of the Page (ie: the Device type) decide the Height of the scrollable */
    function getContentHeight(){

        if(root.width > units.gu(80))
            return manageCategoryExpensePage.height + manageCategoryExpensePage.height/2 + units.gu(20)
        else
            return manageCategoryExpensePage.height + manageCategoryExpensePage.height/2 + units.gu(10) //phone
    }

    /* Return the todayDate with UTC values set to zero */
    function getTodayDate(){

        var today = new Date();
        today.setUTCHours(0);
        today.setUTCMinutes(0);
        today.setUTCSeconds(0);
        today.setUTCMilliseconds(0);

        return today;
    }


    /* Add the provided amount of days at the input date, if amount is negative, subtract them. The returned data has
       minutse,seconds,millisecond set to zero because are not important to track them
    */
    function addDaysToDate(date, days) {
        return new Date(
            date.getFullYear(),
            date.getMonth(),
            date.getDate() + days,
            0,
            0,
            0,
            0
        );
    }


    /* Utility function to format the javascript date to have double digits for day and month (default is one digit in js)
       Example return date like: YYYY-MM-DD
       eg: 2017-04-28
    */
    function formatDateToString(date)
    {
       var dd = (date.getDate() < 10 ? '0' : '') + date.getDate();
       var MM = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
       var yyyy = date.getFullYear();

       return (yyyy + "-" + MM + "-" + dd);
    }

# trim-query
A custom variable template to return a string obtained by removing a query with a specified name from a link URL or page URL.  
It is mainly used to delete unnecessary "_ga" queries when measuring link URL and page URL events.

## Operation overview
- Deletes the query specified by "Delete query key" from the variable specified by "Target URL" and returns it.
  (If nothing is deleted, the value of the variable specified in “Target URL” will be returned as is)

## Memo
- In the Target URL field, you can specify the following three items that are especially in demand without registering variables.
  - Element URL (= Click URL, Form URL)
  - Page URL （= Page URL)
  - Page URL All （= Page URL + Fragment)
- In the Target URL field, in addition to the above three items, you can also select a specified variable.
- "Remove from what" is only "Queries" by default, but it is possible to delete from hashtags by checking "Fragment".
- The query name specified by "Delete query key" is judged by "exact match".
- If there is no part matching the query name specified in "Delete Query Key", or if "Delete Query Key" is not set, the target value specified in "Target URL" is returned as it is.
- This template was created by Ayudante, Inc. as the 1st draft.

## Editing history
### [2019/10/18 (Update)] Ayudante, Inc. 
- In order to create a community template, the language of each part has been changed from Japanese to English.

### [2019/06/21(Update)] Ayudante, Inc. 
- When saving a variable, the error message "Service error occurred" was displayed and a bug that could not be saved occurred, so the input rule for the "targetQueries" item was deleted.

### [2019/05/24 (New)] Ayudante, Inc.
https://ayudante.jp/column/2019-05-24/18-04/
- It was new registration.

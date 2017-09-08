           _____                               _       _
          / ____|                             | |     | |       
         | |     ___ _ __  ___ _   _ ___    __| | __ _| |_ __ _ 
         | |    / _ \ '_ \/ __| | | / __|  / _` |/ _` | __/ _` |
         | |___|  __/ | | \__ \ |_| \__ \ | (_| | (_| | || (_| |
          \_____\___|_| |_|___/\__,_|___/  \__,_|\__,_|\__\__,_|


## Census data display

This demo uses:

 - Chocolate.js framework (npm install chocolate)
 - Sqlite node.js module (npm install sqlite3)
 - a SQLite database that contains a table "census_learn_sql” with demographic data
 - Semantic UI framework

 
Goal of this demo is to create a small web application that visualizes database data.

Application allows to select a column (amongst demographic data), then display, for each different value in this column, number of lines with this value, and "age" value average.
Values are sorted by decreasing order. One can display only 100 first values.


Page looks like:

    |              -------------
    |    variable | education v |
    |              -------------
    |     --------------------------------------------
    |    | value                | count | average age |
    |    | Ph D                 | 1234  | 45,5        |
    |    | Less than 1st grade  | 123   | 34,4        |
    |     --------------------------------------------
    |
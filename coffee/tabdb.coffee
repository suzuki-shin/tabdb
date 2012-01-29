create_table_tables = 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)'

db = window.openDatabase "tabdb","","TABDB", 1048576

successLog = (mes) ->
    console.log '[success]'
    console.log mes
failureLog = (mes) ->
    console.log '[failure]'
    console.log mes

createTable = (sql, params = []) ->
    console.log 'createTable start'
    db.transaction (tx) ->
         tx.executeSql sql, params, successLog, failureLog

createTableTables =->
    console.log 'createTableTables start'
    createTable create_table_tables



$ ->
    $('#test').click ->
        alert 'hoge'
        createTableTables()
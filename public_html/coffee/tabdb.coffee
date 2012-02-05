create_tabdb_tables = 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)'
insert_tabdb_tables = 'INSERT INTO tabdb_tables (name) VALUES (?)'
select_tabdb_tables = 'select name from tabdb_tables'
where_name_eq = ' where name = ?'

db = window.openDatabase "tabdb","","TABDB", 1048576

successLog = (mes) ->
    console.log '[success]'
    console.log mes
failureLog = (mes) ->
    console.log '[failure]'
    console.log mes

execSql = (sql, params = [], success_callback = successLog, failure_callback = failureLog) ->
    console.log 'execSql start'
    console.log params
    db.transaction (tx) ->
         tx.executeSql sql, params, success_callback, failure_callback

createTabdbTables =->
    console.log 'createTabdbTables start'
    execSql create_tabdb_tables

# insertTabdbTables = (name) ->
#     console.log 'insertTabdbTables start'
#     execSql insert_tabdb_tables, [name]

saveIfNotExists = (name, data) ->
    console.log 'saveIfNotExists start'
    execSql select_tabdb_tables + where_name_eq,
            [name],
            (tx, res) ->
                 console.log res.rows
                 if res.rows.length > 0
                     console.log 'already exist table'
                 else
                     _insertTabdbTables name
                     _createDataTable data

    _insertTabdbTables = (name) ->
	    console.log 'insertTabdbTables start'
	    execSql insert_tabdb_tables, [name]

    _createDataTable = (data) ->
        console.log '_createDataTable'
        console.log data

# file api
selectFile = (ev) ->
    file = ev.target.files[0]
    alert file.name + ' is selected!'
#     insertTabdbTables 'jkjkj'
#     insertTabdbTables file.name

    reader = new FileReader()
    reader.readAsText(file)

    reader.onload = (ev) ->
        console.log 'readeronload'
        textData = reader.result
        alert textData
        saveIfNotExists file.name, textData

    reader.onerror = (ev) ->
        alert 'error'

$ ->
    $(document).on 'change', '#selectFile', selectFile

#     $('#test').click ->
#         alert 'hoge fuga'
#         createTabdbTables()

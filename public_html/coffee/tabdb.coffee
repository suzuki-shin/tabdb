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
    console.log sql
    console.log params
    db.transaction (tx) ->
        tx.executeSql sql, params, success_callback, failure_callback

createTabdbTables =->
    console.log 'createTabdbTables start'
    execSql create_tabdb_tables

saveIfNotExists = (name, data) ->
    console.log 'saveIfNotExists start'
    console.log data
    execSql select_tabdb_tables + where_name_eq,
            [name],
            (tx, res) ->
                 console.log res.rows
                 if res.rows.length > 0
                     console.log 'already exist table'
                 else
                     _insertTabdbTables name
                     console.log data
                     _createDataTable name, data

    _insertTabdbTables = (name) ->
        console.log '_insertTabdbTables start'
        execSql insert_tabdb_tables, [name]

    _createDataTable = (name, data) ->
        console.log '_createDataTable'
#         console.log (line.split ',' for line in data.split "\n")
        lines = data.split "\n"
        console.log lines
        execSql createTableSql(name, lines[0].split ','),
        console.log lines
        execSql insertTableSql name, lines

#     _insertDataTable = (name, data = []) ->
#         console.log '_insertDataTable start'
#         insertTableSql(name, data)


createTableSql = (name, cols = []) ->
    "CREATE TABLE IF NOT EXISTS #{name} (" + (" #{c} TEXT " for c in cols) + ")"

insertTableSql = (name, data = []) ->
    console.log 'insertTableSql'
    console.log name
    console.log data
    for d in data.splice 1
        quoted = ("'" + d_ + "'" for d_ in d.split ',')
        execSql "insert into #{name} (#{data[0]}) values (#{quoted})"

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
        console.log textData.split("\n")
        saveIfNotExists file.name, textData

    reader.onerror = (ev) ->
        alert 'error'


execSelectAndLog = (table_name) ->
    _log = (tx, res) ->
        len = res.rows.length
        console.log (res.rows.item(i) for i in [0...len])
#         console.log (res.rows.item(i).name for i in [0...len])

    execSql "select * from #{table_name}", [], _log


$ ->
    $(document).on 'change', '#selectFile', selectFile

    $('#test').click ->
        alert 'hoge fuga'
        execSelectAndLog 'tabdb_tables'
#         insertTableSql 'aaa', ["id,a,b","AAA,BBB,1","XXX,YYY,2"]
#         saveIfNotExists 'ABC', "a,b,c\nAAA,BBB,1\nXXX,YYY,2\n"
#         console.log createTableSql('aaa', ['id','a','b'])

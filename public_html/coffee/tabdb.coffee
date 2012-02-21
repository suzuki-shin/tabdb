where_name_eq = ' where name = ?'

db = window.openDatabase "tabdb","","TABDB", 1048576

# execSqlのsuccess_callbackのdefault
successLog = (mes) ->
    console.log '[success]'
    console.log mes

# execSqlのfailure_callbackのdefault
failureLog = (mes) ->
    console.log '[failure]'
    console.log mes

# executeSqlのラッパー
execSql = (tx, sql, params = [], success_callback = successLog, failure_callback = failureLog) ->
    console.log 'execSql start'
    console.log sql
    console.log params
    db.transaction (tx) ->
        tx.executeSql sql, params, success_callback, failure_callback


createTabdbTables = (tx) ->
    console.log 'createTabdbTables start'
    execSql tx, 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)'


createDataTable = (tx, name, data) ->
    console.log 'createDataTable'
#       console.log (line.split ',' for line in data.split "\n")
    console.log data
    lines = data.split "\n"
    console.log lines

    _insertDataTable = (tx, name, data = []) ->
        console.log '_insertDataTable start'
        insertData tx, name, data

    execSql tx, createTableSql(name, lines[0].split ','),
            [],
            (tx) -> _insertDataTable(tx, name, lines) # なんかこれがexecSql createTableSqlより先に実行されてるっぽい => あー、txを引継いでないからか、、、

saveIfNotExists = (tx, name, data) ->
    console.log 'saveIfNotExists start'
    console.log data

    _insertTabdbTables = (tx, name) ->
        console.log '_insertTabdbTables start'
        execSql tx, 'INSERT INTO tabdb_tables (name) VALUES (?)', [name]

    execSql tx, 'SELECT name FROM tabdb_tables' + where_name_eq,
            [name],
            (tx, res) ->
                 console.log res.rows
                 if res.rows.length > 0
                     console.log 'already exist table'
                 else
                     _insertTabdbTables tx, name
                     console.log data
                     createDataTable tx, name, data
            (tx, res) ->
                 createTabdbTables tx
                 _insertTabdbTables tx, name
                 createDataTable tx, name, data


createTableSql = (name, cols = []) ->
    "CREATE TABLE IF NOT EXISTS '" + name + "' (" + (" #{c} TEXT " for c in cols) + ")"

insertData = (tx, name, data = []) ->
    console.log 'insertData'
    console.log name
    console.log data
    for d in data.splice 1
        quoted = ("'" + d_ + "'" for d_ in d.split ',')
        execSql tx, "insert into '" + name + "' (#{data[0]}) values (#{quoted})"

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
        db.transaction (tx) -> saveIfNotExists(tx, file.name, textData)

    reader.onerror = (ev) ->
        alert 'error'


execSelectAndLog = (table_name, cols = []) ->
    _log = (tx, res) ->
        len = res.rows.length
        for i in [0...len]
            console.log (cols[j] + ': ' +  res.rows.item(i)[cols[j]] for j in [0...cols.length])

    db.transaction (tx) -> execSql(tx, "select * from #{table_name}", [], _log)


$ ->
    $(document).on 'change', '#selectFile', selectFile

    $('#test').click ->
        alert 'hoge fuga'
#         createTabdbTables()
#         execSelectAndLog 'tabdb_tables', ['name']
#         execSelectAndLog 'bbb', ['a','b','c']
#         insertData 'ABC', ["a,b,c","AAA,BBB,1","XXX,YYY,2"]
#         console.log createTableSql('ABC', ['a','b','c'])
#         db.transaction (tx) -> saveIfNotExists tx, 'ABC', "a,b,c\nAAA,BBB,1\nXXX,YYY,2\n"
        db.transaction (tx) -> createDataTable tx, 'DEF', "a,b,c\nAAAX,BXBB,1\nXUXX,YUYY,2\n"

###
# config
###
where_name_eq = ' where name = ?'

db = window.openDatabase "tabdb","","TABDB", 1048576

###
# functions
###
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
#    console.log (line.split ',' for line in data.split "\n")
  console.log data
  lines = data.split "\n"
  console.log lines

  _insertDataTable = (tx, name, data = []) ->
    console.log '_insertDataTable start'
    insertData tx, name, data

  execSql tx, createTableSql(name, lines[0].split ','),
      [],
      (tx) -> _insertDataTable(tx, name, lines)

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

  reader = new FileReader()
  reader.readAsText(file)

  reader.onload = (ev) ->
    console.log 'readeronload'
    textData = reader.result
    alert textData
    console.log textData.split("\n")
    file_name = (file.name.match /^(\w+)/)[0]
    file_name or= 'xxxxx'
    console.log file_name
    db.transaction (tx) -> saveIfNotExists(tx, file_name, textData)

  reader.onerror = (ev) ->
    alert 'error'


# select結果のtxとresを受け取り(自由変数のcolsのカラムの値を)、console.logに出力する
selectToConsoleLog = (cols) ->
  _selectToConsoleLog = (tx, res) ->
    len = res.rows.length
    for i in [0...len]
      console.log (cols[j] + ': ' +  res.rows.item(i)[cols[j]] for j in [0...cols.length])

# 指定したテーブルの中身をselectしてconsole.logに出力する
execSelectAndLog = (table_name, cols) ->
  db.transaction (tx) -> execSql(tx, "select * from #{table_name}", [], selectToConsoleLog(cols))

selectTables = (table_name, cols, jqobj, disp_func = selectToConsoleLog) ->
  db.transaction (tx) -> execSql(tx, "select * from #{table_name}", [], disp_func(cols, jqobj))

# selectした結果のtxとresを受け取ってそれをHTMLのテーブルにして追加する関数を返す
selectToTable = (cols, jqobj) ->
  _selectToTable = (tx, res) ->
    len = res.rows.length
    items = (res.rows.item(i) for i in [0...len])
    console.log items
    jqobj.empty().append '<table>'
    for it in items
      jqobj.append '<tr><th>' + c + '</th><td>' + it[c] + '</td></tr>' for c in cols
    jqobj.append '</table>'

# テーブルのカラムを取得する
# tx
# table_name : 対象テーブル名
# callback   : colsを引数にとる1引数の関数。colsを使ってしたい実処理。
getColsOf = (tx, table_name, callback = (cols) -> console.log cols) ->
  execSql tx, "SELECT sql FROM sqlite_master WHERE name = ?", [table_name],
          (tx, res) ->
            cols = (res.rows.item(0).sql.match /\((.+)\)/)[1].split ','
            callback cols
###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile

  $('#test').click ->
    alert 'hoge fuga'
    selectTables 'hoge', ['id', 'name'],  $('#test'), selectToTable
    db.transaction (tx) -> getColsOf tx, 'hoge'

#     db.transaction (tx) -> createDataTable tx, 'DEF', "a,b,c\nAAAX,BXBB,1\nXUXX,YUYY,2\n"
#         createTabdbTables()
#         execSelectAndLog 'tabdb_tables', ['name']
#         execSelectAndLog 'bbb', ['a','b','c']
#         insertData 'ABC', ["a,b,c","AAA,BBB,1","XXX,YYY,2"]
#         console.log createTableSql('ABC', ['a','b','c'])
#         db.transaction (tx) -> saveIfNotExists tx, 'ABC', "a,b,c\nAAA,BBB,1\nXXX,YYY,2\n"

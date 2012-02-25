###
# config
###
db = window.openDatabase "tabdb","","TABDB", 1048576

###
# 汎用関数
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
  tx.executeSql sql, params, success_callback, failure_callback

# CREATE TABLE文を返す(**カラムの型は全部TEXT**)
createTableSql = (name, cols = []) ->
  "CREATE TABLE IF NOT EXISTS '" + name + "' (" + (" #{c} TEXT " for c in cols) + ")"

# 0番目の要素がカラム名のカンマ区切り、それ以降がデータのカンマ区切りであるようなdataをとり、指定テーブルにインサートする
insertData = (tx, name, data = []) ->
  console.log 'insertData'
#   console.log name
#   console.log data
  for d in data.splice 1
    quoted = ("'" + d_ + "'" for d_ in d.split ',')
    execSql tx, "INSERT INTO '" + name + "' (#{data[0]}) VALUES (#{quoted})"

# select結果のtxとresを受け取り(自由変数のcolsのカラムの値を)、console.logに出力する関数を返す
selectToConsoleLog = (cols) ->
  (tx, res) ->
    len = res.rows.length
    for i in [0...len]
      console.log (cols[j] + ': ' +  res.rows.item(i)[cols[j]] for j in [0...cols.length])

# selectした結果のtxとresを受け取ってそれをHTMLのテーブルにして追加する関数を返す
# args
#   cols: カラム名のリスト
#   jqobj: HTMLテーブルのタグを追加したい対象のjQueryオブジェクト
# return
#   FUNCTION: txとresを受け取ってHTMLのテーブルを追加する関数
selectToTable = (table_name, cols, jqobj) ->
  (tx, res) ->
    len = res.rows.length
    items = (res.rows.item(i) for i in [0...len])
    console.log items
#     names = (console.log col.name for col in items[0])
#     console.log names
    jqobj.empty().append '<table class="table001"><caption>' + table_name + '</caption><tr>' + ('<th>' + c + '</th>' for c in cols).join('') + '</tr>' + ('<tr>' + ('<td>' + it[c] + '</td>' for c in cols) + '</tr>' for it in items) + '</table>'

# 指定したテーブルの中身をselectしてconsole.logに出力する
# args
#   tx:
#   table_name: 対象のテーブル名
#   cols: カラム名のリスト
execSelectAndLog = (tx, table_name) ->
  getColsOf tx, table_name,
            (cols) -> execSql tx, "SELECT * FROM #{table_name}", [], selectToConsoleLog(cols)

# 指定したテーブルの中身をselectして、funcで処理する
# args
#   tx:
#   table_name: 対象のテーブル名
#   cols:       カラム名のリスト
#   jqobj:      操作対象のjQueryオブジェクト
#   func FUNCTION: table_nameとcolsとjqueryオブジェクトを受け取りごにょごにょする2引数の関数
selectTables = (tx, table_name, jqobj, func) ->
  getColsOf tx, table_name,
            (cols) -> execSql tx, "SELECT * FROM #{table_name}", [], func(table_name, cols, jqobj)

# テーブルのカラムを取得してそれを使用してごにょごにょする
# args
#   tx
#   table_name : 対象テーブル名
#   callback   : colsを引数にとる1引数の関数。colsを使ってしたい実処理。
getColsOf = (tx, table_name, callback = (x) -> console.log x) ->
  console.log 'getColsOf'
  execSql tx, "SELECT sql FROM sqlite_master WHERE name = ?", [table_name],
          (tx, res) ->
            cols_with_type = (res.rows.item(0).sql.match /\((.+)\)/)[1].split ','
            cols = ((c.match /(\w+)\s+(.+)/)[1] for c in cols_with_type)
            callback cols

###
# tabdb用関数
###
createTabdbTables = (tx) ->
  console.log 'createTabdbTables start'
  execSql tx, 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)'


createDataTable = (tx, name, data) ->
  console.log 'createDataTable'
  lines = data.split "\n"
  execSql tx, createTableSql(name, lines[0].split ','), [],
          (tx) -> insertData tx, name, lines

saveIfNotExists = (tx, name, data) ->
  console.log 'saveIfNotExists start'
#   console.log data
  _insertTabdbTables = (tx, name) ->
    console.log '_insertTabdbTables start'
    execSql tx, 'INSERT INTO tabdb_tables (name) VALUES (?)', [name]
  execSql tx, 'SELECT name FROM tabdb_tables WHERE name = ?',
          [name],
          (tx, res) ->
#             console.log res.rows
            if res.rows.length > 0
              console.log 'already exist table'
            else
              _insertTabdbTables tx, name
#               console.log data
              createDataTable tx, name, data
          (tx, res) ->
            createTabdbTables tx
            _insertTabdbTables tx, name
            createDataTable tx, name, data


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


###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile

  $('#test').click ->
    alert 'hoge fuga'
    db.transaction (tx) ->
#      getColsOf tx, 'hoge'
      selectTables tx, 'hoge', $('#test'), selectToTable
#       execSelectAndLog tx, 'tabdb_tables'

#     db.transaction (tx) -> createDataTable tx, 'DEF', "a,b,c\nAAAX,BXBB,1\nXUXX,YUYY,2\n"
#         createTabdbTables()
#         execSelectAndLog 'tabdb_tables', ['name']
#         execSelectAndLog 'bbb', ['a','b','c']
#         insertData 'ABC', ["a,b,c","AAA,BBB,1","XXX,YYY,2"]
#         console.log createTableSql('ABC', ['a','b','c'])
#         db.transaction (tx) -> saveIfNotExists tx, 'ABC', "a,b,c\nAAA,BBB,1\nXXX,YYY,2\n"

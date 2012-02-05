(function() {
  var createTabdbTables, create_tabdb_tables, db, execSql, failureLog, insertTabdbTablesIfNotExists, insert_tabdb_tables, selectFile, select_tabdb_tables, successLog, where_name_eq;

  create_tabdb_tables = 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)';

  insert_tabdb_tables = 'INSERT INTO tabdb_tables (name) VALUES (?)';

  select_tabdb_tables = 'select name from tabdb_tables';

  where_name_eq = ' where name = ?';

  db = window.openDatabase("tabdb", "", "TABDB", 1048576);

  successLog = function(mes) {
    console.log('[success]');
    return console.log(mes);
  };

  failureLog = function(mes) {
    console.log('[failure]');
    return console.log(mes);
  };

  execSql = function(sql, params, success_callback, failure_callback) {
    if (params == null) params = [];
    if (success_callback == null) success_callback = successLog;
    if (failure_callback == null) failure_callback = failureLog;
    console.log('execSql start');
    console.log(params);
    return db.transaction(function(tx) {
      return tx.executeSql(sql, params, success_callback, failure_callback);
    });
  };

  createTabdbTables = function() {
    console.log('createTabdbTables start');
    return execSql(create_tabdb_tables);
  };

  insertTabdbTablesIfNotExists = function(name) {
    var _insertTabdbTables;
    console.log('insertTabdbTablesIfNotExists start');
    execSql(select_tabdb_tables + where_name_eq, [name], function(tx, res) {
      console.log(res.rows);
      if (res.rows.length > 0) {
        return console.log('already exist table');
      } else {
        return _insertTabdbTables(name);
      }
    });
    return _insertTabdbTables = function(name) {
      console.log('insertTabdbTables start');
      return execSql(insert_tabdb_tables, [name]);
    };
  };

  selectFile = function(ev) {
    var file, reader;
    file = ev.target.files[0];
    alert(file.name + ' is selected!');
    insertTabdbTablesIfNotExists(file.name);
    reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function(ev) {
      var textData;
      console.log('readeronload');
      textData = reader.result;
      return alert(textData);
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  $(function() {
    $(document).on('change', '#selectFile', selectFile);
    return $('#test').click(function() {
      alert('hoge fuga');
      return createTabdbTables();
    });
  });

}).call(this);

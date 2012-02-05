(function() {
  var createTabdbTables, create_tabdb_tables, db, execSql, failureLog, insert_tabdb_tables, saveIfNotExists, selectFile, select_tabdb_tables, successLog, where_name_eq;

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

  saveIfNotExists = function(name, data) {
    var _createDataTable, _insertTabdbTables;
    console.log('saveIfNotExists start');
    execSql(select_tabdb_tables + where_name_eq, [name], function(tx, res) {
      console.log(res.rows);
      if (res.rows.length > 0) {
        return console.log('already exist table');
      } else {
        _insertTabdbTables(name);
        return _createDataTable(data);
      }
    });
    _insertTabdbTables = function(name) {
      console.log('insertTabdbTables start');
      return execSql(insert_tabdb_tables, [name]);
    };
    return _createDataTable = function(data) {
      console.log('_createDataTable');
      return console.log(data);
    };
  };

  selectFile = function(ev) {
    var file, reader;
    file = ev.target.files[0];
    alert(file.name + ' is selected!');
    reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function(ev) {
      var textData;
      console.log('readeronload');
      textData = reader.result;
      alert(textData);
      return saveIfNotExists(file.name, textData);
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  $(function() {
    return $(document).on('change', '#selectFile', selectFile);
  });

}).call(this);

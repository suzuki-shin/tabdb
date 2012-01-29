(function() {
  var createTable, createTableTables, create_table_tables, db, failureLog, successLog;

  create_table_tables = 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)';

  db = window.openDatabase("tabdb", "", "TABDB", 1048576);

  successLog = function(mes) {
    console.log('[success]');
    return console.log(mes);
  };

  failureLog = function(mes) {
    console.log('[failure]');
    return console.log(mes);
  };

  createTable = function(sql, params) {
    if (params == null) params = [];
    console.log('createTable start');
    return db.transaction(function(tx) {
      return tx.executeSql(sql, params, successLog, failureLog);
    });
  };

  createTableTables = function() {
    console.log('createTableTables start');
    return createTable(create_table_tables);
  };

  $(function() {
    return $('#test').click(function() {
      alert('hoge');
      return createTableTables();
    });
  });

}).call(this);

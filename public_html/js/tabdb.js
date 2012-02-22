(function() {
  var createDataTable, createTabdbTables, createTableSql, db, execSelectAndLog, execSql, failureLog, insertData, saveIfNotExists, selectFile, successLog, where_name_eq;

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

  execSql = function(tx, sql, params, success_callback, failure_callback) {
    if (params == null) params = [];
    if (success_callback == null) success_callback = successLog;
    if (failure_callback == null) failure_callback = failureLog;
    console.log('execSql start');
    console.log(sql);
    console.log(params);
    return db.transaction(function(tx) {
      return tx.executeSql(sql, params, success_callback, failure_callback);
    });
  };

  createTabdbTables = function(tx) {
    console.log('createTabdbTables start');
    return execSql(tx, 'CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)');
  };

  createDataTable = function(tx, name, data) {
    var lines, _insertDataTable;
    console.log('createDataTable');
    console.log(data);
    lines = data.split("\n");
    console.log(lines);
    _insertDataTable = function(tx, name, data) {
      if (data == null) data = [];
      console.log('_insertDataTable start');
      return insertData(tx, name, data);
    };
    return execSql(tx, createTableSql(name, lines[0].split(',')), [], function(tx) {
      return _insertDataTable(tx, name, lines);
    });
  };

  saveIfNotExists = function(tx, name, data) {
    var _insertTabdbTables;
    console.log('saveIfNotExists start');
    console.log(data);
    _insertTabdbTables = function(tx, name) {
      console.log('_insertTabdbTables start');
      return execSql(tx, 'INSERT INTO tabdb_tables (name) VALUES (?)', [name]);
    };
    return execSql(tx, 'SELECT name FROM tabdb_tables' + where_name_eq, [name], function(tx, res) {
      console.log(res.rows);
      if (res.rows.length > 0) {
        return console.log('already exist table');
      } else {
        _insertTabdbTables(tx, name);
        console.log(data);
        return createDataTable(tx, name, data);
      }
    }, function(tx, res) {
      createTabdbTables(tx);
      _insertTabdbTables(tx, name);
      return createDataTable(tx, name, data);
    });
  };

  createTableSql = function(name, cols) {
    var c;
    if (cols == null) cols = [];
    return "CREATE TABLE IF NOT EXISTS '" + name + "' (" + ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = cols.length; _i < _len; _i++) {
        c = cols[_i];
        _results.push(" " + c + " TEXT ");
      }
      return _results;
    })()) + ")";
  };

  insertData = function(tx, name, data) {
    var d, d_, quoted, _i, _len, _ref, _results;
    if (data == null) data = [];
    console.log('insertData');
    console.log(name);
    console.log(data);
    _ref = data.splice(1);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      d = _ref[_i];
      quoted = (function() {
        var _j, _len2, _ref2, _results2;
        _ref2 = d.split(',');
        _results2 = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          d_ = _ref2[_j];
          _results2.push("'" + d_ + "'");
        }
        return _results2;
      })();
      _results.push(execSql(tx, "insert into '" + name + ("' (" + data[0] + ") values (" + quoted + ")")));
    }
    return _results;
  };

  selectFile = function(ev) {
    var file, reader;
    file = ev.target.files[0];
    alert(file.name + ' is selected!');
    reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function(ev) {
      var file_name, textData;
      console.log('readeronload');
      textData = reader.result;
      alert(textData);
      console.log(textData.split("\n"));
      file_name = (file.name.match(/^(\w+)/))[0];
      file_name || (file_name = 'xxxxx');
      console.log(file_name);
      return db.transaction(function(tx) {
        return saveIfNotExists(tx, file_name, textData);
      });
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  execSelectAndLog = function(table_name, cols) {
    var _log;
    if (cols == null) cols = [];
    _log = function(tx, res) {
      var i, j, len, _results;
      len = res.rows.length;
      _results = [];
      for (i = 0; 0 <= len ? i < len : i > len; 0 <= len ? i++ : i--) {
        _results.push(console.log((function() {
          var _ref, _results2;
          _results2 = [];
          for (j = 0, _ref = cols.length; 0 <= _ref ? j < _ref : j > _ref; 0 <= _ref ? j++ : j--) {
            _results2.push(cols[j] + ': ' + res.rows.item(i)[cols[j]]);
          }
          return _results2;
        })()));
      }
      return _results;
    };
    return db.transaction(function(tx) {
      return execSql(tx, "select * from " + table_name, [], _log);
    });
  };

  $(function() {
    $(document).on('change', '#selectFile', selectFile);
    return $('#test').click(function() {
      alert('hoge fuga');
      return db.transaction(function(tx) {
        return createDataTable(tx, 'DEF', "a,b,c\nAAAX,BXBB,1\nXUXX,YUYY,2\n");
      });
    });
  });

}).call(this);

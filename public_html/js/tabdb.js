(function() {
  var createTabdbTables, createTableSql, db, execSelectAndLog, execSql, failureLog, insertTableSql, saveIfNotExists, selectFile, successLog, where_name_eq;

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
    console.log(sql);
    console.log(params);
    return db.transaction(function(tx) {
      return tx.executeSql(sql, params, success_callback, failure_callback);
    });
  };

  createTabdbTables = function() {
    console.log('createTabdbTables start');
    return execSql('CREATE TABLE IF NOT EXISTS tabdb_tables (name TEXT)');
  };

  saveIfNotExists = function(name, data) {
    var _createDataTable, _insertTabdbTables;
    console.log('saveIfNotExists start');
    console.log(data);
    execSql('SELECT name FROM tabdb_tables' + where_name_eq, [name], function(tx, res) {
      console.log(res.rows);
      if (res.rows.length > 0) {
        return console.log('already exist table');
      } else {
        _insertTabdbTables(name);
        console.log(data);
        return _createDataTable(name, data);
      }
    }, function(tx, res) {
      createTabdbTables();
      _insertTabdbTables(name);
      return _createDataTable(name, data);
    });
    _insertTabdbTables = function(name) {
      console.log('_insertTabdbTables start');
      return execSql('INSERT INTO tabdb_tables (name) VALUES (?)', [name]);
    };
    return _createDataTable = function(name, data) {
      var lines;
      console.log('_createDataTable');
      lines = data.split("\n");
      console.log(lines);
      execSql(createTableSql(name, lines[0].split(',')), console.log(lines));
      return execSql(insertTableSql(name, lines));
    };
  };

  createTableSql = function(name, cols) {
    var c;
    if (cols == null) cols = [];
    return ("CREATE TABLE IF NOT EXISTS " + name + " (") + ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = cols.length; _i < _len; _i++) {
        c = cols[_i];
        _results.push(" " + c + " TEXT ");
      }
      return _results;
    })()) + ")";
  };

  insertTableSql = function(name, data) {
    var d, d_, quoted, _i, _len, _ref, _results;
    if (data == null) data = [];
    console.log('insertTableSql');
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
      _results.push(execSql("insert into " + name + " (" + data[0] + ") values (" + quoted + ")"));
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
      var textData;
      console.log('readeronload');
      textData = reader.result;
      alert(textData);
      console.log(textData.split("\n"));
      return saveIfNotExists(file.name, textData);
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
    return execSql("select * from " + table_name, [], _log);
  };

  $(function() {
    $(document).on('change', '#selectFile', selectFile);
    return $('#test').click(function() {
      alert('hoge fuga');
      execSelectAndLog('tabdb_tables', ['name']);
      execSelectAndLog('bbb', ['a', 'b', 'c']);
      console.log(createTableSql('ABC', ['a', 'b', 'c']));
      return saveIfNotExists('ABC', "a,b,c\nAAA,BBB,1\nXXX,YYY,2\n");
    });
  });

}).call(this);

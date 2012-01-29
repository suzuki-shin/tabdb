(function() {
  var selectFile;

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
      return alert(textData);
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  $(function() {
    return $(document).on('change', '#selectFile', selectFile);
  });

}).call(this);

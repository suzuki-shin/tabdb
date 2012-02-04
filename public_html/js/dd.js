(function() {
  var f_dragover, f_drop;

  f_dragover = function(ev) {
    console.log('f_dragover start');
    return ev.preventDefault();
  };

  f_drop = function(ev) {
    var file;
    console.log('f_drop start');
    console.log(ev);
    console.log(ev.dataTransfer);
    if (ev.dataTransfer.files.length) {
      alert('file is dragged.');
      file = ev.dataTransfer.files[0];
      console.log(file);
    } else {
      alert('notfile is dragged.');
    }
    return ev.preventDefault();
  };

  $(function() {
    $(document).on('dragover', '#box', f_dragover);
    return $(document).on('drop', '#box', f_drop);
  });

}).call(this);

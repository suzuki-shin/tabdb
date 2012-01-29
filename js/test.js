var element = document.getElementById('box');
console.log(element);

var f_dragover = function(event) {
    console.log('f_dragover');
    event.preventDefault();
};
// element.ondragover = function(event) {
//     event.preventDefault();
// };

// element.ondrop = function(event) {
var f_drop = function(event) {
    console.log('f_drop');
    if (event.dataTransfer.files.length) {
        alert('file is dragged.');

        var file = event.dataTransfer.files[0];
        console.log(file);
    } else {
        alert('notfile is dragged.');
    }

    event.preventDefault();
};


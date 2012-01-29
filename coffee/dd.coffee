f_dragover = (ev) ->
    console.log 'f_dragover start'
    ev.preventDefault()

f_drop = (ev) ->
    console.log 'f_drop start'
    console.log ev
    console.log ev.dataTransfer
    if ev.dataTransfer.files.length
        alert('file is dragged.')

        file = ev.dataTransfer.files[0]
        console.log file
    else
        alert('notfile is dragged.');

    ev.preventDefault()

$ ->
    $(document).on 'dragover', '#box', f_dragover
    $(document).on 'drop', '#box', f_drop

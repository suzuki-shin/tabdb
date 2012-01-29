selectFile = (ev) ->
    file = ev.target.files[0]
    alert file.name + ' is selected!'

    reader = new FileReader()
    reader.readAsText(file)

    reader.onload = (ev) ->
        console.log 'readeronload'
        textData = reader.result
        alert textData

    reader.onerror = (ev) ->
        alert 'error'

$ ->
    $(document).on 'change', '#selectFile', selectFile


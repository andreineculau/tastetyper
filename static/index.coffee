$ () ->
  contentSrc = ''
  $window = $ window
  $body = $ window.document.body
  $theme = $ '#theme'
  $hljsStyle = $ '#hljsStyle'
  $selectedHljsStyle = $ '#selectedHljsStyle'
  $content = $ '#content'

  metaKeyName = 'Ctrl'
  metaKeyName = 'Cmd'  if /^Mac/.test navigator.platform
  newTaste = $('#newTaste').html().replace /#{metaKeyName}/g, metaKeyName

  base = do () ->
    link = document.createElement 'a'
    link.setAttribute 'href', window.location.toString()
    "#{link.protocol}//#{link.hostname}:#{link.port}#{link.pathname}"

  getDomContent = () ->
    $content[0].innerText

  setContent = (content) ->
    if 'innerText' of $content[0]
      contentSrc = $content[0].innerText = content
    else
      content = content.replace
      contentSrc = $content[0].innerHTML = he.encode content

  wantsToEdit = (evt) ->
    metaKey = evt.ctrlKey
    metaKey = evt.metaKey  if /^Mac/.test navigator.platform
    return false  unless metaKey
    char = String.fromCharCode(evt.which).toLowerCase()
    return false  unless char is 'e'
    true

  maybeStartEditing = (evt) ->
    return true  unless wantsToEdit evt
    evt.preventDefault()
    edit contentSrc
    false

  maybeCancelEditing = (evt) ->
    return true  unless evt.which is 27
    evt.preventDefault()
    hash = window.location.hash.replace /^#/, ''
    tryLoading hash
    false

  cleanupPaste = () ->
    # erase any styling
    setContent getDomContent()

  scheduleCleanupPaste = (evt) ->
    setTimeout cleanupPaste, 100

  keepFocus = (evt) ->
    $content.focus()

  wantsToSave = (evt) ->
    metaKey = evt.ctrlKey
    metaKey = evt.metaKey  if /^Mac/.test navigator.platform
    return false  unless metaKey
    char = String.fromCharCode(evt.which).toLowerCase()
    return false  unless char is 's'
    true

  disableSave = (evt) ->
    return true  unless wantsToSave evt
    evt.preventDefault()
    false

  maybeSave = (evt) ->
    return true  unless wantsToSave evt
    evt.preventDefault()

    filename = window.location.hash.replace /^#/, ''
    if evt.shiftKey
      loop
        promptFilename = window.prompt 'Please enter a filename', filename
        return  unless promptFilename?
        filename = promptFilename.replace /[^A-Za-z0-9\-_]/, ''
        break  if filename is promptFilename
    url = "tastes/#{filename}"

    contentSrc = getDomContent().trim().replace(/\s+\n/g, '\n')
    contentSrc += '\n'  if contentSrc.length
    setContent contentSrc  if contentSrc isnt getDomContent()
    return true  unless contentSrc.length

    done = (body, status, xhr) ->
      window.location.hash = filename

    fail = () ->
      window.alert "Failed to save"
      edit()

    lock()
    $.ajax({
      method: 'PUT'
      url
      contentType: 'application/octet-stream'
      data: contentSrc
    }).done(done).fail(fail)
    false

  edit = (content = contentSrc) ->
    $content.html content
    $content.attr('contentEditable', 'true').focus()
    $content.on 'blur', keepFocus
    $body.addClass 'editing'
    $body.off 'keydown', disableSave
    $body.on 'keydown', maybeSave
    $body.on 'keydown', maybeCancelEditing

  lock = (content = contentSrc) ->
    options = {
      highlight: (code, language) ->
        return hljs.highlight(language, code).value
      gfm: true
      tables: true
      breaks: true
      langPrefix: 'hljs ' # workaround https://github.com/chjj/marked/pull/418
    }
    html = marked content, options
    html = html.replace /src=(['"])/g, 'src=$1tastes/'
    $content.html html
    $('a', $content).each (index, link) ->
      simplifiedLink = "#{link.protocol}//#{link.hostname}:#{link.port}#{link.pathname}"
      if simplifiedLink.indexOf(base) is 0
        $(this).on 'click', (evt) ->
          evt.preventDefault()
          currentUrl = window.location.hash.replace /^#/, ''
          newUrl = $(this).attr 'href'
          url = resolveUrl currentUrl, newUrl
          url = url.replace base, ''
          window.location.hash = "\##{url}"
          false
    $content.attr 'contentEditable', 'false'
    $content.off 'blur', keepFocus
    $body.removeClass 'editing'
    $body.on 'keydown', maybeStartEditing
    $body.on 'keydown', disableSave
    $body.off 'keydown', maybeSave
    $body.off 'keydown', maybeCancelEditing

  tryLoading = (url) ->
    unless url?.length
      window.location.hash = '#index.md'
      return

    done = (body, status, xhr) ->
      setContent body
      edit()
      lock()

    fail = () ->
      edit newTaste

    lock()
    $body.off 'keydown', maybeStartEditing
    $body.off 'keydown', maybeCancelEditing
    $.ajax({
      url: "tastes/#{url}"
    }).done(done).fail(fail)

  window.onpopstate = (evt) ->
    url = evt.target.location.hash.replace /^#/, ''
    tryLoading url

  $theme.on 'change', (evt) ->
    theme = this.value
    $.cookie 'theme', theme
    window.location.reload true

  localTheme = $.cookie 'theme'
  if localTheme?
    $("> option[value=\"#{localTheme}\"]", $theme).prop 'selected', 'selected'

  $hljsStyle.on 'change', (evt) ->
    hljsStyle = this.value
    href = $selectedHljsStyle.attr 'href'
    href = href.split('/').slice(0, -1).concat(["#{hljsStyle}.css"]).join '/'
    $selectedHljsStyle.attr 'href', href
    window.localStorage.setItem 'hljsStyle', hljsStyle

  localHljsStyle = window.localStorage.getItem 'hljsStyle'
  if localHljsStyle?
    $("> option[value=\"#{localHljsStyle}\"]", $hljsStyle).prop 'selected', 'selected'

  url = window.location.hash.replace /^#/, ''
  tryLoading url

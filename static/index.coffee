$ () ->
  $content = $ '#content'
  $hljsStyle = $ '#hljsStyle'
  $selectedHljsStyle = $ '#selectedHljsStyle'

  base = do () ->
    link = document.createElement 'a'
    link.setAttribute 'href', window.location.toString()
    "#{link.protocol}//#{link.hostname}:#{link.port}#{link.pathname}"

  tryLoading = (url) ->
    unless url?.length
      window.location.hash = '#README.md'
      return

    done = (body, status, xhr) ->
      options = {
        highlight: (code, language) ->
          return hljs.highlight(language, code).value
        gfm: true
        tables: true
        breaks: true
        langPrefix: 'hljs ' # workaround https://github.com/chjj/marked/pull/418
      }
      html = marked body, options
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
      $('code:not([lang])').each (index, codeBlock) ->
        $(codeBlock).addClass 'hljs'

    fail = () ->

    $.ajax({
      url: "tastes/#{url}"
    }).done(done).fail(fail)

  window.onpopstate = (evt) ->
    url = evt.target.location.hash.replace /^#/, ''
    tryLoading url

  $hljsStyle.on 'change', (evt) ->
    hljsStyle = this.value
    href = $selectedHljsStyle.attr 'href'
    href = href.split('/').slice(0, -1).concat(["#{hljsStyle}.css"]).join '/'
    $selectedHljsStyle.attr 'href', href
    window.localStorage.setItem 'hljsStyle', hljsStyle

  localHljsStyle = window.localStorage.getItem 'hljsStyle'
  if localHljsStyle?
    $("> option[value=\"#{localHljsStyle}\"]", $hljsStyle).prop('selected', 'selected').change()

  url = window.location.hash.replace /^#/, ''
  tryLoading url

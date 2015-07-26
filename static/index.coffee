$ () ->
  $content = $ '#content'
  $style = $ '#style'
  $selectedStyle = $ '#selectedStyle'

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
            url = $(this).attr 'href'
            window.location.hash = "\##{url}"
            false


    fail = () ->

    $.ajax({
      url: "tastes/#{url}"
    }).done(done).fail(fail)

  window.onpopstate = (evt) ->
    url = evt.target.location.hash.replace /^#/, ''
    tryLoading url

  $style.on 'change', (evt) ->
    style = this.value
    href = $selectedStyle.attr 'href'
    href = href.split('/').slice(0, -1).concat(["#{style}.css"]).join '/'
    $selectedStyle.attr 'href', href
    window.localStorage.setItem 'style', style

  url = window.location.hash.replace /^#/, ''
  tryLoading url

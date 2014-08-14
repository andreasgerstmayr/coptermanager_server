coptermanager = require 'coptermanager'

class CopterLauncher
  constructor: ->
    @client = null
    coptermanager.on 'create', @clientCreated
    window.onerror = @javascriptError

    @setupEditor()
    $('#launchBtn').on 'click', @launchBtnClick
    $('#emergencyBtn').on 'click', @emergencyBtnClick

  setupEditor: ->
    @editor = ace.edit('codeeditor')
    @editor.getSession().setUseWorker(false)
    @editor.setTheme('ace/theme/xcode')
    @editor.getSession().setMode('ace/mode/javascript')

  launchBtnClick: =>
    code = @editor.getSession().getValue()
    @launchCopter code

  emergencyBtnClick: =>
    unless @client
      alert 'copter not started'
    else unless @client.copterid
      alert "copter isn't flying"
    else
      uuid = @client.copterid

      $.ajax
        url: API_ENDPOINT + '/copter/' + uuid + '/emergency'
        type: 'POST'
        dataType: 'json'
        success: (data) ->
          if data.result is 'success'
            alert 'sent emergency request'
          else
            alert 'error while sending emergency request'
          return
        error: (e) ->
          alert 'error while sending emergency request'
          return

  showLaunchBtn: ->
    $('#runningBtn').fadeOut complete: ->
      $(this).addClass('hide')
      $('#launchBtn').fadeIn()

  showRunningBtn: ->
    $('#launchBtn').fadeOut complete: ->
      $('#runningBtn').hide().removeClass('hide').fadeIn()

  updateCopterList: ->
    $.get '/copter/_copterlist', (data) ->
      $('#copterlist').fadeOut complete: ->
        $('#copterlist').html(data)
        $('#copterlist').fadeIn()

  launchCopter: (code) ->
    @showRunningBtn()
    $('#consoleContainer').empty()

    unless @client
      @client = coptermanager.createRemoteClient(endpoint: API_ENDPOINT)

    fn = new Function('client', code + '; client.after(0, function() { window.copterLauncher.scriptFinished(); });')
    alert @client
    fn(@client)

  clientCreated: (client) =>
    client.on 'log', (message) ->
      $('#consoleContainer').append '<p>' + message + '</p>'
    client.on 'bind', =>
      @updateCopterList()
    client.on 'disconnect', =>
      @updateCopterList()

  scriptFinished: ->
    @showLaunchBtn()

  javascriptError: (error, file, lineno) ->
    $('#consoleContainer').append "<p class='text-danger'>JavaScript error: #{error}, lineno: #{lineno}</p>"


$(document).ready ->
  window.copterLauncher = copterLauncher = new CopterLauncher

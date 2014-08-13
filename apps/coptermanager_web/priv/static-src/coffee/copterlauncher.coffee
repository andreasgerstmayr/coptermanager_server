coptermanager = require 'coptermanager'

class CopterLauncher
  constructor: ->
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
    unless window.client
      alert 'copter not started'
    else unless window.client.copterid
      alert "copter isn't flying"
    else
      uuid = window.client.copterid

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

    unless window.client
      window.client = coptermanager.createRemoteClient(endpoint: API_ENDPOINT)

    fn = new Function(code + '; client.after(0, function() { window.copterLauncher.scriptFinished(); });')
    fn()

  clientCreated: (client) =>
    client.on 'log', (message) ->
      $('#consoleContainer').append '<p>' + message + '</p>'
    client.on 'bind', =>
      @updateCopterList()
    client.on 'disconnect', =>
      @updateCopterList()

  scriptFinished: ->
    @showLaunchBtn()

  javascriptError: (error) ->
    $('#consoleContainer').append "<p class='text-danger'>JavaScript error: " + error + "</p>"


$(document).ready ->
  window.client = null
  window.copterLauncher = copterLauncher = new CopterLauncher

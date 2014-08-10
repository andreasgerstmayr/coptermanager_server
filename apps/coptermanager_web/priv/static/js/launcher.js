window.coptermanager = {
  registerClient: function(client) {
    window.coptermanager.currentClient = client;
    client.on('log', function(message) {
      $('#consoleContainer').append("<p>" + message + "</p>");
    });
  },
  clientFinished: function() {
    window.coptermanager.currentClient = null;
    show_launch_btn();
  },
  currentClient: null
};

window.onerror = function(error) {
  $('#consoleContainer').append("<p class='text-danger'>JavaScript error: " + error + "</p>");
};

function show_launch_btn() {
  $('#runningBtn').fadeOut({complete: function() {
    $(this).addClass('hide');
    $('#launchBtn').fadeIn();
  }});
}

function show_running_btn() {
  $('#launchBtn').fadeOut({complete: function() {
    $('#runningBtn').removeClass('hide').hide().fadeIn();
  }});
}

function launch_copter(code) {
  show_running_btn();
  $('#consoleContainer').empty();

  var fn = new Function(code + "; window.coptermanager.currentClient.after(0, function() { window.coptermanager.clientFinished(); });");
  fn();
}

$(document).ready(function() {
  var editor = ace.edit("codeeditor");
  editor.getSession().setUseWorker(false);
  editor.setTheme("ace/theme/xcode");
  editor.getSession().setMode("ace/mode/javascript");

  $('#launchBtn').on('click', function() {
    var code = editor.getSession().getValue();
    launch_copter(code);
  });

  $('#emergencyBtn').on('click', function() {
    if (!window.coptermanager.currentClient) {
      alert("copter not started");
    }
    else if (!window.coptermanager.currentClient.copterid) {
      alert("copter isn't flying");
    }
    else {
      var uuid = window.coptermanager.currentClient.copterid;
      $.ajax({
        url: API_ENDPOINT + '/copter/' + uuid + '/emergency',
        type: 'POST',
        dataType: "json",
        success: function(data) {
          if (data.result === "success")
            alert('sent emergency request');
          else
            alert('error while sending emergency request');
        },
        error: function(e) {
          alert('error while sending emergency request');
        }
      });
    }
  });
});

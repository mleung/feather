
var FormHelper = {
  
  // TODO: Make this more generic, because it 
  // will be reused. 
  hideShowConfigurationTitle: function() {
    if ($('configuration_title').visible()) {
      $('configuration_title').hide();
      $('configuration_title_container').show();
    }
    else {
      $('configuration_title').show();
      $('configuration_title_container').hide();
      $('configuration_title').focus();
    }
  },
  
  configurationTitleKeyPress: function(e) {
    // Escape key press. There are probably constants for this!
    if (e.keyCode == 27) {
      this.hideShowConfigurationTitle();
    }
    // Enter key pressed.
    else if (e.keyCode == 13) {
      var url = "/admin/configurations?title=" + $F('configuration_title');
      new Ajax.Request(url, {
          asynchronous:'true', 
          evalScripts:'true',
          method:'put',
          onLoading: function() {
            FormHelper.hideShowConfigurationTitle();
            $('configuration_title_container').innerText = "Saving..."
          },
          onSuccess: function(transport) {
            var response = transport.responseText;
            alert(response)
            $('configuration_title_container').innerText = response;
            FormHelper.hideShowConfigurationTitle();
          },
          onFailure: function() { alert('Something went wrong...') },
      });
    }
  }
  
}


Event.observe(window, 'load', function() {
  Event.observe('configuration_title_container', 'click', FormHelper.hideShowConfigurationTitle);
  Event.observe('configuration_title', 'blur', FormHelper.hideShowConfigurationTitle);
  Event.observe('configuration_title', 'keypress', FormHelper.configurationTitleKeyPress.bindAsEventListener(FormHelper));
});

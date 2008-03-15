
var FormHelper = {
  /**
	* This toggles the visibility of the specified element, and alternately toggles the *_container element
	**/
  hideShow: function(name) {
    if ($(name).visible()) {
	    FormHelper.showContainer(name);
    }
    else {
	    FormHelper.hideContainer(name);
      $(name).focus();
    }
  },

  hideContainer: function(name) {
  	$(name).show();
  	$(name + '_container').hide();
  },

  showContainer: function(name) {
  	$(name).hide();
  	$(name + '_container').show();
  },

  /**
	* This processes the keypress event for the element, and makes a request to the specified url (with the element contents), for in place editing via AJAX
	**/
  keyPress: function(e, url, name) {
    // Escape key press. There are probably constants for this!
    if (e.keyCode == 27) {
      this.hideShow(name);
    }
    // Enter key pressed
    else if (e.keyCode == 13) {
	    url += $F(name);
      new Ajax.Request(url, {
          asynchronous:'true', 
          evalScripts:'true',
          method:'put',
          onLoading: function() {
            FormHelper.hideShow(name);
            $(name + '_display').innerText = "Saving..."
          },
          onFailure: function() { alert('Something went wrong...') },
      });
    }
  },

  /**
	* This sets up the events for the given element, to allow in place editing and saving to the specified url
	**/
  inPlaceEditEvents: function(name, url) {
  	Event.observe(name + '_container', 'click', function() { FormHelper.hideShow(name) });
  	Event.observe(name, 'blur', function() { FormHelper.showContainer(name) });
  	Event.observe(name, 'keypress', FormHelper.keyPress.bindAsEventListener(FormHelper, url, name));
  }
}

Event.observe(window, 'load', function() {
	//Set up the events for the configuration page
	FormHelper.inPlaceEditEvents("configuration_title", "/admin/configurations?title=");
	FormHelper.inPlaceEditEvents("configuration_tag_line", "/admin/configurations?tag_line=");
	FormHelper.inPlaceEditEvents("configuration_about", "/admin/configurations?about=");
});

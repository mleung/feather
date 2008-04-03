
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
  	$(name + '-container').hide();
  },

  showContainer: function(name) {
  	$(name).hide();
  	$(name + '-container').show();
  },

  /**
	* This processes the keypress event for an element, and makes a request to the specified url (with the element contents), for in place editing via AJAX
	**/
  keyPress: function(e, url, name) {
    // Escape key press. There are probably constants for this!
    if (e.keyCode == 27) {
      this.hideShow(name);
    }
    // Enter key pressed (and shift key not held down)
    else if (e.keyCode == 13 && this.keys.indexOf(16) == -1) {
	  url += escape($F(name));
      new Ajax.Request(url, {
          asynchronous:'true', 
          evalScripts:'true',
          method:'put',
          onLoading: function() {
            FormHelper.hideShow(name);
            $(name + '-display').innerText = "Saving..."
          },
          onFailure: function() { alert('Something went wrong...') },
      });
	  this.keys = [];
    }
  },

  /**
	* This processes the key down event for an element, adding the key to an array that keeps track of keys held down
	**/
  keyDown: function(e) {
  	if (this.keys == null) {
  		this.keys = [];
  	}
  	if (e.keyCode != null && this.keys.indexOf(e.keyCode) == -1) {
  		this.keys[this.keys.length] = e.keyCode;
  	}
  },

  /**
	* This processes the key up event for the element, removing the key from the array that keeps track of keys held down
	*/
  keyUp: function(e) {
  	if (this.keys != null && e.keyCode != null && this.keys.indexOf(e.keyCode) != -1) {
  		this.keys.splice(this.keys.indexOf(e.keyCode), 1);
  	}
  },

  /**
	* This sets up the events for the given element, to allow in place editing and saving to the specified url, as well as multi-line (shift+enter) support
	**/
  inPlaceEditEvents: function(name, url, multiline) {
  	Event.observe(name + '-container', 'click', function() { FormHelper.hideShow(name) });
  	Event.observe(name, 'blur', function() { FormHelper.showContainer(name) });
  	Event.observe(name, 'keypress', FormHelper.keyPress.bindAsEventListener(FormHelper, url, name));
	  if (multiline) {
	  	Event.observe(name, 'keydown', FormHelper.keyDown.bindAsEventListener(FormHelper));
	  	Event.observe(name, 'keyup', FormHelper.keyUp.bindAsEventListener(FormHelper));
	  }
  }
}

Event.observe(window, 'load', function() {
	//Set up the events for the configuration page
	FormHelper.inPlaceEditEvents("configuration-title", "/admin/configurations?title=");
	FormHelper.inPlaceEditEvents("configuration-tag-line", "/admin/configurations?tag_line=");
	FormHelper.inPlaceEditEvents("configuration-about", "/admin/configurations?about=", true);
});

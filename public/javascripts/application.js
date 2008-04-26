var ArticleHelper = {

  /**
 	* This function will auto-resize a text area instead of showing scroll bars
	**/
  resizeTextArea:  function(elem) {
    a = elem.value.split('\n');
    b = 1;
    
    for (i = 0; i < a.length; i++) {
      if (a[i].length >= elem.cols) {
        b += Math.floor(a[i].length / elem.cols); 
      }
    }
    
    b += a.length;
    
    if (b > elem.rows) {
      elem.rows = b + 5;
    }
  }  
  
}

Event.observe(window, 'load', function() {
  Event.observe('article_content', 'keypress', function() { ArticleHelper.resizeTextArea($('article_content')) });
});
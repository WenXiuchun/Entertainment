'use strict';

jQuery(function($) {

	
	//
	// copy API title to the title of the HTML document
	//

	function apiTitleHandler() {
		var apiTitle = $(this).text();
		if(apiTitle)
		{
			if(document.title)
			{
				document.title = apiTitle + ' - ' + document.title;
			}
			else
			{
				document.title = apiTitle;
			}
		}
	};

	$('body').one('DOMSubtreeModified', 'main h1.raml-console-title', apiTitleHandler);

	// invoke handler function right away, in case the API title was loaded before the above handler was attached
	($.proxy(apiTitleHandler, $('body main h1.raml-console-title').get(0)))();

})

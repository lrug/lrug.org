function hasWordInElement(word, element) {       
    if(element.nodeType == Node.TEXT_NODE)                   
        return element.nodeValue.match(word) != null;
    else 
        return $A(element.childNodes).any(
            function (child) { 
                return hasWordInElement(word, child); 
            });
}
var searchingOn = ""
function observeTagSearch(element, value) {
	if(value.length < 3 && searchingOn != "")
	{
		searchingOn = "";
		divs = $$("div.tag-description");
		$A(divs).each(function(div){ Element.show(div); });
	}
	else if(value.length >= 3 && searchingOn != value)
	{
		searchingOn = value
    	divs = $$("div.tag-description");
		$A(divs).each(function (div){
			if(hasWordInElement(value, div))
				Element.show(div);						
			else
				Element.hide(div);
		});
	}
}


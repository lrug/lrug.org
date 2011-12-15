var TabControl = Class.create();

TabControl.controls = $H();
TabControl.BadTabError = new Error('TabControl: Invalid tab.');

TabControl.prototype = {
  /*
    Initializes a tab control. The variable +element_id+ must be the id of an HTML element
    containing one element with it's class name set to 'tabs' and another element with it's
    class name set to 'pages'.
  */
  initialize: function(element_id) {
    TabControl.controls[element_id] = this;
    this.control_id = element_id;
    this.element = $(element_id);
    this.tab_container = document.getElementsByClassName('tabs', this.element).first();
    this.tabs = $H();
  },
  
  /*
    Creates a new tab. The variable +tab_id+ is a unique string used to identify the tab
    when calling other methods. The variable +caption+ is a string containing the caption
    of the tab. The variable +page+ is the ID of an HTML element, or the HTML element
    itself. When a tab is initially added the page element is hidden.
  */
  addTab: function(tab_id, caption, page) {
    new Insertion.Bottom(
      this.tab_container,
      '<a class="tab" href="javascript:TabControl.controls[\''
      + this.control_id
      + '\'].select(\'' + tab_id + '\');">' + caption + '</a>'
    );
    var tab = this.tab_container.lastChild;
    tab.tab_id = tab_id;
    tab.caption = caption;
    tab.page = $(page);
    this.tabs[tab_id] = tab;
    this._setNotHere(tab);
    return tab;
  },
  
  /*
    Removes +tab+. The variable +tab+ may be either a tab ID or a tab element.
  */
  removeTab: function(tab) {
    var t = this._tabify(tab);
    var id = t.tab_id;
    Element.remove(t.page);
    Element.remove(t);
    new_tabs = $H();
    this.tabs.each(function(pair) {
      if (pair.key != id) new_tabs[pair.key] = pair.value;
    });
    this.tabs = new_tabs;
    if (this.selected.tab_id == id) {
      var first = this.firstTab();
      if (typeof first != 'undefined') this.select(first.tab_id);
    }
  },

  /*
    Selects +tab+ updating the control. The variable +tab+ may be either a tab ID or a
    tab element.
  */
  select: function(tab) {
    var t = this._tabify(tab);
    this.tabs.each(function(pair) {
      if (pair.key == t.tab_id) {
        if (this.selected) this.selected.selected = false;
        this.selected = t;
        t.selected = true;
        this._setHere(pair.key);
      } else {
        this._setNotHere(pair.key);
      }
    }.bind(this));
    false;
  },

  /*
    Returns the first tab element that was added using #addTab().
  */
  firstTab: function() {
    return this.tabs[this.tabs.keys().first()];
  },
  
  /*
    Returns the the last tab element that was added using #addTab().
  */
  lastTab: function() {
    return this.tabs[this.tabs.keys().last()];
  },
  
  /*
    Returns the total number of tab elements managed by the control.
  */
  tabCount: function() {
    return this.tabs.keys().length;
  },
  
  /*
    Private Methods
  */
  
  /*
    Shows the page for +tab+ and adds the class 'here' to tab. The variable +tab+ may
    be either a tab ID or a tab element.
  */
  _setHere: function(tab) {
    var t = this._tabify(tab);
    Element.show(t.page);
    Element.addClassName(t, 'here');
  },
  
  /*
    Hides the page for +tab+ and removes the class 'here' from tab. The variable +tab+
    may be either a tab ID or a tab element.
  */
  _setNotHere: function(tab) {
    var t = this._tabify(tab);
    Element.hide(t.page);
    Element.removeClassName(t, 'here');
  },

  /*
    Returns a tab when passed a string or tab element. Throws a BadTabError otherwise.
  */
  _tabify: function(something) {
    if (typeof something == 'string') {
      var object = this.tabs[something];
    } else {
      var object = something;
    }
    if ((typeof object != 'undefined') && (object.tab_id)) {
      return object;
    } else {
      throw TabControl.BadTabError;
    }
  }
};
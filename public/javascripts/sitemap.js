var SiteMap = Class.create();
SiteMap.prototype = Object.extend({}, RuledTable.prototype); // Inherit from RuledTable

Object.extend(SiteMap.prototype, {

  ruledTableInitialize: RuledTable.prototype.initialize,
  
  initialize: function(id, expanded) {
    this.ruledTableInitialize(id);
    this.expandedRows = expanded
  },
  
  onRowSetup: function(row) {
    Event.observe(row, 'click', this.onMouseClickRow.bindAsEventListener(this), false);
  },
  
  onMouseClickRow: function(event) {
    var element = Event.element(event);
    if (this.isExpander(element)) {
      var row = Event.findElement(event, 'tr');
      if (this.hasChildren(row)) {
        this.toggleBranch(row, element);
      }
    }
  },
  
  hasChildren: function(row) {
    return ! /\bno-children\b/.test(row.className);
  },
  
  isExpander: function(element) {
    return (element.tagName.strip().downcase() == 'img') && /\bexpander\b/i.test(element.className);
  },
  
  isExpanded: function(row) {
    return /\bchildren-visible\b/i.test(row.className);
  },
  
  isRow: function(element) {
    return element.tagName && (element.tagName.strip().downcase() == 'tr');
  },
  
  extractLevel: function(row) {
    if (/level-(\d+)/i.test(row.className))
      return RegExp.$1.toInteger();
  },
  
  extractPageId: function(row) {
    if (/page-(\d+)/i.test(row.id))
      return RegExp.$1.toInteger();
  },
  
  getExpanderImageForRow: function(row) {
    var images = $A(row.getElementsByTagName('img', row));
    var expanders = [];
    images.each(function(image){
      expanders.push(image);
    }.bind(this));
    return expanders.first();
  },     
  
  saveExpandedCookie: function() {
    document.cookie = "expanded_rows=" + this.expandedRows.uniq().join(",") + "; path=/admin";
  }, 
  
  hideBranch: function(row, img) {
    var level = this.extractLevel(row);
    var sibling = row.nextSibling;
    while(sibling != null) {
      if (this.isRow(sibling)) {
        if (this.extractLevel(sibling) <= level) break;
        Element.hide(sibling);
      }
      sibling = sibling.nextSibling;
    }
    var pageId = this.extractPageId(row);
    var newExpanded = [];
    for(i = 0; i < this.expandedRows.length; i++)
      if(this.expandedRows[i] != pageId)
        newExpanded.push(this.expandedRows[i]);
    this.expandedRows = newExpanded;
    this.saveExpandedCookie();
    if (img == null)
      img = this.getExpanderImageForRow(row);
    img.src = img.src.replace(/collapse/, 'expand');
    Element.removeClassName(row, 'children-visible');
    Element.addClassName(row, 'children-hidden');
  },
  
  showBranchInternal: function(row, img) {
    var level = this.extractLevel(row);
    var sibling = row.nextSibling;
    var children = false;
    var childOwningSiblings = [];        
    while(sibling != null) {
      if (this.isRow(sibling)) {
        var siblingLevel = this.extractLevel(sibling);
        if (siblingLevel <= level) break;
        if (siblingLevel == level + 1) {
          Element.show(sibling);
          if(sibling.className.match(/children-visible/)) {
            childOwningSiblings.push(sibling);
          } else {
            this.hideBranch(sibling);
          }
        }
        children = true;
      }
      sibling = sibling.nextSibling;
    }
    if (!children)
      this.getBranch(row);
    if (img == null)
      img = this.getExpanderImageForRow(row);          
    img.src = img.src.replace(/expand/, 'collapse');
    for(i=0; i < childOwningSiblings.length; i++) {
        this.showBranch(childOwningSiblings[i], null);            
    }        
    Element.removeClassName(row, 'children-hidden');
    Element.addClassName(row, 'children-visible');
  },
  
  showBranch: function(row, img) {
    this.showBranchInternal(row, img);
    this.expandedRows.push(this.extractPageId(row));
    this.saveExpandedCookie();
  },
  
  getBranch: function(row) {
    var level = this.extractLevel(row).toString();
    var id = this.extractPageId(row).toString();
    new Ajax.Updater(
      row,
      '/admin/ui/pages/children/' + id + '/' + level,
      {
        asynchronous: true,
        insertion: Insertion.After,
        onLoading: function(request) {
          Element.show('busy-' + id);
          this.updating = true;
        }.bind(this),
        onComplete: function(request) {
          var sibling = row.nextSibling;
          while (sibling != null) {
            if (this.isRow(sibling)) {
              var siblingLevel = this.extractLevel(sibling);
              if (siblingLevel <= level) break;
              this.setupRow(sibling);
            }
            sibling = sibling.nextSibling;
          }
          this.updating = false;
          Effect.Fade('busy-' + id);
        }.bind(this)
      }
    );
  },
  
  toggleBranch: function(row, img) {
    if (! this.updating) {
      if (this.isExpanded(row)) {
        this.hideBranch(row, img);
      } else {
        this.showBranch(row, img);
      }
    }
  }

});

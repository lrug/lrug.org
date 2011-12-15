var RuledTable = Class.create();
RuledTable.prototype = {
  
  initialize: function(element_id) {
    var table = $(element_id);
    var rows = table.getElementsByTagName('tr');
    for (var i = 0; i < rows.length; i++) {
      this.setupRow(rows[i]);
    }
  },
  
  onMouseOverRow: function(event) {
    // Element.addClassName(this, 'highlight');
    this.className = this.className.replace(/\s*\bhighlight\b|$/, ' highlight'); // faster than the above
  },
  
  onMouseOutRow: function(event) {
    // Element.removeClassName(this, 'highlight');
    this.className = this.className.replace(/\s*\bhighlight\b\s*/, ' '); // faster than the above
  },
  
  setupRow: function(row) {
    Event.observe(row, 'mouseover', this.onMouseOverRow.bindAsEventListener(row));
    Event.observe(row, 'mouseout', this.onMouseOutRow.bindAsEventListener(row));
    if (this.onRowSetup) this.onRowSetup(row);
  }
  
};
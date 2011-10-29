(function() {
  var TodoData, TodoWidget, load_template, log, set_screen;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(function() {
    var todo_widget;
    todo_widget = new TodoWidget;
    return todo_widget.init();
  });
  TodoWidget = (function() {
    function TodoWidget() {}
    TodoWidget.prototype.init = function() {
      this.data = new TodoData;
      this.template = load_template("todo_widget");
      this.item_template = load_template("todo_item");
      this.render();
      this.init_item_actions();
      return this.init_form();
    };
    TodoWidget.prototype.delete_item = function(label_item) {
      var index, item;
      item = $($(label_item).closest('li'));
      index = $('#items li').index(item);
      this.data.delete_item(index);
      return $(item).remove();
    };
    TodoWidget.prototype.init_item_actions = function() {
      this.timeout_delete = 0;
      this.timeout_strike = 0;
      return $("#items li label").live("mousedown", __bind(function(event) {
        this.timeout_strike = setTimeout(__bind(function() {
          return $(event.target).addClass("deleting");
        }, this), 500);
        return this.timeout_delete = setTimeout(__bind(function() {
          return this.delete_item(event.target);
        }, this), 1000);
      }, this)).live('mouseup', __bind(function(event) {
        clearTimeout(this.timeout_delete);
        clearTimeout(this.timeout_strike);
        return $(event.target).removeClass("deleting");
      }, this));
    };
    TodoWidget.prototype.init_form = function() {
      this.add_item_submit = $("#add_item_submit");
      this.add_item_text = $("#add_item_text");
      this.add_item_form = $("#add_item_form");
      return this.add_item_form.submit(__bind(function(e) {
        e.preventDefault();
        this.add_item(this.add_item_text.val());
        this.reset_form();
        return false;
      }, this));
    };
    TodoWidget.prototype.render = function() {
      return set_screen(this.template(this.data.load()));
    };
    TodoWidget.prototype.reset_form = function() {
      this.add_item_text.val('');
      return this.add_item_text.focus();
    };
    TodoWidget.prototype.add_item = function(text) {
      var item;
      item = this.data.add_item(text);
      return $("#items").append(this.item_template({
        item: item
      }));
    };
    return TodoWidget;
  })();
  TodoData = (function() {
    function TodoData() {}
    TodoData.prototype.load = function() {
      this.data = JSON.parse(localStorage.getItem("todo"));
      if (!this.data) {
        this.data = [
          {
            text: "Hold me to delete"
          }
        ];
      }
      return {
        items: this.data
      };
    };
    TodoData.prototype.add_item = function(text) {
      var item;
      item = {
        text: text
      };
      this.data.push(item);
      this.store();
      return item;
    };
    TodoData.prototype.delete_item = function(index) {
      this.data.splice(index, 1);
      return this.store();
    };
    TodoData.prototype.store = function() {
      return localStorage.setItem("todo", JSON.stringify(this.data));
    };
    return TodoData;
  })();
  load_template = function(name) {
    return _.template($("#" + name).html());
  };
  set_screen = function(html) {
    return $("#screen").html(html);
  };
  log = function(message) {
    return console.log(message);
  };
}).call(this);

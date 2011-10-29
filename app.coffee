$ ->
  todo_widget = new TodoWidget
  todo_widget.init()

class TodoWidget
  init: ->
    @data = new TodoData
    @template = load_template("todo_widget")
    @item_template = load_template("todo_item")

    @render()

    @init_item_actions()
    @init_form()

  delete_item: (label_item) ->
    item = $($(label_item).closest('li'))
    index = $('#items li').index(item)
    @data.delete_item(index);
    $(item).remove()

  init_item_actions: ->
    @timeout_delete = 0
    @timeout_strike = 0 
    $("#items li").disableSelection()
    $("#items li label").live("mousedown", @item_down)
      .live("mouseup", @item_up)
      .live("touchstart", @item_down)
      .live("touchend", @item_up)


  item_down: (event) =>
    # We notify the user that they are deleting
    @timeout_strike = setTimeout => 
      $(event.target).addClass("deleting")
    , 500
    # We are deleting the item, after one secound
    @timeout_delete = setTimeout => 
      @delete_item(event.target)
    , 1000

  item_up: (event) ->
    clearTimeout(@timeout_delete)
    clearTimeout(@timeout_strike)
    $(event.target).removeClass("deleting")

  init_form: ->
    @add_item_submit = $("#add_item_submit")
    @add_item_text = $("#add_item_text")
    @add_item_form = $("#add_item_form")
    # We add a item, when the form is submitted
    @add_item_form.submit (e) =>
      e.preventDefault()
      @add_item @add_item_text.val()
      @reset_form()
      false

  render: ->
    set_screen(@template(@data.load()))

  reset_form: ->
    @add_item_text.val('')
    @add_item_text.focus()

  add_item: (text) ->
    item = @data.add_item(text)
    $("#items").append(@item_template({item: item}))
    $("#items li").disableSelection()

class TodoData
  load: ->
    @local_data = localStorage.getItem("todo");
    @data = JSON.parse(@local_data) if @local_data;
    @data = [{text: "Hold me to delete"}] unless @data
    items: @data
  add_item: (text)->
    item = {text: text}
    @data.push(item)
    @store()
    item
  delete_item: (index) ->
    @data.splice(index,1); 
    @store()
  store: ->
    localStorage.setItem("todo",JSON.stringify(@data))

# Utility functions
load_template = (name) ->
  _.template($("##{name}").html())

set_screen = (html) ->
  $("#screen").html(html)    

log = (message) ->
  console.log message

$.fn.extend {
  disableSelection: ->
    $(this).each ->
      $(this).onselectstart = ->
        return false

      this.unselectable = "on";
      $(this).css '-moz-user-select', 'none'
      $(this).css '-webkit-user-select', 'none'
}

#Tudoo version 1  
#- A simple todo application made in Coffeescript  
#- Works on Safari, Chrome, Firefox and in iOS and newer Andriod systems

$ ->
  # We create a new TodoWidget, and Initialize it
  todo_widget = new TodoWidget
  todo_widget.init()

# The TodoWidget is the class that controls the whole todo app
class TodoWidget
  # The init function handles the loading of the application.
  # It asks the TodoData class to load the data from localstorage, 
  # and reads and render the templates from the index.html page.
  init: ->
    @data = new TodoData # we create a new data object
    @template = load_template("todo_widget") # we read the main template
    @item_template = load_template("todo_item") # we read the item template

    # we ask the render method to render our application
    @render() 

    @init_item_actions()
    @init_form()

  # This method deleted a item, and removes it form the data
  delete_item: (label_item) ->
    item = $($(label_item).closest('li'))
    index = $('#items li').index(item) # we get the index of the item in the list
    @data.delete_item(index); # we ask the data to delete the item
    $(item).remove() # we remove the item from the UI

  # This method binds the actions we can do with the item
  init_item_actions: ->
    # We create some variables to hold the item deletion timeouts
    @timeout_delete = 0
    @timeout_strike = 0 
    $("#items li").disableSelection()
    # We register the events we can do on the label. This registers both the
    # mouse events and the touch events
    $("#items li label").live("mousedown", @item_down)
      .live("mouseup", @item_up)
      .live("touchstart", @item_down)
      .live("touchend", @item_up)

  # This method is fired, when we press down on an item
  item_down: (event) =>
    # We notify the user that they are deleting
    @timeout_strike = setTimeout => 
      $(event.target).addClass("deleting")
    , 500
    # We are deleting the item, after one secound
    @timeout_delete = setTimeout => 
      @delete_item(event.target)
    , 1000
    false

  # This method is fired when we release our hold on an item
  item_up: (event) ->
    clearTimeout(@timeout_delete)
    clearTimeout(@timeout_strike)
    $(event.target).removeClass("deleting")
    false
  
  #This method binds our actions to our new item form
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

  # This method adds a new item to the data, and to the UI
  add_item: (text) ->
    item = @data.add_item(text)
    $("#items").append(@item_template({item: item}))
    $("#items li").disableSelection()

class TodoData
  # On load, we will read from localStorage. If no data is found, we will
  # create some simple sample data
  load: ->
    @local_data = localStorage.getItem("todo");
    @data = JSON.parse(@local_data) if @local_data;
    @data = [{text: "Hold me to delete"}] unless @data
    items: @data
  
  # We add a item to the array, and store it in localStorage
  add_item: (text)->
    item = {text: text}
    @data.push(item)
    @store()
    item
  delete_item: (index) ->
    @data.splice(index,1); 
    @store()
  
  # We store the array in localStorage. We call JSON.stringify to be able to 
  # store complex objects in localstorage.
  store: ->
    localStorage.setItem("todo",JSON.stringify(@data))

# Utility functions
load_template = (name) ->
  _.template($("##{name}").html())

set_screen = (html) ->
  $("#screen").html(html)    

log = (message) ->
  console.log message

# We use this method to disable selections on mobile devises,
# so we can use the delete action on a long hold
$.fn.extend {
  disableSelection: ->
    this.each ->
      this.onselectstart = ->
        return false

      this.unselectable = "on";
      $(this).css '-moz-user-select', 'none'
      $(this).css '-webkit-user-select', 'none'
}

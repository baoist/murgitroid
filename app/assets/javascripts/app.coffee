# Loader for background images.
class Loader
  constructor: (directory, fallback) ->
    @directory = directory
    @fallback = fallback[0]

    @loaded = [@fallback]
    @files = @retrieve()
    @load_images()

  retrieve: ->
    # when porting to rails, create a method that returns a list of files:
    #$.get('/retrieve/' + @directory)
    if @directory == "maps"
      return ["images/maps/map-2.jpg", "images/maps/map-3.jpg", "images/maps/map-3.jpg", "images/maps/map-4.jpg", "images/maps/map-5.jpg", "images/maps/map-6.jpg", "images/maps/map-7.jpg"]
    else
      return ["images/assoc/people-2.png", "images/assoc/people-3.png", "images/assoc/people-4.png", "images/assoc/people-5.png", "images/assoc/people-6.png", "images/assoc/people-7.png"]

  load_images: ->
    @load(item) for item in @files

  load: (location) ->
    self = @
    img = new Image('src', location)
    $(img).attr('src', location)
    $(img).load -> self.loaded.push(img)

# transition handler
class Transitioner
  # key: like 'map'
  constructor: (initial, timer, resets) ->
    @prev = $(initial)
    @time = timer

  swap: (next, resets) ->
    if resets then next.css(resets)
    next.appendTo(@prev.parent())
    @transition @prev, @time, '-' + ($(@prev).height() + 50), ->
      $(this).detach()
    return false if !next
    self = @
    @transition next, @time, 0, ->
      $(this).css('z-index', 2)
      self.prev = next

  transition: (element, timer, offset, callback) ->
    element.stop().animate
      'margin-top': offset
    , timer, 'linear', callback
    
# backbone page handler
class Page extends Backbone.Model
  # set up the model that will hold every page content
  defaults:
    name: 'piece_name'
    map: 'colored_map'
    associated: 'cutout_image'
    content: 'page_content'

class Pages extends Backbone.Collection
  # holds all page content
  model: Page

class Page_Manager extends Backbone.View
  el: $('body, html')

  initialize: (maps, assoc)->
    @collection = new Pages()
    @maps = maps
    @assoc = assoc
    @pages = @pagelist()
    @disabled = false
    @main = $('#main_content')

    initial_item = @init(window.location.href.split('#')[1])

    @time = 1100
    @trans_map = new Transitioner(initial_item.get('map'), @time)
    @trans_assoc = new Transitioner(initial_item.get('associated'), @time)
    @trans_content = new Transitioner(initial_item.get('content'), @time)
  
  events: {
    "click nav#main a" : "nav"
  }
  
  init: (page) ->
    page =  if !page then '#code' else '#' + page
    position = $.inArray(page, @pages)
    title = page.replace('#', '')

    data = @get_data(page)

    starter = @create(data.title, data.map, data.assoc, $(page))
    starter.get('content').appendTo(@main)
    @active = data.title
    starter

  nav: (e) ->
    page = e.currentTarget.hash

    data = @get_data(page)
    return false if @disabled == true or @active == data.title
    self = @
    self.disabled = true
    
    record = @get(data.title)[0]
    
    if !record # checks existance of the record
      record = @create(data.title, data.map, data.assoc, $(page))
    else
      record.set({ map: data.map, associated: data.assoc }) # may want to change to check if images differ

    @set(record)
    setTimeout ->
      self.disabled = false
    , @time

    e.preventDefault()
  
  get_data: (page) ->
    position = $.inArray(page, @pages)
    { title: page.replace('#', ''), map: @get_image(@maps.loaded, position), assoc: @get_image(@assoc.loaded, position) }

  get_image: (array, position) ->
    if array[position] then return array[position] else return array[0]

  get: (title) ->
    @collection.filter (page) ->
      page.get('name') == title

  create: (name, map_element, people_element, content) ->
    item = new Page()
    item.set({ name: name, map: map_element, associated: people_element, content: content })
    @collection.add(item)
    item
    
    # add decoded
  pagelist: -> # gets the ids of all the pages for positioning
    pages = []
    pages.push $(section).attr('href') for section in $('nav#main a')
    pages
    
  set: (page) -> # need to check whether current exists or not to determine how to act
    @active = page.get('name')

    @trans_map.swap($(page.get('map')), {'margin-top': 0, 'z-index': 1})
    @trans_assoc.swap($(page.get('associated')), {'margin-top': $('html, body').height() * 3, 'z-index': 1})
    @trans_content.swap(page.get('content'), {'margin-top': $('html, body').height()})
    content_height = if page.get('content').height() > $(window).height() then page.get('content').height() else $(window).height()
    @main.height(content_height)

# resize for browser
class Resize
  constructor: (container, image) ->
    @container = container
    @image_ratio = @ratio(image.width(), image.height())
    @state()

  ratio: (width, height) ->
    width / height

  state: ->
    if !$(@container).hasClass('wide') and @ratio($(window).width(), $(window).height()) > @image_ratio
      $(@container).addClass('wide')
    else if $(@container).hasClass('wide') and @ratio($(window).width(), $(window).height()) < @image_ratio
      $(@container).removeClass('wide')
    
class Wheel
  constructor: (container, inner) ->
    @container = container
    @inner = [$(container).find('.inner').attr('src')].concat(inner.files)
    @legends = @legend()
    @master = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]

    @key = 0
    @R = Raphael(@container.attr('id'), @container.width(), @container.height())

    @outer_image = @R.image(@container.find('.outer').attr('src'), 0, 0, 335, 335)
    @inner_image = @R.image(@inner[@key], 35, 35, 265, 265)

  legend: () ->
    # get request ajax stylez
    keys = [["D","7","R","4","9","L","K","Y","H","0","G","8","O","T","A","E","Z","W","3","X","2","Q","P","F","J","B","M","5","S","I","C","V","N","1","U","6"]]
    keys.push(["D","7","R","4","9","L","K","Y","H","0","G","8","O","T","A","E","Z","W","3","X","2","Q","P","F","J","B","M","5","S","I","C","V","N","1","U","6"]) for i in [0..@inner.length-1]
    keys

  swap: (new_key) ->
    self = @
    return false if new_key-1 == @key
    @key = new_key-1 or 0

    @transition_swap @inner_image, 250, 135, 35, 0, ->
      self.inner_image.attr("src", self.inner[0])
      self.transition_swap self.inner_image, 250, 35, 35, 1

  spin: (key_match, key)->
    @transition_spin @inner_image, key_match, key
  
  transition_swap: (element, time, xpos, ypos, opacity, callback) -> # excluded for Transitioner method due to raphael/SVG elements
    element.animate
      x: xpos,
      y: ypos,
      opacity: opacity,
    , time
    , callback

  transition_spin: (element, key_match, key)-> # A=B > key_match a, key b
    position = $.inArray(key_match.toString().toUpperCase(), @master) - $.inArray(key.toString().toUpperCase(), @legends[@key])
    element.animate
      rotation: position * 10
    , 1000

class Coder
  constructor: (form, wheel, code_type) ->
    @form = form
    @wheel = wheel
    @code_type = code_type
    @key_a
    @key_b
    @disallow()

  disallow: ->
    @fields = @form.find('input[type!=submit], textarea')
    @fields.not(':first').addClass('unavailable')

  allowed: (field) ->
    if $(field).hasClass('unavailable')
      @fields.not('.unavailable').last().focus()
      return false
    true

  set_next: (element) ->
    $(@fields[@fields.index($(element)) + 1])
      .removeClass('unavailable')
      .focus()

  code: ->
    
  show: ->
    
  check: (key_val, element, char_pos) ->
    return false if $(element).val().length == 1
    if $(element).attr('id') == @code_type + '_master' # master key
      if key_val > 0 and key_val < 10
        @wheel.swap(key_val)
        return true
    if $.inArray(key_val.toString().toUpperCase(), @wheel.master) != -1
      if $(element).attr('id') == @code_type + '_key_one' then @key_a = key_val
      if $(element).attr('id') == @code_type + '_key_two' then @key_b = key_val
      @wheel.spin(@key_a, @key_b) if @key_a and @key_b
      return true
    false

code_focus = (obj, ele) ->
  return false if !obj.allowed(ele)
  acceptable = false

  $(ele).val('')
  $(ele)
    .keypress (e) ->
      acceptable = obj.check(String.fromCharCode(e.charCode), ele) # properly overwrites
    .keyup (e) ->
      return false if !acceptable
      obj.set_next(ele)
  
jQuery(document).ready ->
  maps = new Loader("maps", $('#maps').find('img'))
  assoc = new Loader("assoc", $('#people').find('img')) # change to people
  maps_resize = new Resize($('#maps'), $('#maps').find('img'))
  assoc_resize = new Resize($('#people'), $('#people').find('img'))

  pages = new Page_Manager(maps, assoc)

  $(window).resize ->
    maps_resize.state()
    assoc_resize.state()

  inner = new Loader("inner", $("#code_wheel .inner"))

  code_wheel = new Wheel($('#code_wheel'), inner)
  decode_wheel = new Wheel($('#decode_wheel'), inner)

  coder = new Coder($('#code form'), code_wheel, 'code')
  decoder = new Coder($('#decode form'), decode_wheel, 'decode')

  $('#code form input').focus ->
    code_focus(coder, this)
  $('#decode form input').focus ->
    code_focus(decoder, this)

## NOTES
# putting el outside of initialize is how you set the main element
#
## TODO
# code submit
# json load retrievals
# facebook and twitter

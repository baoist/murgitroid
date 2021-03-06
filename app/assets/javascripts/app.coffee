Array.prototype.attr_sort = (attribute) ->
  match_arr = this
  hold_arr = []
  hold_arr.push $(item).attr(attribute) for item in match_arr
  hold_arr.sort()

  $.each match_arr, (index, val) ->
    $(val).attr attribute, hold_arr[index]

  return match_arr

# Loader for background images.
# add a .loaded method and order method to make certain that the order is proper. Make sure Page positioning doesn't include initial.
class Loader
  constructor: (directory, fallback) ->
    @directory = directory
    @fallback = fallback[0]

    @loaded = []
    @files = []
    @retrieve()

  retrieve: ->
    self = @
    current = $(@fallback).attr('src')

    $.getJSON "/retrieve/" + @directory + ".json", (data) ->
      for item in data
        self.files.push(item) if item != current
      self.load_images()
    , "json"

  load_images: ->
    @load(item) for item in @files

  load: (location) ->
    self = @
    img = new Image('src', location)
    $(img).attr('src', location)
    $(img).load ->
      self.loaded.push(img)

  set_complete: ->
    @loaded = @loaded.attr_sort('src')
    @loaded_complete = true

# transition handler
class Transitioner
  # key: like 'map'
  constructor: (initial, timer, resets) ->
    @prev = $(initial)
    @time = timer
    @dir = if @prev[0].src and @prev[0].src.search(/assoc/i) > -1 then '+' else '-'

  swap: (next, resets) ->
    return false if !!next.attr('src') and @prev.attr('src') == next.attr('src')
    if resets then next.css(resets)
    next.appendTo(@prev.parent())
    @transition @prev, @time, @dir + (@prev.height() + 50), ->
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

  initialize: (maps, assoc, coder, decoder) ->
    @collection = new Pages()
    @maps = maps
    @assoc = assoc
    @pages = @pagelist()
    @disabled = false
    @main = $('#main_content')
    @coder = coder
    @decoder = decoder

    initial_item = @init(window.location.href.split('/')[window.location.href.split('/').length-1])

    @time = 1100
    @trans_map = new Transitioner(initial_item.get('map'), @time)
    @trans_assoc = new Transitioner(initial_item.get('associated'), @time)
    @trans_content = new Transitioner(initial_item.get('content'), @time)
  
  events: {
    "click nav#main a" : "nav",
    "click a.new_code" : "nav"
    "click a.new_decode" : "nav"
    "click a.terms_link" : "nav"
  }
  
  init: (page) ->
    page =  if !page or $.inArray('#' + page, @pages) == -1 then '#code' else '#' + page
    position = $.inArray(page, @pages)
    @start_pos = position
      
    title = page.replace('#', '')
    data = @get_data(page)

    starter = @create(data.title, data.map, data.assoc, $(page))
    start_height = if starter.get('content').height() > $(window).height() - $('header').height() - 30 then starter.get('content').height() + 50 else $(window).height() - $('header').height() - 30
    starter.get('content').height(start_height).appendTo(@main)
    @active = data.title
    starter

  nav: (e) ->
    page = e.currentTarget.hash

    data = @get_data(page)
    return false if @disabled == true or @active == data.title
    self = @
    self.disabled = true
    
    record = @get(data.title)[0]
    
    if !record
      record = @create(data.title, data.map, data.assoc, $(page))

    record.set({ map: data.map, associated: data.assoc }) if record.cid != 'c1'

    @set(record)
    setTimeout ->
      self.disabled = false
      if self.active == 'decoded' and self.get('code')
        self.reset_forms()
    , @time

    e.preventDefault()
  
  get_data: (page) ->
    position = $.inArray(page, @pages)
    position-- if position > @start_pos
    { title: page.replace('#', ''), map: @get_image(@maps, position), assoc: @get_image(@assoc, position) }

  get_image: (array, position) ->
    if array.loaded.length == array.files.length and !array.loaded_complete and array.files.length > 1
      array.set_complete()
    return if !!array.loaded[position] then array.loaded[position] else array.fallback

  get: (title) ->
    @collection.filter (page) ->
      page.get('name') == title

  create: (name, map_element, people_element, content) ->
    item = new Page()
    item.set({ name: name, map: map_element, associated: people_element, content: content })
    @collection.add(item)
    item
    
  pagelist: ->
    pages = []
    pages.push $(section).attr('href') for section in $('nav#main a')
    pages
    
  set: (page) -> # need to check whether current exists or not to determine how to act
    @active = page.get('name')

    @trans_map.swap($(page.get('map')), {'margin-top': 0, 'z-index': 1})
    @trans_assoc.swap($(page.get('associated')), {'margin-top': $('html, body').height() * 3, 'z-index': 1})
    @trans_content.swap(page.get('content'), {'margin-top': $('html, body').height()})
    content_height = if page.get('content').height() > ($(window).height() - $('#main_content').offset().top - 50) then page.get('content').height() + 20 else $(window).height() - $('#main_content').offset().top - 50
    @main.height(content_height)

  reset_forms: ->
    code = @get('code')[0].get('content')

    if $(code).find('.encoded_message').is('*')
      $(code).find('.encoded_message').remove()
      $(code).find('#code_wheel').show()
      @coder.disallow()
    
    @decoder.disallow()

# resize for browser
class Resize
  constructor: (container, image) ->
    @container = container
    @image_ratio = @ratio(image.width(), image.height())

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
    @wheel = inner
    @legends = @legend()
    @master = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
    @inner = @set_inner()

    @key = 0
    @R = Raphael(@container.attr('id'), @container.width(), @container.height())

    @outer_image = @R.image(@container.find('.outer').attr('src'), 0, 0, 335, 335)
    @inner_image = @R.image(@inner[@key] or $(container).find('.inner').attr('src'), 35, 35, 265, 265)
  
  set_inner: ->
    [$(@container).find('.inner').attr('src')].concat(@wheel.files)

  legend: () ->
    keys = [["D","7","R","4","9","L","K","Y","H","0","G","8","O","T","A","E","Z","W","3","X","2","Q","P","F","J","B","M","5","S","I","C","V","N","1","U","6"], ["H", "1", "L", "7", "O", "P", "D", "E", "4", "Q", "V", "Y", "F", "K", "X", "6", "Z", "3", "2", "U", "M", "B", "S", "5", "G", "R", "C", "9", "W", "8", "J", "I", "N", "0", "A", "T"], ["4", "J", "I", "0", "5", "2", "A", "Y", "B", "L", "N", "U", "F", "D", "V", "Q", "1", "P", "8", "Z", "3", "G", "E", "M", "H", "C", "7", "O", "T", "R", "6", "X", "9", "W", "S", "K"], ["J", "7", "I", "T", "E", "P", "U", "2", "V", "S", "K", "D", "W", "8", "1", "F", "L", "H", "Z", "5", "N", "R", "B", "9", "O", "C", "G", "6", "Y", "3", "Q", "A", "M", "X", "4", "0"], ["J", "P", "W", "2", "B", "Q", "R", "S", "X", "H", "G", "T", "N", "1", "I", "U", "Z", "9", "L", "M", "6", "5", "0", "4", "O", "K", "8", "F", "C", "Y", "7", "A", "E", "V", "D", "3"], ["S", "Q", "3", "I", "4", "D", "A", "W", "U", "6", "R", "O", "M", "E", "V", "J", "1", "2", "F", "L", "G", "7", "T", "Y", "P", "C", "H", "X", "B", "N", "9", "0", "K", "5", "Z", "8"], ["2", "W", "7", "D", "T", "X", "B", "P", "8", "E", "H", "Q", "A", "3", "K", "I", "Z", "1", "6", "4", "M", "L", "S", "N", "U", "J", "R", "Y", "0", "9", "C", "F", "G", "O", "5", "V"], ["K", "Y", "L", "G", "M", "7", "3", "8", "V", "T", "E", "R", "C", "W", "I", "1", "0", "P", "D", "2", "X", "Q", "J", "6", "A", "5", "O", "B", "Z", "H", "F", "S", "U", "4", "N", "9"], ["5", "1", "D", "E", "P", "7", "Y", "C", "6", "X", "U", "T", "8", "0", "W", "K", "R", "M", "9", "J", "V", "4", "L", "A", "O", "I", "N", "Q", "Z", "3", "F", "H", "S", "2", "B", "G"], ["2", "S", "T", "8", "L", "5", "W", "9", "Q", "H", "P", "A", "1", "F", "B", "I", "O", "N", "Z", "7", "U", "G", "E", "C", "6", "X", "0", "M", "V", "3", "R", "J", "Y", "K", "4", "D"]]
    keys

  swap: (new_key) ->
    self = @
    return false if new_key-1 == @key
    @inner = @set_inner()
    @key = new_key-1 or 0

    @transition_swap @inner_image, 250, 135, 35, 0, ->
      self.inner_image.attr("src", self.inner[self.key])
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

  transition_spin: (element, key_match, key) ->
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
    @message = ''

  disallow: ->
    @fields = @form.find('input[type=text], input[type=number], textarea')
    @fields.val('')
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
    data = @form.serializeArray()
    self = @
    return false if @message == data[data.length - 1].value
    @message = data[data.length - 1].value

    $.post @form.attr('action') + '.json', data, (data) ->
      return false if data.status == "error"
      self.show_code(self.form.parent(), data.coded.message_coded)
      
  show_code: (container, message)->
    self = @
    time = 'slow'

    container.height('auto')

    if $('.encoded_message').is('*')
      $('.encoded_message').slideToggle time , ->
        $(this).remove()
        self.show_code container, message
      return false
    if $('#code_wheel').is('*')
      $('#code_wheel').slideUp time
    if is_iProduct()
      $('body').animate ->
        scrollTop: 0
      , time

    new_el = $('<div>').addClass('encoded_message').css 'display', 'none'
    new_el.append('<hgroup>').append('<h2>your message</h2><h1>'+ message + '</h1>')
    navi = $('<nav>').attr('class', 'social_media')
    navi.append $('<a>').attr({ class: 'facebook', target: 'new', href: 'http://www.facebook.com/share.php?u=http://its-supermurgitroid.com/page/decode&t=Decode My Message on Its-SuperMurgitroid' }).text('Post on Facebook')
    navi.append $('<a>').attr({ class: 'twitter', target: 'new', href: 'http://twitter.com/home?status=' + message + ' %23itsSM' }).text('Tweet')
    navi.append $('<a>').attr({ class: 'email', href: "mailto:?subject=Decode My Message on its-supermurgitroid.com&body=This message is for your eyes only. Contact me if you need the master code and key." + escape("\n") + escape("\n") + message }).text('Send with Email')
    navi.appendTo(new_el)
    new_el.prependTo(container)

    new_el.slideToggle time
    
  decode: ->
    data = @form.serializeArray()
    self = @

    $.post @form.attr('action') + '.json', data, (data) ->
      return false if data.status == "error"
      $('#decoded_link').click()
      $('#decoded').find('hgroup h1').text(data.message)
    
  check: (key_val, element, char_pos) ->
    return true if $(element).is('textarea')
    return false if $(element).val().length == 1
    if $(element).attr('id') == @code_type + '_master' # master key
      if key_val > 0 and key_val < 10
        @wheel.swap(key_val)
        return true
      else
        return false
    if $.inArray(key_val.toString().toUpperCase(), @wheel.master) != -1
      if $(element).attr('id') == @code_type + '_key_a' then @key_a = key_val
      if $(element).attr('id') == @code_type + '_key_b' then @key_b = key_val
      @wheel.spin(@key_a, @key_b) if @key_a and @key_b
      return true
    false

class Contact
  constructor: (form) ->
    @form = form
    @status = true
    
  send: ->
    return false if @status == false
    @status = false
    self = @

    data = @form.serializeArray()
    $.post @form.attr('action') + '.json', data, (data) ->
      self.status = true
      if data.status == 'error'
        self.message('error', 'Please decode the message and place it in the captcha field.')
        return false
      self.form.find('#captcha').removeClass('error')
      self.clear()
      self.message('success', 'Thank you for contacting headquarters.')

  clear: ->
    @form.find('input[type=text], textarea').val('')

  message: (status, message)->
    time = 650
    self = @
    return false if $('.contact_response').find('p').attr('class') == status
    if $('.contact_response').is('*')
      $('.contact_response').slideToggle time, ->
        $(this).remove()
        self.message status, message
      return false
    @form.after $('<div class="contact_response"><p class="' + status + '">' + message + '</p></div>')
    $('body, html').find('.contact_response').slideToggle time

code_focus = (obj, ele) ->
  return false if !obj.allowed(ele)
  acceptable = false

  $(ele).val('')
  $(ele)
    .keypress (e) ->
      acceptable = obj.check(String.fromCharCode(e.charCode), ele)
    .keyup (e) ->
      return false if !acceptable
      obj.set_next(ele)

is_iProduct = ->
  return (navigator.platform.indexOf("iPhone") != -1) || (navigator.platform.indexOf("iPod") != -1) || (navigator.platform.indexOf("iPad") != -1)

jQuery(document).ready ->
  if !is_iProduct()
    maps = new Loader("maps", $('#maps').find('img'))
    assoc = new Loader("assoc", $('#people').find('img'))
  else
    maps = new Loader("blank", $('#maps').find('img'))
    assoc = new Loader("blank", $('#people').find('img'))

  maps_resize = new Resize($('#maps'), $('#maps').find('img'))
  assoc_resize = new Resize($('#people'), $('#people').find('img'))

  $(window).resize ->
    maps_resize.state()
    assoc_resize.state()
   
  if $('#main_content').is('*')
    inner = new Loader("inner", $("#code_wheel .inner"))
    code_wheel = new Wheel($('#code_wheel'), inner)
    decode_wheel = new Wheel($('#decode_wheel'), inner)

    coder = new Coder($('#code form'), code_wheel, 'code')
    decoder = new Coder($('#decode form'), decode_wheel, 'decode')

    pages = new Page_Manager(maps, assoc, coder, decoder)

    contact = new Contact($('#new_contact'))

    $('#code form input[type!=submit], #code form textarea').focus -> code_focus(coder, this)
    $('#decode form input[type!=submit], #code form textarea').focus -> code_focus(decoder, this)

    $('#new_code').submit ->
      coder.code()
      false
    $('#new_decode').submit ->
      decoder.decode()
      false
    $('#new_contact').submit ->
      contact.send()
      false

  maps_resize.state()
  assoc_resize.state()

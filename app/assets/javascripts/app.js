(function() {
  var Coder, Loader, Page, Page_Manager, Pages, Resize, Transitioner, Wheel, code_focus;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Loader = (function() {
    function Loader(directory, fallback) {
      this.directory = directory;
      this.fallback = fallback[0];
      this.loaded = [this.fallback];
      this.files = this.retrieve();
      this.load_images();
    }
    Loader.prototype.retrieve = function() {
      if (this.directory === "maps") {
        return ["images/maps/map-2.jpg", "images/maps/map-3.jpg", "images/maps/map-3.jpg", "images/maps/map-4.jpg", "images/maps/map-5.jpg", "images/maps/map-6.jpg", "images/maps/map-7.jpg"];
      } else {
        return ["images/assoc/people-2.png", "images/assoc/people-3.png", "images/assoc/people-4.png", "images/assoc/people-5.png", "images/assoc/people-6.png", "images/assoc/people-7.png"];
      }
    };
    Loader.prototype.load_images = function() {
      var item, _i, _len, _ref, _results;
      _ref = this.files;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(this.load(item));
      }
      return _results;
    };
    Loader.prototype.load = function(location) {
      var img, self;
      self = this;
      img = new Image('src', location);
      $(img).attr('src', location);
      return $(img).load(function() {
        return self.loaded.push(img);
      });
    };
    return Loader;
  })();
  Transitioner = (function() {
    function Transitioner(initial, timer, resets) {
      this.prev = $(initial);
      this.time = timer;
    }
    Transitioner.prototype.swap = function(next, resets) {
      var self;
      if (resets) {
        next.css(resets);
      }
      next.appendTo(this.prev.parent());
      this.transition(this.prev, this.time, '-' + ($(this.prev).height() + 50), function() {
        return $(this).detach();
      });
      if (!next) {
        return false;
      }
      self = this;
      return this.transition(next, this.time, 0, function() {
        $(this).css('z-index', 2);
        return self.prev = next;
      });
    };
    Transitioner.prototype.transition = function(element, timer, offset, callback) {
      return element.stop().animate({
        'margin-top': offset
      }, timer, 'linear', callback);
    };
    return Transitioner;
  })();
  Page = (function() {
    __extends(Page, Backbone.Model);
    function Page() {
      Page.__super__.constructor.apply(this, arguments);
    }
    Page.prototype.defaults = {
      name: 'piece_name',
      map: 'colored_map',
      associated: 'cutout_image',
      content: 'page_content'
    };
    return Page;
  })();
  Pages = (function() {
    __extends(Pages, Backbone.Collection);
    function Pages() {
      Pages.__super__.constructor.apply(this, arguments);
    }
    Pages.prototype.model = Page;
    return Pages;
  })();
  Page_Manager = (function() {
    __extends(Page_Manager, Backbone.View);
    function Page_Manager() {
      Page_Manager.__super__.constructor.apply(this, arguments);
    }
    Page_Manager.prototype.el = $('body, html');
    Page_Manager.prototype.initialize = function(maps, assoc) {
      var initial_item;
      this.collection = new Pages();
      this.maps = maps;
      this.assoc = assoc;
      this.pages = this.pagelist();
      this.disabled = false;
      this.main = $('#main_content');
      initial_item = this.init(window.location.href.split('#')[1]);
      this.time = 1100;
      this.trans_map = new Transitioner(initial_item.get('map'), this.time);
      this.trans_assoc = new Transitioner(initial_item.get('associated'), this.time);
      return this.trans_content = new Transitioner(initial_item.get('content'), this.time);
    };
    Page_Manager.prototype.events = {
      "click nav#main a": "nav"
    };
    Page_Manager.prototype.init = function(page) {
      var data, position, starter, title;
      page = !page ? '#code' : '#' + page;
      position = $.inArray(page, this.pages);
      title = page.replace('#', '');
      data = this.get_data(page);
      starter = this.create(data.title, data.map, data.assoc, $(page));
      starter.get('content').appendTo(this.main);
      this.active = data.title;
      return starter;
    };
    Page_Manager.prototype.nav = function(e) {
      var data, page, record, self;
      page = e.currentTarget.hash;
      data = this.get_data(page);
      if (this.disabled === true || this.active === data.title) {
        return false;
      }
      self = this;
      self.disabled = true;
      record = this.get(data.title)[0];
      if (!record) {
        record = this.create(data.title, data.map, data.assoc, $(page));
      } else {
        record.set({
          map: data.map,
          associated: data.assoc
        });
      }
      this.set(record);
      setTimeout(function() {
        return self.disabled = false;
      }, this.time);
      return e.preventDefault();
    };
    Page_Manager.prototype.get_data = function(page) {
      var position;
      position = $.inArray(page, this.pages);
      return {
        title: page.replace('#', ''),
        map: this.get_image(this.maps.loaded, position),
        assoc: this.get_image(this.assoc.loaded, position)
      };
    };
    Page_Manager.prototype.get_image = function(array, position) {
      if (array[position]) {
        return array[position];
      } else {
        return array[0];
      }
    };
    Page_Manager.prototype.get = function(title) {
      return this.collection.filter(function(page) {
        return page.get('name') === title;
      });
    };
    Page_Manager.prototype.create = function(name, map_element, people_element, content) {
      var item;
      item = new Page();
      item.set({
        name: name,
        map: map_element,
        associated: people_element,
        content: content
      });
      this.collection.add(item);
      return item;
    };
    Page_Manager.prototype.pagelist = function() {
      var pages, section, _i, _len, _ref;
      pages = [];
      _ref = $('nav#main a');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        section = _ref[_i];
        pages.push($(section).attr('href'));
      }
      return pages;
    };
    Page_Manager.prototype.set = function(page) {
      var content_height;
      this.active = page.get('name');
      this.trans_map.swap($(page.get('map')), {
        'margin-top': 0,
        'z-index': 1
      });
      this.trans_assoc.swap($(page.get('associated')), {
        'margin-top': $('html, body').height() * 3,
        'z-index': 1
      });
      this.trans_content.swap(page.get('content'), {
        'margin-top': $('html, body').height()
      });
      content_height = page.get('content').height() > $(window).height() ? page.get('content').height() : $(window).height();
      return this.main.height(content_height);
    };
    return Page_Manager;
  })();
  Resize = (function() {
    function Resize(container, image) {
      this.container = container;
      this.image_ratio = this.ratio(image.width(), image.height());
      this.state();
    }
    Resize.prototype.ratio = function(width, height) {
      return width / height;
    };
    Resize.prototype.state = function() {
      if (!$(this.container).hasClass('wide') && this.ratio($(window).width(), $(window).height()) > this.image_ratio) {
        return $(this.container).addClass('wide');
      } else if ($(this.container).hasClass('wide') && this.ratio($(window).width(), $(window).height()) < this.image_ratio) {
        return $(this.container).removeClass('wide');
      }
    };
    return Resize;
  })();
  Wheel = (function() {
    function Wheel(container, inner) {
      this.container = container;
      this.inner = [$(container).find('.inner').attr('src')].concat(inner.files);
      this.legends = this.legend();
      this.master = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
      this.key = 0;
      this.R = Raphael(this.container.attr('id'), this.container.width(), this.container.height());
      this.outer_image = this.R.image(this.container.find('.outer').attr('src'), 0, 0, 335, 335);
      this.inner_image = this.R.image(this.inner[this.key], 35, 35, 265, 265);
    }
    Wheel.prototype.legend = function() {
      var i, keys, _ref;
      keys = [["D", "7", "R", "4", "9", "L", "K", "Y", "H", "0", "G", "8", "O", "T", "A", "E", "Z", "W", "3", "X", "2", "Q", "P", "F", "J", "B", "M", "5", "S", "I", "C", "V", "N", "1", "U", "6"]];
      for (i = 0, _ref = this.inner.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        keys.push(["D", "7", "R", "4", "9", "L", "K", "Y", "H", "0", "G", "8", "O", "T", "A", "E", "Z", "W", "3", "X", "2", "Q", "P", "F", "J", "B", "M", "5", "S", "I", "C", "V", "N", "1", "U", "6"]);
      }
      return keys;
    };
    Wheel.prototype.swap = function(new_key) {
      var self;
      self = this;
      if (new_key - 1 === this.key) {
        return false;
      }
      this.key = new_key - 1 || 0;
      return this.transition_swap(this.inner_image, 250, 135, 35, 0, function() {
        self.inner_image.attr("src", self.inner[0]);
        return self.transition_swap(self.inner_image, 250, 35, 35, 1);
      });
    };
    Wheel.prototype.spin = function(key_match, key) {
      return this.transition_spin(this.inner_image, key_match, key);
    };
    Wheel.prototype.transition_swap = function(element, time, xpos, ypos, opacity, callback) {
      return element.animate({
        x: xpos,
        y: ypos,
        opacity: opacity
      }, time, callback);
    };
    Wheel.prototype.transition_spin = function(element, key_match, key) {
      var position;
      position = $.inArray(key_match.toString().toUpperCase(), this.master) - $.inArray(key.toString().toUpperCase(), this.legends[this.key]);
      return element.animate({
        rotation: position * 10
      }, 1000);
    };
    return Wheel;
  })();
  Coder = (function() {
    function Coder(form, wheel, code_type) {
      this.form = form;
      this.wheel = wheel;
      this.code_type = code_type;
      this.key_a;
      this.key_b;
      this.disallow();
    }
    Coder.prototype.disallow = function() {
      this.fields = this.form.find('input[type!=submit], textarea');
      return this.fields.not(':first').addClass('unavailable');
    };
    Coder.prototype.allowed = function(field) {
      if ($(field).hasClass('unavailable')) {
        this.fields.not('.unavailable').last().focus();
        return false;
      }
      return true;
    };
    Coder.prototype.set_next = function(element) {
      return $(this.fields[this.fields.index($(element)) + 1]).removeClass('unavailable').focus();
    };
    Coder.prototype.code = function() {};
    Coder.prototype.show = function() {};
    Coder.prototype.check = function(key_val, element, char_pos) {
      if ($(element).val().length === 1) {
        return false;
      }
      if ($(element).attr('id') === this.code_type + '_master') {
        if (key_val > 0 && key_val < 10) {
          this.wheel.swap(key_val);
          return true;
        }
      }
      if ($.inArray(key_val.toString().toUpperCase(), this.wheel.master) !== -1) {
        if ($(element).attr('id') === this.code_type + '_key_one') {
          this.key_a = key_val;
        }
        if ($(element).attr('id') === this.code_type + '_key_two') {
          this.key_b = key_val;
        }
        if (this.key_a && this.key_b) {
          this.wheel.spin(this.key_a, this.key_b);
        }
        return true;
      }
      return false;
    };
    return Coder;
  })();
  code_focus = function(obj, ele) {
    var acceptable;
    if (!obj.allowed(ele)) {
      return false;
    }
    acceptable = false;
    $(ele).val('');
    return $(ele).keypress(function(e) {
      return acceptable = obj.check(String.fromCharCode(e.charCode), ele);
    }).keyup(function(e) {
      if (!acceptable) {
        return false;
      }
      return obj.set_next(ele);
    });
  };
  jQuery(document).ready(function() {
    var assoc, assoc_resize, code_wheel, coder, decode_wheel, decoder, inner, maps, maps_resize, pages;
    maps = new Loader("maps", $('#maps').find('img'));
    assoc = new Loader("assoc", $('#people').find('img'));
    maps_resize = new Resize($('#maps'), $('#maps').find('img'));
    assoc_resize = new Resize($('#people'), $('#people').find('img'));
    pages = new Page_Manager(maps, assoc);
    $(window).resize(function() {
      maps_resize.state();
      return assoc_resize.state();
    });
    inner = new Loader("inner", $("#code_wheel .inner"));
    code_wheel = new Wheel($('#code_wheel'), inner);
    decode_wheel = new Wheel($('#decode_wheel'), inner);
    coder = new Coder($('#code form'), code_wheel, 'code');
    decoder = new Coder($('#decode form'), decode_wheel, 'decode');
    $('#code form input').focus(function() {
      return code_focus(coder, this);
    });
    return $('#decode form input').focus(function() {
      return code_focus(decoder, this);
    });
  });
}).call(this);

/*************
 * OBSERVERS *
 *************/
Event.observe(window, "load", function() {
  if ($("assets")) {
    Assets.assets_table = $("assets");
    Assets.assets_section = $("assets").childElements()[1];
  }

  $$(".category").each(function(cat) {
    cat.observe("click", function(e) {
      changeCategory(cat); 
      Event.stop(e);
    }.bind(this));
  });
});

function changeCategory(category) {
  Assets.assets_table.hide();
  $("assets_spinner").show();

  Assets.clear();

  new Ajax.Request(category.href + "&format=json", {
    method: "get",
    onComplete: function(transport) {
      var json = transport.responseJSON; // category (String), assets (array)
      json.assets.each(function(asset) {
        asset = asset.asset;

        Assets.loadAsset({
          id: asset.id, 
          title: asset.title,
          category: json.category, 
          year: asset.year, 
          author: asset.author,
          url: unescape(asset.url)
        });
      }.bind(this));

      $("assets_spinner").hide();
      Assets.assets_table.show();
      Assets.show();
    }.bind(this)
  });
}

/**********
 * SHOUTS *
 **********/
var shouts = null;

function displayShouts() {
  if($('shouts').style.display == 'none') {
    $('shouts').innerHTML = '<img src="/images/spinner.gif" alt="spinner" />';
    $('shouts').style.display = '';
    $('new_message_link').style.display = '';
    if(!shouts) {
      fetchAndRenderShouts();
    } else {
      renderShouts();
    }
  } else {
    $('shouts').style.display = 'none';
    $('new_message_link').style.display = 'none';
  }
}

function displayNewMessage() {
  if($('new_message').style.display == 'none') {
    $('new_message').style.display = '';
  } else {
    $('new_message').style.display = 'none'
  }
}

function fetchAndRenderShouts() {
  new Ajax.Request('/messages.json', {
    method: 'get',
    onSuccess: function(transport) {
      shouts = transport.responseJSON;
      renderShouts();
    }
  });
}

function renderShouts() {
  if(!shouts) {
    $('shouts').innerHTML = 'Miski error';
    return;
  } else {
    $('shouts').innerHTML = '';
  }

  var i = 0;
  shouts.each(function(record) {
    var klass = (i % 2) ? 'odd' : 'even';

    record = record['message']
    var p = new Element('p', {'class': klass});
    var datetime = formatDate(record['created_at']);
    var span = new Element('span', {'class': 'author'}).update(record['author'].escapeHTML() + ' - ' + datetime);
    p.insert(span);
    p.insert('<br/>');
    p.insert(record['body'].escapeHTML());
    $('shouts').insert(p);

    i++;
  });
  new Effect.Shake($('shouts'), {duration: 0.8});
}

function formatDate(d) {
  if (typeof d == 'string') {
    d = d.toDate();
  }

  var month = d.getMonth() + 1;
  var day_month_year = d.getDate() + '/' + month + '/' + d.getFullYear();

  var hours = d.getHours();
  if (hours < 10) {
    hours = '0' + hours;
  }
  var minutes = d.getMinutes();
  if (minutes < 10) {
    minutes = '0' + minutes;
  }

  return (day_month_year + ' - ' + hours + ':' + minutes);
}

function submitMessage() {
  var author = $('message_author');
  var body = $('message_body');
  var submit = $('message_submit');
  var spinner = $('message_spinner');

  if(author.value.length > 20 || author.value.length < 3) {
    alert('Nimi peab olema vahemikus 5 kuni 20 tähemärki');
    return false;
  }
  if(body.value.length > 150 || body.value.length < 5) {
    alert('Sisu peab olema vahemikus 5 kuni 150 tähemärki');
    return false;
  }

  var params = $('new_message_form').serialize(true);
  author.disabled = true;
  body.disabled = true;
  submit.disabled = true;
  spinner.style.display = '';

  new Ajax.Request('/messages.json', {
    method: 'post', parameters: params,
    onComplete: function(transport) {
      author.disabled = false;
      body.disabled = false;
      submit.disabled = false;
      spinner.style.display = 'none';

      var shout = transport.responseJSON;
      if(shout['message'] != undefined) {
        $('new_message').style.display = 'none';
        author.value = '';
        body.value = '';
        addShout(shout);
      } else {
        alert('Miskit juhtus ja shouti ei õnnestunud ära salvestada');
      }
    }
  });
}

function addShout(shout) {
  if(shouts.length > 9) {
    shouts.pop();
  }
  shouts.reverse();
  shouts.push(shout);
  shouts.reverse();
  renderShouts();
}

/*****************
 * InPlaceEditor *
 *****************/
function in_place_editor(element, column, url) {
  var obj = element.select('.' + column)[0];
  new Ajax.InPlaceEditor(obj, url, {
    callback: function(form, value) { return 'asset[' + column + ']=' + escape(value) },
    ajaxOptions: { method: 'put' },
    onComplete: function(transport, element) {
      response = transport.responseJSON;
      element.innerHTML = response[column];
    }
  });
}

/********************
 * CATEGORIES CLOUD *
 ********************/
function displayCategoriesCloud() {
  if($('categories_cloud').style.display == 'none') {
    $('categories_cloud').style.display = '';
  } else {
    $('categories_cloud').style.display = 'none'
  }
}

/**********
 * ASSETS *
 **********/
var Assets = Class.create({
});
Object.extend(Assets, {
  assets: new Array(),
  assets_table: null,
  assets_section: null,

  clear: function() {
    this.assets_section.innerHTML = "";
    this.assets = new Array();
  },

  show: function() {
    var i = 0;
    this.assets.each(function(asset) {
      var parity = i % 2 == 0 ? "even" : "odd";
      var el = "<tr class=" + parity + "><td>" + asset["title"] + "</td>";
      el += "<td>" + asset["category"] + "</td>";
      el += "<td>" + asset["year"] + "</td>";
      el += "<td>" + asset["author"] + "</td>";
      el += "<td><a href=" + asset["url"] + ">Vaata</a></td></tr>";

      this.assets_section.insert({bottom: el});
      i++;
    }.bind(this));
  },

  find: function(id) {
    this.assets.each(function(asset) {
      if (asset.id == id) {
        return asset;
      }
    });
  },

  loadAsset: function(options) {
    this.add(new Asset(options));
  },

  add: function(asset) {
    this.assets.push(asset);
  },

  remove: function(asset) {
    var index = this.assets.indexOf(asset);
    this.assets.splice(index, index);
    asset.fade();
  },

  destroy: function(id) {
    new Ajax.Request("/assets/" + id + ".json", {
      method: "delete",
      onComplete: function(transport) {
        var response = transport.responseJSON;
        if(response["success"] == true) {
          var asset = Assets.find(id);
          this.remove(asset)
        } else {
          alert("Kustutamine ebaõnnestus");
        }
      }.bind(this)
    });
  }
});

var Asset = Class.create({
  initialize: function(opts) {
    this.id       = opts["id"];
    this.title    = titlelize(opts["title"]);
    this.category = titlelize(opts["category"]);
    this.year     = opts["year"];
    this.author   = opts["author"];
    this.url      = opts["url"];
  }
});

function titlelize(str) {
  var title = str.split(" ");
  var output = new Array();

  $(title).each(function(w) {
    w = w[0, 0].toUpperCase() + w.substring(1);

    if (w.match(/^[ivx]*$/i)) {
      w = w.toUpperCase();
    }

    output.push(w);
  }.bind(this));

  return output.join(" ");
}

// Prototype extensions
String.prototype.toDate = function() {
  var a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(this);
  if (a) {
    return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]));
  } else {
    return null;
  }
}


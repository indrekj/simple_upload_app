/*************
 * OBSERVERS *
 *************/
Event.observe(window, 'load', function() {
  Assets.loadAssets();

  var page = History.get('page');
  if(page) {
    Assets.showByCategory(unescape(page));
  }
});

function changeCategory(page) {
  History.set('page', escape(page));
  Assets.showByCategory(page);
  return false;
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
  assetsToShow: new Array(),

  loadAssets: function() {
    $$('.asset').each(function(asset) {
      Assets.loadAsset(asset)
    });
  },

  loadAsset: function(asset) {
    var cat = asset.getElementsByClassName('category')[0].innerHTML;
    var a = new Asset({id: asset.id, category: cat});
    Assets.add(a);
  },

  find: function(id) {
    assets.each(function(asset) {
      if(asset.id == 'asset_' + id || asset.id == id) {
        return asset;
      }
    });
  },

  add: function(asset) {
    Assets.assets.push(asset);
  },

  // NOTE: Usual id, not dom_id.
  destroy: function(id) {
    new Ajax.Request('/assets/' + id + '.json', {
      method: 'delete',
      onComplete: function(transport) {
        var response = transport.responseJSON;
        if(response['success'] == true) {
          var asset = Assets.find(id);
          asset.fade();
          
          // remove asset from list
          var index = Assets.assets.indexOf(asset);
          Assets.assets.splice(index, index);
          index = Assets.assetsToShow.indexOf(asset);
          Assets.assetsToShow.splice(index, index);
        } else {
          alert('Kustutamine ebaõnnestus');
        }
      }
    });
  },

  showAll: function() {
    Assets.assetsToShow = Assets.assets;
    Assets.show();
  },

  showByCategory: function(category) {
    Assets.assetsToShow = new Array();
    Assets.assets.each(function(asset) {
      if(asset.category.toLowerCase() == category.toLowerCase()) {
        Assets.assetsToShow.push(asset);
      }
    });
    Assets.show();
  },

  show: function() {
    var odd = 0;
    Assets.assets.each(function(asset) {
      if(Assets.assetsToShow.indexOf(asset) != -1) {
        asset.setOdd(odd % 2);
        asset.show();
        odd++;
      } else {
        asset.hide();
      }
    });
  }
});

var Asset = Class.create({
  id: null,
  category: null,
  element: null,

  initialize: function(hash) {
    this.id       = hash['id'];
    this.category = hash['category'];
    this.element  = $(this.id);
  },

  setOdd: function(bool) {
    this.element.removeClassName('odd');
    this.element.removeClassName('even');
    var parity = bool ? 'odd' : 'even';
    this.element.addClassName(parity);
  },

  show: function() {
    this.element.show();
  },

  hide: function() {
    this.element.hide();
  }
});


// Prototype extensions
String.prototype.toDate = function() {
  var a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(this);
  if (a) {
    return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]));
  } else {
    return null;
  }
}


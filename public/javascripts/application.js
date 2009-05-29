// Common JavaScript code across your application goes here.

/**********
 * SHOUTS *
 **********/
var shouts = null;

function display_shouts() {
  if($('shouts').style.display == 'none') {
    $('shouts').innerHTML = '<img src="/images/spinner.gif" alt="spinner" />';
    $('shouts').style.display = '';
    $('new_message_link').style.display = '';
    if(!shouts) {
      fetch_and_render_shouts();
    } else {
      render_shouts();
    }
  } else {
    $('shouts').style.display = 'none';
    $('new_message_link').style.display = 'none';
  }
}

function display_new_message() {
  if($('new_message').style.display == 'none') {
    $('new_message').style.display = '';
  } else {
    $('new_message').style.display = 'none'
  }
}

function fetch_and_render_shouts() {
  new Ajax.Request('/messages', {
    method: 'get',
    onSuccess: function(transport) {
      shouts = transport.responseJSON;
      render_shouts();
    }
  });
}

function render_shouts() {
  if(!shouts) {
    $('shouts').innerHTML = 'Miski error';
    return;
  } else {
    $('shouts').innerHTML = '';
  }

  var i = 0;
  shouts.each(function(record) {
    var klass = (i % 2) ? 'odd' : 'even';

    var p = new Element('p', {'class': klass});
    var datetime = record['created_at'].split(' +')[0];
    var span = new Element('span', {'class': 'author'}).update(record['author'].escapeHTML() + ' - ' + datetime);
    p.insert(span);
    p.insert('<br/>');
    p.insert(record['body'].escapeHTML());
    $('shouts').insert(p);

    i++;
  });
  new Effect.Shake($('shouts'), {duration: 0.8});
}

function submit_message() {
  var author = $('message_author');
  var body = $('message_body');
  var submit = $('message_submit');
  var spinner = $('message_spinner');

  if(author.value.length > 20 || author.value.length < 3) {
    alert('Nimi peab olema vahemikus 5 kuni 20 tähemärki');
    return false;
  }
  if(body.value.length > 100 || body.value.length < 5) {
    alert('Sisu peab olema vahemikus 5 kuni 100 tähemärki');
    return false;
  }

  author.disabled = true;
  body.disabled = true;
  submit.disabled = true;
  spinner.style.display = '';

  new Ajax.Request('/messages', {
    method: 'post', parameters: $('new_message_form').serialize(),
    onComplete: function(transport) {
      author.disabled = false;
      body.disabled = false;
      submit.disabled = false;
      spinner.style.display = 'none';

      var shout = transport.responseJSON;
      if(shout['id'] != undefined) {
        $('new_message').style.display = 'none';
        author.value = '';
        body.value = '';
        add_shout(shout);
      } else {
        alert('Miskit juhtus ja shouti ei õnnestunud ära salvestada');
      }
    }
  });
}

function add_shout(shout) {
  if(shouts.length > 9) {
    shouts.pop();
  }
  shouts.reverse();
  shouts.push(shout);
  shouts.reverse();
  render_shouts();
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

/**********
 * ASSETS *
 **********/
function destroy_asset(id) {
  new Ajax.Request('/assets/' + id + '.json', {
    method: 'delete',
    onComplete: function(transport) {
      var response = transport.responseJSON;
      if(response['success'] == true) {
        $('asset_' + id).fade();
      } else {
        alert('Kustutamine ebaõnnestus');
      }
    }
  });
}

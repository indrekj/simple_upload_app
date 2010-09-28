/*************
 * OBSERVERS *
 *************/
Event.observe(window, "load", function() {
  //Event.observe($("new_file_link"), "click", function() {
  //  setTimeout(function() {initializeAjaxUploader()}, 1500);
  //});

  if ($("assessments")) {
    Assessments.assessments_table = $("assessments");
    Assessments.assessments_section = $("assessments").childElements()[1];
  }

  $$(".category").each(function(cat) {
    cat.observe("click", function(e) {
      Event.stop(e);
      changeCategory(cat); 
    }.bind(this));
  }.bind(this));

  // Google analytics
  loadScript("http://www.google-analytics.com/ga.js", function() {
    var pageTracker = _gat._getTracker("UA-3366869-2");
    pageTracker._trackPageview();
  }.bind(this));

  // DropIO Chat
  //loadScript("http://drop.io/it_inf/remote_chat_bar.js?chat_password=", function() {});
});

function loadScript(src, callback) {
  var head = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  var loaded = false;
  script.setAttribute('src', src);
  script.onload = script.onreadystatechange = function() {
    if (!loaded && (!this.readyState || this.readyState == 'complete'
                                     || this.readyState == 'loaded') ) {
      loaded = true;
      callback();
      script.onload = script.onreadystatechange = null;
      head.removeChild(script);
    }
  }
  head.appendChild(script);
}

var interval = null;
function initializeAjaxUploader() {
  $("upload_step_one").show();
  $("upload_step_two").hide();

  if (categoriesList)
    new Autocompleter.Local("assessment_category_name", "category_list", categoriesList);

  var uuid = randomUUID();
  new AjaxUpload("new_assessment_button", {
    action: "/assessments?format=js&X-Progress-ID=" + uuid + "&callback=uploadStepTwo",
    autoSubmit: true,
    name: "assessment[file]",
    responseType: "json",
    onSubmit: function(file, extension) {
      $("new_assessment_button").hide();
      interval = window.setInterval(function() {
        fetch(uuid);
      }, 500);
    }
  });
}

function uploadStepTwo(response) {
  if (response.success) {
    assessment = response.data.assessment;
    $("assessment_title").value = assessment.title;
    $("assessment_category_name").value = assessment.category_name;

    $("upload_step_one").hide();
    $("new_assessment_done_button").show();
    $("upload_step_two_spinner").hide();
    $("upload_step_two_failure").hide();
    $("upload_step_two_success").hide();

    Effect.SlideDown("upload_step_two", {duration: 1.5});

    Event.observe($("new_assessment_done_button"), "click", function() {
      new Ajax.Request("/assessments/" + assessment.id + "?format=json", {
        parameters: $("upload_step_two_form").serialize(true),
        method: "put",
        onLoading: function() {
          $("upload_step_two_spinner").show();
          $("new_assessment_done_button").hide();
          $("upload_step_two_failure").hide();
        },
        onSuccess: function(transport) {
          $("upload_step_two_spinner").hide();
          var assessment = transport.responseJSON.assessment;
          // Add assessment to list when uploaded to the current category
          //Assessments.loadAssessment(assessment);
          $("upload_step_two_success").show();
          setTimeout(function() { Modalbox.hide() }, 2000);
        },
        onFailure: function(transport) {
          $("upload_step_two_spinner").hide();
          $("upload_step_two_failure").show();
          setTimeout(function() { $("new_assessment_done_button").show() }, 2000);
        }
      });
    });
  } else {
    $("upload_step_one").innerHTML = "Miskit failis!";
  }
}

function fetch(uuid) {
  new Ajax.Request("/progress", {
    method: "get",
    requestHeaders: {"X-Progress-ID": uuid, "Accept": "application/json"},
    onComplete: function(transport) {
      var upload = eval(transport.responseText);

      $("progress").show();

      /* change the width if the inner progress-bar */
      if (upload.state == "uploading") {
        var percentage = 100 * upload.received / upload.size
        $("progress_percentage").innerHTML = "" + percentage + "%";
      }
    
      /* we are done, stop the interval */
      if (upload.state == "done") {
        $("progress").hide();
        window.clearTimeout(interval);
      }
    }
  });
}

function randomUUID() {
  uuid = "";
  for (i = 0; i < 32; i++) {
    uuid += Math.floor(Math.random() * 16).toString(16);
  }
  return uuid;
}

function changeCategory(category) {
  Assessments.assessments_table.hide();
  $("assessments_spinner").show();

  Assessments.clear();

  new Ajax.Request(category.href + "&format=json", {
    method: "get",
    onComplete: function(transport) {
      var json = transport.responseJSON; // category (String), assessments (array)
      json.assessments.each(function(assessment) {
        assessment = assessment.assessment;

        Assessments.loadAssessment({
          id: assessment.id, 
          title: assessment.title,
          category: json.category, 
          year: assessment.year, 
          author: assessment.author,
          url: unescape(assessment.assessment_path)
        });
      }.bind(this));

      $("assessments_spinner").hide();
      Assessments.assessments_table.show();
      Assessments.show();
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
  new Effect.BlindDown($('shouts'), {duration: 1});
}

function formatDate(d) {
  if (typeof d == 'string') {
    d = new Date(d);
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
    callback: function(form, value) { return 'assessment[' + column + ']=' + escape(value) },
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

/***************
 * ASSESSMENTS *
 ***************/
var Assessments = Class.create({
});
Object.extend(Assessments, {
  assessments: new Array(),
  assessments_table: null,
  assessments_section: null,

  clear: function() {
    this.assessments_section.innerHTML = "";
    this.assessments = new Array();
  },

  show: function() {
    var i = 0;
    this.assessments.each(function(assessment) {
      var parity = i % 2 == 0 ? "even" : "odd";
      var el = "<tr class=" + parity + "><td>" + assessment["title"] + "</td>";
      el += "<td>" + assessment["category"] + "</td>";
      el += "<td>" + assessment["year"] + "</td>";
      el += "<td>" + assessment["author"] + "</td>";
      el += "<td><a href=" + assessment["url"] + ">Vaata</a></td></tr>";

      this.assessments_section.insert({bottom: el});
      i++;
    }.bind(this));
  },

  find: function(id) {
    this.assessments.each(function(assessment) {
      if (assessment.id == id) {
        return assessment;
      }
    });
  },

  loadAssessment: function(options) {
    this.add(new Assessment(options));
  },

  add: function(assessment) {
    this.assessments.push(assessment);
  },

  remove: function(assessment) {
    var index = this.assessments.indexOf(assessment);
    this.assessments.splice(index, index);
    assessment.fade();
  },

  destroy: function(id) {
    new Ajax.Request("/assessments/" + id + ".json", {
      method: "delete",
      onComplete: function(transport) {
        var response = transport.responseJSON;
        if(response["success"] == true) {
          var assessment = Assessments.find(id);
          this.remove(assessment)
        } else {
          alert("Kustutamine ebaõnnestus");
        }
      }.bind(this)
    });
  }
});

var Assessment = Class.create({
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


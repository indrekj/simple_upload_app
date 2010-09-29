$(document).ready(function() {
  //Event.observe($("new_file_link"), "click", function() {
  //  setTimeout(function() {initializeAjaxUploader()}, 1500);
  //});

  $(".category").click(function(e) {
    changeCategory(this); 
    return false;
  });

  // Google analytics
  loadScript("http://www.google-analytics.com/ga.js", function() {
    var pageTracker = _gat._getTracker("UA-3366869-2");
    pageTracker._trackPageview();
  });

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
  $("#upload_step_one").show();
  $("#upload_step_two").hide();

  if (categoriesList)
    new Autocompleter.Local("assessment_category_name", "category_list", categoriesList);

  var uuid = randomUUID();
  new AjaxUpload("new_assessment_button", {
    action: "/assessments?format=js&X-Progress-ID=" + uuid + "&callback=uploadStepTwo",
    autoSubmit: true,
    name: "assessment[file]",
    responseType: "json",
    onSubmit: function(file, extension) {
      $("#new_assessment_button").hide();
      interval = window.setInterval(function() {
        fetch(uuid);
      }, 500);
    }
  });
}

function uploadStepTwo(response) {
  if (response.success) {
    assessment = response.data.assessment;
    $("#assessment_title").value = assessment.title;
    $("#assessment_category_name").value = assessment.category_name;

    $("#upload_step_one").hide();
    $("#new_assessment_done_button").show();
    $("#upload_step_two_spinner").hide();
    $("#upload_step_two_failure").hide();
    $("#upload_step_two_success").hide();

    Effect.SlideDown("#upload_step_two", {duration: 1.5});

    Event.observe($("#new_assessment_done_button"), "click", function() {
      new Ajax.Request("/assessments/" + assessment.id + "?format=json", {
        parameters: $("#upload_step_two_form").serialize(true),
        method: "put",
        onLoading: function() {
          $("#upload_step_two_spinner").show();
          $("#new_assessment_done_button").hide();
          $("#upload_step_two_failure").hide();
        },
        onSuccess: function(transport) {
          $("#upload_step_two_spinner").hide();
          var assessment = transport.responseJSON.assessment;
          // Add assessment to list when uploaded to the current category
          //Assessments.loadAssessment(assessment);
          $("#upload_step_two_success").show();
          setTimeout(function() { Modalbox.hide() }, 2000);
        },
        onFailure: function(transport) {
          $("#upload_step_two_spinner").hide();
          $("#upload_step_two_failure").show();
          setTimeout(function() { $("#new_assessment_done_button").show() }, 2000);
        }
      });
    });
  } else {
    $("#upload_step_one").innerHTML = "Miskit failis!";
  }
}

function fetch(uuid) {
  new Ajax.Request("/progress", {
    method: "get",
    requestHeaders: {"X-Progress-ID": uuid, "Accept": "application/json"},
    onComplete: function(transport) {
      var upload = eval(transport.responseText);

      $("#progress").show();

      /* change the width if the inner progress-bar */
      if (upload.state == "uploading") {
        var percentage = 100 * upload.received / upload.size
        $("#progress_percentage").innerHTML = "" + percentage + "%";
      }
    
      /* we are done, stop the interval */
      if (upload.state == "done") {
        $("#progress").hide();
        window.clearTimeout(interval);
      }
    }
  });
}

function changeCategory(category) {
  $("#assessments").hide();
  $("#assessments_spinner").show();

  Assessments.clear();

  $.getJSON(category.href + "&format=json", function(data) {
    // data => category (String), assessments (array)
    $.each(data.assessments, function(i, assessment) {
      assessment = assessment.assessment;

      Assessments.loadAssessment({
        id: assessment.id, 
        title: assessment.title,
        category: data.category, 
        year: assessment.year, 
        author: assessment.author,
        url: unescape(assessment.assessment_path)
      });
    });

    $("#assessments_spinner").hide();
    $("#assessments").show();
    Assessments.show();
  });
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
  $('#categories_cloud').toggle();
}

/***************
 * ASSESSMENTS *
 ***************/
var Assessments = {
  objects: new Array(),

  clear: function() {
    $("#assessments tbody").html("");
    Assessments.objects = new Array();
  },

  show: function() {
    var i = 0;
    $.each(Assessments.objects, function(i, assessment) {
      var parity = i % 2 == 0 ? "even" : "odd";
      var el = "<tr class=" + parity + "><td>" + assessment["title"] + "</td>";
      el += "<td>" + assessment["category"] + "</td>";
      el += "<td>" + assessment["year"] + "</td>";
      el += "<td>" + assessment["author"] + "</td>";
      el += "<td><a href=" + assessment["url"] + ">Vaata</a></td></tr>";

      $("#assessments tbody").append(el);
      i++;
    });
  },

  find: function(id) {
    $.each(Assessments.objects, function(i, assessment) {
      if (assessment.id == id) {
        return assessment;
      }
    });
  },

  loadAssessment: function(options) {
    Assessments.add(new Assessment(options));
  },

  add: function(assessment) {
    Assessments.objects.push(assessment);
  },

  remove: function(assessment) {
    var index = Assessments.objects.indexOf(assessment);
    Assessments.objects.splice(index, index);
    assessment.fade();
  },

  destroy: function(id) {
    new Ajax.Request("/assessments/" + id + ".json", {
      method: "delete",
      onComplete: function(transport) {
        var response = transport.responseJSON;
        if(response["success"] == true) {
          var assessment = Assessments.find(id);
          Assessments.remove(assessment)
        } else {
          alert("Kustutamine ebaõnnestus");
        }
      }
    });
  }
};

var Assessment = function(opts) {
  this.id       = opts["id"];
  this.title    = titlelize(opts["title"]);
  this.category = titlelize(opts["category"]);
  this.year     = opts["year"];
  this.author   = opts["author"];
  this.url      = opts["url"];
};

function titlelize(str) {
  var title = str.split(" ");
  var output = new Array();

  $.each(title, function(i, w) {
    w = w[0, 0].toUpperCase() + w.substring(1);

    if (w.match(/^[ivx]*$/i)) {
      w = w.toUpperCase();
    }

    output.push(w);
  });

  return output.join(" ");
}

function randomUUID() {
  uuid = "";
  for (i = 0; i < 32; i++) {
    uuid += Math.floor(Math.random() * 16).toString(16);
  }
  return uuid;
}

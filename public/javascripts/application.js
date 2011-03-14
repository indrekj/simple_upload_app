$(document).ready(function() {
  if ($("#new_file_link")) {
    $("#new_file_link").fancybox({
      title: "Lisa uus fail",
      titleShow: false,
      modal: false,
      width: 520,
      height: 265,
      showCloseButton: true,
      autoDimensions: false,
      autoScale: false,
      href: "/assessments/new"
    });
  }

  $("#categories_cloud a.category")
    .bind("ajax:success", function(event, data) {
      $("#assessments").html(data);
    })
    .bind("ajax:error", function() {
      alert("some error happened");
    });

  // Google analytics
  $.getScript("http://www.google-analytics.com/ga.js", function() {
    var pageTracker = _gat._getTracker("UA-3366869-2");
    pageTracker._trackPageview();
  });
});

function uploadStepTwo(response) {
  if (response.success) {
    assessment = response.assessment;
    $("#assessment_title").val(assessment.title);
    $("#assessment_category_name").val(assessment.category_name);

    $("#upload_step_one").hide();
    $("#new_assessment_done_button").show();
    $("#upload_step_two_spinner").hide();
    $("#upload_step_two_failure").hide();
    $("#upload_step_two_success").hide();

    $("#upload_step_two").slideDown("slow");

    $("#new_assessment_done_button").click(function() {
      $.ajax({
        url: "/assessments/" + assessment.id + "?format=json",
        type: "PUT",
        dataType: "json",
        data: $("#upload_step_two_form").serialize(true),
        beforeSend: function() {
          $("#upload_step_two_spinner").show();
          $("#new_assessment_done_button").hide();
          $("#upload_step_two_failure").hide();
        },
        success: function(data) {
          $("#upload_step_two_spinner").hide();
          $("#upload_step_two_success").show();
          setTimeout(function() { $.fancybox.close() }, 2000);
        },
        error: function(transport) {
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

function displayCategoriesCloud() {
  $("#categories_cloud").toggle();
}

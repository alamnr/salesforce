/*
 * jQuery v1.9.1 included
 */

$(document).ready(function() {

  // social share popups
  $(".share a").click(function(e) {
    e.preventDefault();
    window.open(this.href, "", "height = 500, width = 500");
  });

  // toggle the share dropdown in communities
  $(".share-label").on("click", function(e) {
    e.stopPropagation();
    var isSelected = this.getAttribute("aria-selected") == "true";
    this.setAttribute("aria-selected", !isSelected);
    $(".share-label").not(this).attr("aria-selected", "false");
  });

  $(document).on("click", function() {
    $(".share-label").attr("aria-selected", "false");
  });

  // show form controls when the textarea receives focus or backbutton is used and value exists
  var $commentContainerTextarea = $(".comment-container textarea"),
      $commentContainerFormControls = $(".comment-form-controls");

  $commentContainerTextarea.one("focus", function() {
    $commentContainerFormControls.show();
  });

  if ($commentContainerTextarea.val() !== "") {
    $commentContainerFormControls.show();
  }

  // Submit requests filter form in the request list page
  $("#request-status-select, #request-organization-select")
    .on("change", function() {
      search();
    });

  // Submit requests filter form in the request list page
  $("#quick-search").on("keypress", function(e) {
    if (e.which === 13) {
      search();
    }
  });

  function search() {
    window.location.search = $.param({
      query: $("#quick-search").val(),
      status: $("#request-status-select").val(),
      organization_id: $("#request-organization-select").val()
    });
  }

  // Submit organization form in the request page
  $("#request-organization select").on("change", function() {
    this.form.submit();
  });
//Begin Humble Squid Category Image Boxes JS Snippet
cat_list = $("ul.category-list li"); // jQuery object containing the category list elements
link_list = $("ul.category-list li a"); // jQuery object containing the category list link elements

// hardcoded array of image assets for use with categories
image_links = [   "//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_Setup.jpg",  "//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_Inventory.jpg", "//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_Project.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_CashIn.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_CashOut.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_GeneralLedger.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_Technical.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_FAQ.jpg",
"//p5.zdassets.com/hc/theme_assets/941342/200224388/Icon_ReleaseNotes.jpg"

];

total_cats = $("ul.category-list li").length; //number of categories we need to iterate over

for (var x = 0; x < total_cats; x++) { //loop to add images to category list elements then strip links of borders and text
    var a_cat = cat_list[x];
    $(a_cat).css({ //adds background images and properties to shrink overlarge backgrounds
        'background-image': 'url(' + image_links[x] + ')',
        'background-size': '100%'
    });
    var a_cat_link = link_list[x];
    $(a_cat_link).text(""); //strip link text...uncomment to enable
    $(a_cat_link).css({
        'border': '0px',
        'width': '100%',
        'height': '100%',
        'margin': '0px',
        'padding': '25%'
    });
}
//End Humble Squid Category Image Boxes JS Snippet

});

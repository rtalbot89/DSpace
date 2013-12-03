$(document).ready(function(){
    //test for a cp-preview link if this is the item view page
    if ($("#cp-preview").length !== 0) {
        $("#cp-preview").bind("click", function(){packagePreview($("#cp-preview").attr("data-href"),"modal");});
         $( "#cp-preview" ).button({
      icons: {
        primary: "ui-icon-newwin"
      }});
    }
    //test if it's the full preview page
     if ($("#cp-preview-full").length !== 0) {
        packagePreview($("#cp-preview-full").attr("data-href"),"full");
    } 
});

function packagePreview(manUrl, mode){
    //remove anything left over
    $( ".cp-menu > h3" ).remove();
    $( ".cp-menu > ul" ).remove();
    var baseUrl = manUrl.substring(0, manUrl.indexOf('imsmanifest.xml'));
    $.get( manUrl, function( xml ) {
        var organizations = $('organization', xml);
        var firstLink = $(organizations).children("item").attr("identifierref");
        var firstPage = baseUrl + $("resource[identifier='"+  firstLink +"']", xml).attr("href");
        var iFrame = $("iframe#viewHolder");
        iFrame.attr("src", firstPage);
        if (mode === 'modal') {
            iFrame.load(function(){
                $( "#dialog-modal" ).dialog({
                    width: "auto",
                    height: "auto",
                    modal: true
                }); 
            }); 
        }
        
        $.each(organizations, function(){
            var items = $(this).children('item');
            
            if (items.length > 1) {
                $(".cp-menu").append('<h3>' + $(this).children("title").text() + '</h3>');
                var list = $("<ul/>");
                $(".cp-menu").append(list);
                $.each(items, function(){
                    var link = baseUrl + $("resource[identifier='"+ $(this).attr("identifierref")+"']", xml).attr("href");
                    var title = $(this).children('title').text();
                    var listElement = $("<li/>");
                    
                    $(listElement).bind("click", function(event){
                        event.preventDefault();
                        list.children("li").removeClass('cp-on');
                        $("#viewHolder").attr("src",link);
                        $(this).addClass('cp-on'); 
                    });
                    
                    $(listElement).append("<a href='" + link + "'>" + title + "</a>");
                    list.append(listElement);
                });
                
                $(".cp-menu ul li:first-child").addClass('cp-on');
            }
        });
    });  
}

//fake API for SCORM packages
window.API = (function(){
  var data = {
    "cmi.core.student_id": "000000",
    "cmi.core.student_name": "Student, Joe",
    "cmi.core.lesson_location": "",
    "cmi.core.lesson_status": "not attempted"
  };
  return {
    LMSInitialize: function() {
      return "true";  
    },
    LMSCommit: function() {
      return "true";  
    },
    LMSFinish: function() {
      return "true";  
    },
    LMSGetValue: function(model) {
      return data[model] || "";
    },
    LMSSetValue: function(model, value) {
      data[model] = value;
      return "true";
    },
    LMSGetLastError: function() {
      return "0";
    },
    LMSGetErrorString: function(errorCode) {
      return "No error";
    },
    LMSGetDiagnostic: function(errorCode) {
      return "No error";
    }
  };
})();
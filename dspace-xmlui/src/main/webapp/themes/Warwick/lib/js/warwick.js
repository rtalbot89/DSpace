$(document).ready(function(){
    //test for a cp-preview id
    if ($("#cp-preview")) {
        var manUrl = $("#cp-preview").attr("href");
        $("#cp-preview").bind("click", function(){packagePreview(manUrl);});
    }
});

function packagePreview(manUrl){
    event.preventDefault();
    //remove anything left over
    $( "#dialog-modal > h3" ).remove();
    $( "#dialog-modal > ul" ).remove();
    var baseUrl = manUrl.substring(0, manUrl.indexOf('imsmanifest.xml'));
    //console.log("fired main");
    $.get( manUrl, function( xml ) {
        //console.log("get ran");
        var organizations = $('organization', xml);
        var firstLink = $(organizations).children("item").attr("identifierref");
        var firstPage = baseUrl + $("resource[identifier='"+  firstLink +"']", xml).attr("href");
        var iFrame = $("iframe#viewHolder");
        iFrame.attr("src", firstPage);
        iFrame.load(function(){
            if ((iFrame.attr("src") === firstPage) &&($(this).contents().width() > 200) ){
                console.log("iframe load run");
                var contentWidth = $(this).contents().width();
                $(this).width(contentWidth);
                var contentHeight = $(this).contents().height();
                //$(".cp-menu").height(contentHeight);
                $(this).height(contentHeight);
                $( "#dialog-modal" ).dialog({
                    width: "auto",
                    height: "auto",
                    modal: true
                }); 
            }
        }); 
        
        $.each(organizations, function(){
            $(".cp-menu").append('<h3>' + $(this).children("title").text() + '</h3>');
            //$('<h3>' + $(this).children("title").text() + '</h3>').insertBefore("#viewHolder");
            var items = $(this).children('item');
            var list = $("<ul/>");
            //list.attr("class", "cp-menu");
            if (items.length > 0) {
                $(".cp-menu").append(list);
                //$(list).insertBefore("#viewHolder");
            }
            $.each(items, function(){
                var link = baseUrl + $("resource[identifier='"+ $(this).attr("identifierref")+"']", xml).attr("href");
                var title = $(this).children('title').text();
                var listElement = $("<li/>");
                $(listElement).bind("click", function(event){
                    event.preventDefault();
                    $("#viewHolder").attr("src",link);
                    $("#viewHolder").load(function(){
                        var contentWidth = $(this).contents().width();
                        $(this).width(contentWidth);
                        var contentHeight = $(this).contents().height();
                        $(this).height(contentHeight);
                    });
                    
                });
                $(listElement).append("<a href='" + link + "'>" + title + "</a>");
                list.append(listElement);
            });
        });       
    });  
}
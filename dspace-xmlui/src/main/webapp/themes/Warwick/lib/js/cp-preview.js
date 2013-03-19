/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */

$(document).ready(function(){
    $("#cp-menu li").bind("click", function(event){
         event.preventDefault();
   // console.log($(this).find("a").attr("href"));
    var newUrl = $(this).find("a").attr("href");
  //  $("#viewHolder").attr("src",'');
  $("#viewHolder").attr("src",newUrl);
  
});
});
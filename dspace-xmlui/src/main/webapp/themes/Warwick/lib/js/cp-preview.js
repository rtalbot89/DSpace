/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
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
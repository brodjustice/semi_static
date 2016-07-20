
// Handle the fact that you may need multipl onload events
// Allows semi static code to add extra onload events via the addSemiStaticLoadEvent(func)

function addSemiStaticLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function'){ window.onload=func;}else{ window.onload=function(){ if (oldonload){oldonload();}func();} }
}

addSemiStaticLoadEvent(function() {
  if(/iPhone|iPad|iPod/i.test(navigator.userAgent)){ document.getElementById("slide-menu-wrapper").style.WebkitTransition = 'none'; }
});



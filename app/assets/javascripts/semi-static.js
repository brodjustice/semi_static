function semiStaticSlideOpenMenu(){
  var menuWrapper = document.getElementById('slide-menu-window');
  if(menuWrapper != null){menuWrapper.classList.add('open')}else{false}
  window.scrollTo(0, 0);
}
function semiStaticSlideCloseMenu(){
  var menuWrapper = document.getElementById('slide-menu-window');
  if(menuWrapper!= null){menuWrapper.classList.remove('open')}else{false}
}

function semiStaticGetPR(){ var pr; try {pr=window.devicePixelRatio} catch(err){pr=1} return(pr); }

// Cause a click anywhere to remove photo popup dialog
function semiStaticPopOff(){
  var d=document.getElementById("dialog");
  d.className = d.className.replace(/^popped$/, "\\");
  d.style.display="none";
  d.innerHTML = '';
  document.getElementById("body-inner").style.opacity="1.0";
}

function semiStaticAJAX(url){
  var xhr = new XMLHttpRequest();
  var token = document.querySelector('meta[name="csrf-token"]').content

  // Note: Params assume that an additional, "?" already exists
  url=url + '&pratio=' + parseInt(semiStaticGetPR());
  xhr.open('GET', encodeURI(url));

  //
  // Contruct headers that will be accepted by Rails 5 strict CSRF policy
  // Token may be invalid/stale for static pages, however Rails 5 still
  // requires a token even for a GET, but does not check it's validity
  // 
  xhr.setRequestHeader('X-CSRF-Token', token)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  xhr.setRequestHeader("Accept", "text/javascript");
  xhr.onload = function() { if (xhr.status === 200) { eval(xhr.responseText); } };
  xhr.send();
}

function addSemiStaticLoadEvent(func) {
  var oldonload = window.onload;
  if(typeof window.onload != 'function'){ window.onload = func;}else{
    window.onload=function(){if(oldonload){oldonload();}func();
    }
  }
}

var menuSub = document.getElementById('menu-sub');
function semiStaticSlideOpenMenu(){
  var menuWrapper = document.getElementById('slide-menu-window');
  if(menuWrapper != null){menuWrapper.classList.add('open')}else{false}
  window.scrollTo(0, 0);
}
function semiStaticSlideCloseMenu(){
  var menuWrapper = document.getElementById('slide-menu-window');
  if(menuWrapper!= null){menuWrapper.classList.remove('open')}else{false}
}
function semiStaticOpenMenu(){
  if (!semiStaticSlideOpenMenu()){ 
    document.getElementById('menu').style.display='block';
    document.getElementById('bar-menu').style.display='block';
    if (menuSub != null) { menuSub.style.display='block'; }
    document.getElementById('menu-close').style.display='block';
    document.getElementById('menu-button').style.display='none';
  }
}
function semiStaticCloseMenu(){
  if (!semiStaticSlideCloseMenu()){ 
    document.getElementById('menu').style.display='none';
    document.getElementById('bar-menu').style.display='none';
    if (menuSub != null) { menuSub.style.display='none'; }
    document.getElementById('menu-close').style.display='none';
    document.getElementById('menu-button').style.display='block';
  }
}
function semiStaticGetPR(){ var pr; try {pr=window.devicePixelRatio} catch(err){pr=1} return(pr); }
function semiStaticAJAX(url){
  var xhr = new XMLHttpRequest();
  // Note: Params assume that an additional, "?" already exists
  url=url + '&pratio=' + parseInt(semiStaticGetPR());
  xhr.open('GET', encodeURI(url));
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

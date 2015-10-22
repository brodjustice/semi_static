var menuSub = document.getElementById('menu-sub');
function semiStaticOpenMenu(){
  document.getElementById('menu').style.display='block';
  document.getElementById('bar-menu').style.display='block';
  if (menuSub != null) { menuSub.style.display='block'; }
  document.getElementById('menu-close').style.display='block';
  document.getElementById('menu-button').style.display='none';
}
function semiStaticCloseMenu(){
  document.getElementById('menu').style.display='none';
  document.getElementById('bar-menu').style.display='none';
  if (menuSub != null) { menuSub.style.display='none'; }
  document.getElementById('menu-close').style.display='none';
  document.getElementById('menu-button').style.display='block';
}

function semiStaticGetPR(){
  var pr;
  try {pr=window.devicePixelRatio} catch(err){pr=1}
  return(pr);
}

function semiStaticAJAX(url){
  var xhr = new XMLHttpRequest();
  // Note: Params assume they are additional, "?" already exists
  url=url + '&pratio=' + parseInt(semiStaticGetPR());
  xhr.open('GET', encodeURI(url));
  xhr.setRequestHeader("Accept", "text/javascript");
  xhr.onload = function() {
    if (xhr.status === 200) { eval(xhr.responseText); }
    else { alert('Request failed.  Returned status of ' + xhr.status); }
  };
  xhr.send();
}

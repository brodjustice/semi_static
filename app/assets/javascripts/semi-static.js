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

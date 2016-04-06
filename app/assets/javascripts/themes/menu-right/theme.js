function semiStaticSlideOpenMenu(){
  var menuWrapper = document.getElementById('slide-menu-wrapper');
  menuWrapper.classList.add('visible');
  menuWrapper.classList.add('open');
}
function semiStaticSlideCloseMenu(){
  var menuWrapper = document.getElementById('slide-menu-wrapper');
  menuWrapper.classList.remove('open');
  menuWrapper.classList.remove('visible');
}


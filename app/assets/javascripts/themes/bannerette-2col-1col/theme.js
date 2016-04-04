function semiStaticSlideOpenMenu(){
  var menuWrapper = document.getElementById('slide-menu-wrapper');
  menuWrapper.style.right='0px';
  menuWrapper.classList.add('shadow');
}
function semiStaticSlideCloseMenu(){
  var menuWrapper = document.getElementById('slide-menu-wrapper');
  menuWrapper.style.right='-412px';
  menuWrapper.classList.remove('shadow');
}

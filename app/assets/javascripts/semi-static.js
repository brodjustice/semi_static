function semiStaticLoading(){
  var el = document.getElementById('menu-loading'),
    i = 0,
    load = setInterval(function() {
      i = ++i % 10;
      el.innerHTML = '&#9609' + Array(i + 1).join('&#9609;');
  }, 600);
  document.getElementById('menu-main').style.display='none';
  document.getElementById('menu-close').style.display='none';
  document.getElementById('bar-in-menu').style.display='none';
  document.getElementById('menu').style.display='block';
  true
}

function semiStaticOpenMenu(){
  document.getElementById('menu').style.display='block';
  document.getElementById('menu-close').style.display='block';
  document.getElementById('bar-in-menu').style.display='block';
  document.getElementById('menu-button').style.display='none';
}
function semiStaticCloseMenu(){
  document.getElementById('menu').style.display='none';
  document.getElementById('menu-close').style.display='none';
  document.getElementById('bar-in-menu').style.display='none';
  document.getElementById('menu-button').style.display='block';
}

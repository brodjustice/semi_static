/* 
  iPad, iPhone, Safarir or Chrome do not handle the resize of the vw css
  on orientation change as one would expect. So repaint the body html
  when we detect an orientation change.
*/
(function(w){

    var ua = navigator.userAgent;

    if(!( /iPhone|iPad|iPod/i.test(navigator.userAgent)) ) {
      return;
    }

    var doc = w.document;

    function semiStaticRepaint(){
      var sel;
      sel = document.getElementById("body-inner")
      sel.style.display='none';
      sel.offsetHeight; // no need to store this anywhere, the reference is enough
      sel.style.display='';
    }

    w.addEventListener( "orientationchange", semiStaticRepaint, false );

})( this );

function semiStaticTilesLoading(){
  var el = document.getElementById('menu-loading'),
    i = 0,
    load = setInterval(function() {
      i = ++i % 10;
      el.innerHTML = '&#9609' + Array(i + 1).join('&#9609;');
  }, 600);
  setInterval(function(){
    document.getElementById('menu').style.display='block';
    document.getElementById('menu').style.borderWidth='0';
    document.getElementById('menu-main').style.display='none';
    document.getElementById('bar-in-menu').style.display='none';
    document.getElementById('menu').style.display='block';
    document.getElementById('menu-loading-wrapper').style.display='block';
    document.getElementById('menu-loading').style.display='block';
  }, 1000);
  true
}

function callback(e) {
    var e = window.e || e;

    if (e.target.className.match(/semi-static-loading/)) {
      semiStaticTilesLoading();
    } else {
      return;
    }
}

if (document.addEventListener)
  document.addEventListener('click', callback, false);
else
  document.attachEvent('onclick', callback);


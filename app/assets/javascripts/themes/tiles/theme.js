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

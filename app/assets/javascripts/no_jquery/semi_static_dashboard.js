// Minimize left menu
function init___dashboard(){
  document.querySelector('.app-sidebar__toggle').addEventListener('click', e => {
    e.preventDefault();
    document.querySelectorAll('.app').forEach((el, i) => {
      if(el.classList.contains('sidenav-toggled')){
        el.classList.remove('sidenav-toggled')
      } else {
        el.classList.add('sidenav-toggled')
      }
    });
  });
}

addSemiStaticLoadEvent(init___dashboard);

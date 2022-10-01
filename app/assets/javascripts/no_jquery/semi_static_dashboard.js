function init___dashboard(){

  document.querySelectorAll('.app').forEach((el, i) => {
    if(document.cookie.indexOf('sidenav=') == -1){
      el.classList.remove('sidenav-toggled')
    } else {
      document.querySelector('.app-sidebar').style.transition = 'none';
      el.classList.add('sidenav-toggled')
    }
  });

  document.querySelector('.app-sidebar__toggle').addEventListener('click', e => {
    e.preventDefault();
    document.querySelectorAll('.app').forEach((el, i) => {
      if(el.classList.contains('sidenav-toggled')){
        el.classList.remove('sidenav-toggled')
        document.cookie = 'sidenav=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;'; 
      } else {
        el.classList.add('sidenav-toggled')
        document.cookie = 'sidenav=toggled; path=/'; 
      }
    });
  });

  document.querySelectorAll("[data-toggle='dropdown']").forEach((el, i) => {
    el.addEventListener('click', e => {
      e.preventDefault();
      document.querySelectorAll('.dropdown-menu').forEach((el, i) => {
        if(el.classList.contains('show')){
          el.classList.remove('show');
        } else {
          el.classList.add('show');
        }
      });
    });
  });

  // Set event handler for info-help
  document.getElementById('help-info-button').addEventListener('click', function(){
    if(document.body.classList.contains('show-help-info')){
      document.body.classList.remove('show-help-info');
    } else {
      document.body.classList.add('show-help-info');
    }
  });
}

addSemiStaticLoadEvent(init___dashboard);

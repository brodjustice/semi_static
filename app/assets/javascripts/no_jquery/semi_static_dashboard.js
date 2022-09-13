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

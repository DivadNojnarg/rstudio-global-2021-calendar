$(document).on('click', '.btn-talk-more-info, .btn-talk-more-info i', function(ev) {
  Shiny.setInputValue('talk_more_info', ev.target.closest('.button').dataset.value, {priority: 'event'});
});

$(document).on('shiny:sessioninitialized', function() {
  Shiny.setInputValue('browser_tz', Intl.DateTimeFormat().resolvedOptions().timeZone);
});

$(document).on('shiny:sessioninitialized', function() {
  setTimeout(function() {
    $('.rt-pagination-nav').addClass('display-flex justify-content-space-between align-items-flex-start');
  }, 1500);
});


Shiny.addCustomMessageHandler('global-theme-setup', function(message) {
  app.methods.toggleDarkTheme();
  if (message === 'light') {
    $('.page').css('background-color', 'gainsboro');
    $('.swipe-handler').css('background-color', '');
    $('.sheet-modal').css('background-color', '#fff');
  } else {
    $('.page').css('background-color', '#1b1b1d');
    $('.swipe-handler').css('background-color', '#1b1b1d');
    $('.sheet-modal').css('background-color', '#1b1a1d');
  }
});


$(function(){
  $('.bg-color-white').on('click', function() {
    $('#globalThemeLight').prop('checked', true);
    if ($('#globalThemeDark').prop('checked')) {
      $('#globalThemeDark').prop('checked', false);
    }
    $('#globalThemeDark').addClass('disabled');
    Shiny.setInputValue('globalTheme', 'light');
  });

  $('.bg-color-black').on('click', function() {
    $('#globalThemeDark').prop('checked', true);
    if ($('#globalThemeLight').prop('checked')) {
      $('#globalThemeLight').prop('checked', false);
    }
    $('#globalThemeLight').addClass('disabled');
    Shiny.setInputValue('globalTheme', 'dark');
  });
});

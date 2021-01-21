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

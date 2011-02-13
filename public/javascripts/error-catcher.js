var browserName = function(browser) {
  if (browser.msie) {
    return "Microsoft Internet Explorer"
  } else if (browser.safari) {
    return "WebKit Safari"
  } else if (browser.mozilla) {
    return "Mozilla Firefox"
  } else {
    return "Unknown"
  }
};

window.onerror = function(message, url, lineNumber) {
  $.ajax({
    type: "POST",
    url: "/errors",
    data: {
      error: {
        browser_name    : browserName($.browser),
        browser_version : $.browser.version,
        message         : message, 
        location        : url,
        line_number     : lineNumber
      }
    }
  });
};

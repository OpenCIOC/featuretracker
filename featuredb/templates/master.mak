<!doctype html>
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!-- Consider adding an manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
  <meta charset="utf-8">

  <!-- Use the .htaccess and remove these lines to avoid edge case issues.
       More info: h5bp.com/b/378 -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title><%block name="title"/></title>
  <meta name="description" content="">
  <meta name="author" content="">

  <!-- Mobile viewport optimized: j.mp/bplateviewport -->
  <meta name="viewport" content="width=device-width,initial-scale=1">

  <!-- Place favicon.ico and apple-touch-icon.png in the root directory: mathiasbynens.be/notes/touch-icons -->

  <!-- CSS: implied media=all -->
  <!-- CSS concatenated and minified via ant build script-->
  <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/redmond/jquery-ui.css" type="text/css" />
  <link rel="stylesheet" href="/static/css/style.css">
  <style type="text/css">
    /* fix the broken font handling in default jquery-ui styles */
    .ui-widget {
        font-family: inherit;
        font-size: 1em;
    }
  </style>
  <!-- end CSS-->

  <!-- More ideas for your <head> here: h5bp.com/d/head-Tips -->

  <!-- All JavaScript at the bottom, except for Modernizr / Respond.
       Modernizr enables HTML5 elements & feature detects; Respond is a polyfill for min/max-width CSS3 Media Queries
       For optimal performance, use a custom Modernizr build: www.modernizr.com/download/ -->
  <script src="/static/js/libs/modernizr-1.7.min.js"></script>
</head>

<body>

<header class="ui-widget-header" style="padding-left: 1em;">
<nav class="site-nav"><%block name="sitenav">
<%block name="newsearch"><a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_url('search_index')}"><span class="ui-icon ui-icon-search ui-button-icon-primary"></span><span class="ui-button-text">New Search</span></a></%block>
%if request.user:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('suggest')}"><span class="ui-icon ui-icon-comment ui-button-icon-primary"></span><span class="ui-button-text">New Request</span></a> 
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('logout')}"><span class="ui-icon ui-icon-power ui-button-icon-primary"></span><span class="ui-button-text">Logout</span></a>
%else:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('login')}"><span class="ui-icon ui-icon-power ui-button-icon-primary"></span><span class="ui-button-text">Login</span></a>
%endif
</%block>
</nav>
<h1 style="margin: 0;">CIOC Feature Request Database</h1></header>
<div class="colmask rightmenu">
<div class="colleft">
  <div class="col1wrap">
  <div id="container" class="col1">
    <header>
	<h1 class="clearfix"><%block name="searchnav"/>${self.title()}</h1>
	

    </header>
    <div id="main" role="main">
	<% message = request.session.pop_flash() %>
	%if message:
		<div class="ui-widget error-notice clearfix">
			<div class="ui-state-highlight ui-corner-all error-notice-wrapper"> 
				<p><span class="ui-icon ui-icon-info error-notice-icon"></span> ${message[0]} </p>
			</div>
		</div>
	%endif

    ${next.body()}

    </div>
    <footer>

    </footer>
  </div> <!--! end of #container -->
  </div>
  <%block name="priority_mgmt"/>
</div>
</div>


  <!-- JavaScript at the bottom for fast page loading -->

  <!-- Grab Google CDN's jQuery, with a protocol relative URL; fall back to local if offline -->
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
  <script>window.jQuery || document.write('<script src="/js/libs/jquery-1.6.2.min.js"><\/script>')</script>
  <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>

  
  <!-- scripts concatenated and minified via ant build script-->
  <script defer src="/static/js/plugins.js"></script>
  <script defer src="/static/js/libs/json2.min.js"></script>
  <script defer src="/static/js/script.js"></script>
  <!-- end scripts-->
  
  <%block name="bottomscripts"/>
	
</body>
</html>

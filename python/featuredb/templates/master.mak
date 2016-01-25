<!doctype html>
<%doc>
  =========================================================================================
   Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
  =========================================================================================
</%doc>

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
  <link rel="shortcut icon" type="image/x-icon" href="/favicon.ico" />

  <!-- CSS: implied media=all -->
  <!-- CSS concatenated and minified via ant build script-->
  <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/themes/redmond/jquery-ui.css" type="text/css" />
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
  <script src="/static/js/libs/modernizr-2.0.6-custom.min.js"></script>
</head>

<%block name="body_open_tag">
<body>
</%block>

<header class="ui-widget-header" style="padding-left: 1em;">
<nav class="site-nav"><%block name="sitenav">
<%block name="newsearch"><a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_url('search_index')}"><span class="ui-icon ui-icon-search ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">New Search</span></a></%block>
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('report')}"><span class="ui-icon ui-icon-signal ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Ranking Report</span></a> 
%if request.user:
  %if request.user.TechAdmin:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('suggestions')}"><span class="ui-icon ui-icon-document ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Suggestions</span></a>   
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('concerns')}"><span class="ui-icon ui-icon-alert ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Concerns</span></a> 
  %endif
  %if request.user.TechAdmin:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('enhancementupdate',action='add')}"><span class="ui-icon ui-icon-comment ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">New Request</span></a>  
  %else:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('suggest')}"><span class="ui-icon ui-icon-comment ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">New Request</span></a>
  %endif
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('account')}"><span class="ui-icon ui-icon-person ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Account</span></a>
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('logout')}"><span class="ui-icon ui-icon-power ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Logout</span></a>
%else:
<a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon-primary" href="${request.route_path('login')}"><span class="ui-icon ui-icon-power ui-button-icon-primary" aria-hidden="true"></span><span class="ui-button-text">Login</span></a>
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
				<p><span class="ui-icon ui-icon-info error-notice-icon">Notice</span> ${message[0]} </p>
			</div>
		</div>
	%endif

    ${next.body()}

    </div>
    <footer>
	<% email_messages = request.session.pop_flash('email_messages') %>
	%if email_messages:
			<div>
		%for message in email_messages:
				${message}
		%endfor
			</div>
	%endif
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

<%def name="makeMgmtInfo(model, show_created=True, show_modified=True)">
<% _ = lambda x: x %>
%if show_created:
<%
	created_date = getattr(model, 'CREATED_DATE', None)
	created_by = getattr(model, 'CREATED_BY', None) or _('Unknown')
%>
<tr>
    <td class="ui-widget-header field">${_('Date Created')}</td>
    <td class="ui-widget-content">${request.format_date(created_date) if created_date else _('Unknown')} (${_('set automatically')})</td>
</tr>
<tr>
    <td class="ui-widget-header field">${_('Created By')}</td>
    <td class="ui-widget-content">${created_by} (${_('set automatically')})</td>
</tr>

%endif
%if show_modified:
<%
	modified_date = getattr(model, 'MODIFIED_DATE', None)
	modified_by = getattr(model, 'MODIFIED_BY', None) or _('Unknown')
%>
<tr>
    <td class="ui-widget-header field">${_('Last Modified')}</td>
    <td class="ui-widget-content">${request.format_date(modified_date) if modified_date else _('Unknown')} (${_('set automatically')})</td>
</tr>
<tr>
    <td class="ui-widget-header field">${_('Last Modified By')}</td>
    <td class="ui-widget-content">${modified_by} (${_('set automatically')})</td>
</tr>

%endif
</%def>

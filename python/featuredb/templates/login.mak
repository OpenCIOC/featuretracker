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

<%inherit file="master.mak"/>
<%block name="title">Login</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form action="${request.route_path('login')}" method='post'>
<table class="form-table">
<tr>
	<td class="ui-widget-header">${renderer.label('email', 'Email:')}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('email')}
		${renderer.email('email')}
	</td>
</tr>
<tr>
	<td class="ui-widget-header">${renderer.label('password', 'Password:')}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('password')}
		${renderer.password('password', maxlength=None)}
	</td>
</tr>
</table>
<br>
<input type="Submit" value="Login">
</form>


<p>Don't have a password yet? <a href="${request.route_path('register')}">Tell us about yourself</a> or <a href="${request.route_url('search_index', _query=[('bypass_login', 'on')])}">go right to the enhancements</a>.
<br>Forgot your password? <a href="${request.route_path('pwreset')}">Reset it</a>.</p>

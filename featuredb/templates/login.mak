<%inherit file="master.mak"/>
<%block name="title">Login</%block>
<%block name="newsearch"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form action='' method='post'>
<table>
<tr>
	<td class="ui-widget-header">${renderer.label('email', 'Email:')}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('email')}
		${renderer.text('email', size=40, maxlength=60)}
	</td>
</tr>
<tr>
	<td class="ui-widget-header">${renderer.label('password', 'Password:')}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('password')}
		${renderer.password('password', size=40, maxlenght=None)}
	</td>
</tr>
</table>
<input type="Submit" value="Login">
</form>


<p>Don't have a password yet? <a href="${request.route_path('register')}">Tell us about yourself</a> or <a href="${request.route_url('search_index', _query=[('bypass_login', 'on')])}">go right to the enhancements</a>.</p>

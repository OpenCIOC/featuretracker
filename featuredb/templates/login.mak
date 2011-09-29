<%inherit file="master.mak"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<h1>Login</h1>
<form action='' method='post'>
<table>
<tr>
	<td class="ui-widget-header">${renderer.label('email', 'Email:')}</td>
	<td class="ui-widget-content">${renderer.text('email', size=40, maxlength=60)}</td>
</tr>
<tr>
	<td class="ui-widget-header">${renderer.label('password', 'Password:')}</td>
	<td class="ui-widget-content">${renderer.password('email', size=40, maxlenght=None)}</td>
</tr>
</table>
</form>

<p>Don't have a password yet? <a href="${request.route_url('register')}">Tell us about yourself</a> or <a href="${request.route_url('search_index', _query=[('bypass_login', 'on')])}">go right to the enhancements</a>.</p>

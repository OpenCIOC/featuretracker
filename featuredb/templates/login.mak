<%inherit file="master.mak"/>
<%block name="title">Login</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form action='' method='post'>
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
		${renderer.password('password', maxlenght=None)}
	</td>
</tr>
</table>
<br>
<input type="Submit" value="Login">
</form>


<p>Don't have a password yet? <a href="${request.route_path('register')}">Tell us about yourself</a> or <a href="${request.route_url('search_index', _query=[('bypass_login', 'on')])}">go right to the enhancements</a>.</p>

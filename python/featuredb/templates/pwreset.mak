<%inherit file="master.mak"/>
<%block name="title">${'Password Reset'}</%block>
<%block name="sitenav"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form action="${request.current_route_path(_form=True)}" method="post">
<div class="hidden">
${renderer.hidden('came_from')}
</div>
<table class="form-table">
<tr>
	<td class="ui-widget-header">${renderer.label('Email', 'Email: ')}</td>
	<td class="ui-widget-content">
		${renderer.errorlist('Email')}
		${renderer.text('Email')}
	</td>
</tr>
</table>
<br>
<input type="submit" value="${'Email New Password'}">
</form>


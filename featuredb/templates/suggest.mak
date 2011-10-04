<%inherit file="master.mak"/>
<%block name="title">Enhancement Suggestion</%block>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form method="post" action="${request.route_url('suggest')}">
	<table class="form-table">
		<tr>
			<td class="ui-widget-header">${renderer.label('Suggestion', 'Your Enhancement Suggestion')}</td>
			</tr>
		<tr>
			<td class="ui-widget-content">
				${renderer.errorlist('Suggestion')}
				${renderer.textarea('Suggestion')}
			</td>
		</tr>
	</table>
<br>
<input type="submit" value="Submit">
</form>


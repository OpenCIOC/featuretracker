<%inherit file="master.mak"/>
<%block name="title">Account</%block>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form method="post" action="${request.route_url('enhancementupdate', action='add' if is_add else 'edit')}">
	<table class="form-table">
	<tr>
		<td class="ui-widget-header">${renderer.label('Title', 'Title')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('Title')}
			${renderer.text('Title', maxlength=255)}
			</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('Basic Description', 'Description')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('BasicDescription')}
			${renderer.textarea('BasicDescription')}
			</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('AdditionalNotes', 'Notes')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('AdditionalNotes')}
			${renderer.textarea('AdditionalNotes')}
			</td>
	</tr>
</table>
<br>
<input type="submit" value="Submit">
</form>


<%inherit file="master.mak"/>
<%block name="title">Register</%block>
<%block name="newsearch"/>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form method="post" action="${request.route_url('register')}">
	<table class="form-table">
		<tr>
			<td class="ui-widget-header">${renderer.label('Email', 'Email Address')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Email')}
				${renderer.text('Email', size=60, maxlength=60, type="email")}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Password', 'Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Password')}
				${renderer.password('Password', size=60)}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('ConfirmPassword', 'Confirm Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ConfirmPassword')}
				${renderer.password('ConfirmPassword', size=60)}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Member', 'CIOC Membership')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Member')}
				${renderer.select('Member', options=[('','')] + members )}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('TomorrowsDate', 'Tomorrows Date')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('TomorrowsDate')}
				${renderer.text('TomorrowsDate', size=60, maxlength=60)}
				<div class="field-help">Enter tomorrow's date as dd/mm/yyyy to help prevent spammers</div>
			</td>
		</tr>
		<tr><td colspan="2" class="ui-state-default" style="text-align: center">Optional Info</td></tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Agency', 'CIOC Agency')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Agency')}
				${renderer.select('Agency', options=[('','')] + agencies)}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('OrgName', 'Organization Name')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('OrgName')}
				${renderer.text('OrgName', maxlength=50 )}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('FirstName', 'First Name')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('FirstName')}
				${renderer.text('FirstName', maxlength=50 )}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('LastName', 'Last Name')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('LastName')}
				${renderer.text('LastName', maxlength=50 )}
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>


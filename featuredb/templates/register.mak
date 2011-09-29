<%inherit file="master.mak"/>
<%block name="title">Register</%block>
<%block name="newsearch"/>

<% renderer = request.model_state.renderer %>
<form method="post" action="${request.route_url('register')}">
	<table>
		<tr>
			<td class="ui-widget-header">${renderer.label('Email', 'Email Address')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('email')}
				${renderer.text('email', size=60, maxlength=60)}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Password', 'Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('password')}
				${renderer.password('password', size=60)}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('ConfirmPassword', 'Confirm Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ConfirmPassword')}
				${renderer.password('ConfirmPassword', size=60)}
			</td>
		</tr>
		<tr><td colspan="2" class="ui-widget-header" style="text-align: center">Optional Info</td></tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Member', 'CIOC Membership')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Member')}
				${renderer.select('Member', options=[('',''), ('', 'A nice member')] )}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Agency', 'CIOC Agency')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Agency')}
				${renderer.select('Agency', options=[('',''),('GOO', 'A nice Agency')] )}
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
				${renderer.errorlist('LastName')}
				${renderer.text('LastName', maxlength=50 )}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('FirstName', 'Last Name')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('LastName')}
				${renderer.text('LastName', maxlength=50 )}
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>


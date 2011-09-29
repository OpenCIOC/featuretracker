<%inherit file="master.mak">

<h1>Register</h1>

<form method="post" action="${request.route_url('home', action='register')}">
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
				${renderer.password('password', size=60))}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('ConfirmPassword', 'Confirm Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ConfirmPassword')}
				${renderer.password('ConfirmPassword', size=60))}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Member', 'CIOC Membership')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Member')}
				${renderer.select('Member', options=[('','')] )}
				</td>
		</tr>
		<% priorities_formatted = [('','')] + [(p.PRIORITY_ID, p.PriorityName) for p in priorities] %>
		<tr>
			<td class="ui-widget-header">${renderer.label('UserPriority', 'My Rating')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('UserPriority')}
				${renderer.select('UserPriority', options=priorities_formatted)}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Estimate', 'Estimate')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Estimate')}
				${renderer.select('Estimate', options=[('','')] + map(tuple, estimates))}
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>


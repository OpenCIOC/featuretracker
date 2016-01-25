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
<%block name="title">Account</%block>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form method="post" action="${request.route_url('account')}">
	<table class="form-table">
		<tr>
			<td class="ui-widget-header">${renderer.label('Email', 'Email Address')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Email')}
				${renderer.email('Email')}
			</td>
		</tr>
		<tr><td colspan="2" class="ui-state-default" style="text-align: center">Optional Info</td></tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Member', 'CIOC Membership')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Member')}
				${renderer.select('Member', options=[('','')] + members )}
				</td>
		</tr>
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
				${renderer.text('OrgName')}
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
				${renderer.text('LastName')}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">Email Settings</td>
			<td class="ui-widget-content">
				${renderer.errorlist('EmailOnNew')}
				${renderer.checkbox('EmailOnNew', label=' Send me an email when new enhancements are added.')}<br>
				${renderer.errorlist('EmailOnUpdate')}
				${renderer.checkbox('EmailOnUpdate', label=' Send me an email when enhancements I\'ve ranked are updated.')}
				</td>
		</tr>
		<tr><td colspan="2" class="ui-state-default" style="text-align: center">Change Password</td></tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Password', 'Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Password')}
				${renderer.password('Password')}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('ConfirmPassword', 'Confirm Password')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ConfirmPassword')}
				${renderer.password('ConfirmPassword')}
			</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>


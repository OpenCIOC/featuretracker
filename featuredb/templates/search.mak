<%inherit file="priority.mak"/>
<%!
from itertools import izip_longest
def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)
%>
<%block name="title">Search for Features</%block>
<%block name="newsearch"/>
<% 
model_state = request.model_state 
renderer = model_state.renderer
%>
${renderer.error_notice()}
<h2 class="ui-state-default ui-corner-all search-type">Advanced Search</h2>
<form method="get" action="${request.route_url('search_results')}">
	<table class="form-table">
		<tr>
			<td class="ui-widget-header">${renderer.label('Terms', 'Full-Text Search')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Terms')}
				${renderer.text('Terms', size=50, maxlength=100)}
			</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Keyword', 'Keyword')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Keyword')}
				${renderer.select('Keyword', options=[('','')] + map(tuple, keywords))}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Module', 'Module')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Module')}
				${renderer.select('Module', options=[('','')] + 
						[(m.MODULE_ID, m.ModuleName) for m in modules])}
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
		<tr>
			<td class="ui-widget-header">${renderer.label('IncludeClosed', 'Closed/Cancelled')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('IncludeClosed')}
				${renderer.checkbox('IncludeClosed')}&nbsp;<label for="IncludeClosed">Include Closed, Cancelled, and Duplicate Items</label>
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>
<% 
priority_types = [('My Ratings', 'User'), ("CIOC's Internal System Ratings", 'Sys')]
if not request.user:
	del priority_types[0]

%>
<h2 class="ui-state-default ui-corner-all search-type">Browse by Priority</h2>
%for label, prefix in priority_types:
<h3>${label}</h3>
<%block name="closed_note"><p class="small-note">This search does not include closed, cancelled or duplicate feature requests</p></%block>
<div class="priority-list clearfix">
%for priority in priorities:
<a class="priority ${priority.PriorityCode.lower().replace(' ', '-')}" href="${request.route_url('search_results', _query=[(prefix + 'Priority',priority[0])])}">${priority.PriorityName} (${getattr(priority, prefix + 'EnhancementCount')})</a>
%endfor
</div>
%endfor


<h2 class="ui-state-default ui-corner-all search-type">Browse by Keyword</h2>
${closed_note()}
<table class="ui-widget-content" cellspacing="0" cellpadding="4">
%for group in grouper(3, keywords):
	<tr>
	%for keyword in group:
		<td>
			%if keyword:
			<a href="${request.route_url('search_results', _query=[('Keyword',keyword[0])])}">${keyword.Keyword} (${keyword.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<h2 class="ui-state-default ui-corner-all search-type">Browse by Estimate</h2>
${closed_note()}
<table class="ui-widget-content" cellspacing="0" cellpadding="4">
%for group in grouper(3, estimates):
	<tr>
	%for estimate in group:
		<td>
			%if estimate:
			<a href="${request.route_url('search_results', _query=[('Estimate',estimate[0])])}">${estimate.CostRange} (${estimate.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<h2 class="ui-state-default ui-corner-all search-type">Browse by Release</h2>
<table class="ui-widget-content" cellspacing="0" cellpadding="4">
%for group in grouper(3, releases):
	<tr>
	%for release in group:
		<td>
			%if release:
			<a href="${request.route_url('search_results', _query=[('Release',release[0]), ('IncludeClosed', 'on')])}">${release.ReleaseName} (${release.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

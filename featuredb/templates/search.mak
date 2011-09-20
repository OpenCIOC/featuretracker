<%inherit file="master.mak"/>
<%!
from itertools import izip_longest
def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)
%>
<% 
model_state = request.model_state 
renderer = model_state.renderer
%>
<h1>Search for Features</h1>
<h2 class="ui-corner-top">Advanced Search</h2>
<form method="get" action="${request.route_url('home', action='results')}">
	<table>
		<tr>
			<td class="ui-widget-header">${renderer.label('Terms', 'Full-Text Search')}</td>
			<td class="ui-widget-content">${renderer.text('Terms', size=50, maxlength=100)}</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Keyword', 'Keyword')}</td>
			<td class="ui-widget-content">
				${renderer.select('Keyword', options=[('','')] + map(tuple, keywords))}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Module', 'Module')}</td>
			<td class="ui-widget-content">
				${renderer.select('Module', options=[('','')] + 
						[(m.MODULE_ID, m.ModuleName) for m in modules])}
				</td>
		</tr>
		<% priorities_formatted = [('','')] + [(p.PRIORITY_ID, p.PriorityName) for p in priorities] %>
		<tr>
			<td class="ui-widget-header">${renderer.label('UserPriority', 'My Rating')}</td>
			<td class="ui-widget-content">
				${renderer.select('UserPriority', options=priorities_formatted)}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Estimate', 'Estimate')}</td>
			<td class="ui-widget-content">
				${renderer.select('Estimate', options=[('','')] + map(tuple, estimates))}
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit">
</form>

<h2>Browse by Priority</h2>
%for label, prefix in [('My Ratings', 'User'), ("CIOC's Internal System Ratings", 'Sys')]:
<h3>${label}</h3>
<div class="priority-list clearfix">
%for priority in priorities:
<a class="priority ${priority.PriorityCode.lower().replace(' ', '-')}" href="${request.route_url('home', action='results', _query=[(prefix + 'Priority',priority[0])])}">${priority.PriorityName} (${getattr(priority, prefix + 'EnhancementCount')})</a>
%endfor
</div>
%endfor


<h2>Browse by Keyword</h2>
<table class="ui-widget-content" cellspacing="0" cellpadding="4">
%for group in grouper(3, keywords):
	<tr>
	%for keyword in group:
		<td>
			%if keyword:
			<a href="${request.route_url('home', action='results', _query=[('Keyword',keyword[0])])}">${keyword.Keyword} (${keyword.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>


<%inherit file="priority.mak"/>
<%block name="title">Suggestions</%block>
<%! 
from markupsafe import Markup
%>

<p>There are <strong>${len(suggestions)}</strong> outstanding requests.</p>
<table border="1" cellpadding="3" cellspacing="0">
<tr>
	<th class="ui-widget-header">Date</th>
	<th class="ui-widget-header">User</th>
	<th class="ui-widget-header">Organization</th>
	<th class="ui-widget-header">Request</th>
	<th class="ui-widget-header">Action</th>
</tr>

%for suggestion in suggestions:
<tr>
<td style="white-space:nowrap;">${suggestion.DateSuggested}</td>
<td><a href="mailto:${suggestion.Email}">${suggestion.Email}</a>
%if suggestion.UserName:
<br>(${suggestion.UserName})
%endif
</td>
<td>${suggestion.OrgName}</td>
<td>${suggestion.Suggestion}</td>
<td>
<a href="">Create</a>
<br><a href="">Delete</a>
</td>
</tr>
%endfor

</table>



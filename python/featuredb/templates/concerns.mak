<%inherit file="priority.mak"/>
<%block name="title">Problem/Concern Features</%block>
<%! 
from markupsafe import Markup
%>

<p>There are <strong>${len(concerns)}</strong> requests marked as having a problem/concern.</p>
<table border="1" cellpadding="3" cellspacing="0">
<tr>
	<th class="ui-widget-header">User</th>
	<th class="ui-widget-header">Organization</th>
	<th class="ui-widget-header">Agency</th>
	<th class="ui-widget-header">Member</th>
	<th class="ui-widget-header">Feature</th>
</tr>

%for concern in concerns:
<tr>
<td><a href="mailto:${concern.Email}">${concern.Email}</a>
%if concern.UserName:
<br>(${concern.UserName})
%endif
</td>
<td>${concern.OrgName}</td>
<td>${concern.Agency}</td>
<td>${concern.MemberName}</td>
<td><a href="${request.route_url('enhancement', id=concern.ID)}">#${concern.ID} ${concern.Title}</a></td>
</tr>
%endfor

</table>



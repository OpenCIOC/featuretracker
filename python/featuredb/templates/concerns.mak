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



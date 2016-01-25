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
<td style="white-space:nowrap;">${request.format_date(suggestion.DateSuggested)}</td>
<td><a href="mailto:${suggestion.Email}">${suggestion.Email}</a>
%if suggestion.UserName:
<br>(${suggestion.UserName})
%endif
</td>
<td>${suggestion.OrgName}</td>
<td>${suggestion.Suggestion}</td>
<td>
<a href="${request.route_path('suggestion_delete', _query=[('ID', suggestion.SUGGEST_ID)])}">Delete</a>
</td>
</tr>
%endfor

</table>



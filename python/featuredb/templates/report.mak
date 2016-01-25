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
<%block name="title">Search Results</%block>
<%! 
from markupsafe import Markup
%>

<p>There are <strong>${len(results)}</strong> enhancements(s) that have not been selected for a release.</p>
<p>Enhancements are listed in order of their current ranking, with high priority items listed first. Click on the enhancement name to view the full details of the enhancement.</p>
<% modules = [('CIC', 'Community Information'),('VOL', 'Volunteer Opportunities'),('TRACKER', 'Client Tracker'),('OFFLINE','Offline Tools'),('ENHANCEMENT','Feature Request Database'),('COMMUNITY','Communities Repository')] %>
<table border="1" cellpadding="3" cellspacing="0">
<tr>
	<th class="ui-widget-header">Overall Rank</th>
%if request.user:
	<th class="ui-widget-header">My Rank</th>
%endif
	<th class="ui-widget-header">Title</th>
	<th class="ui-widget-header">Module(s)</th>
	<th class="ui-widget-header">Est. Cost</th>
	<th class="ui-widget-header">CIOC Priority</th>
	<th class="ui-widget-header">Avg. Priority</th>
%if request.user:
	<th class="ui-widget-header">My Priority</th>
%endif
	<th class="ui-widget-header">Ranked by # Members</th>
	<th class="ui-widget-header">Ranked by # Users</th>
	<th class="ui-widget-header">Times in User Top 30</th>
</tr>

%for result in results:
<tr>
<td class="bold-text">${result.OverallRank}</td>
%if request.user:
<td>${result.UserRank}</td>
%endif
<td><a href="${request.route_url('enhancement', id=result.ID)}">#${result.ID} ${result.Title}</a></td>
<td>
%for module, title in modules:
%if getattr(result, module):
<span class="module-icon module-icon-${module.lower()}" title="${title}"></span>
%endif
%endfor
<td>${result.CostRange}</td>
<% priority = priority_map[result.SysPriority] %>
<td><span class="${priority.PriorityCode.lower().replace(' ', '-')}-text">${priority.PriorityName}</span></td>
<% priority = priority_map[result.AvgPriority] %>
<td><span class="${priority.PriorityCode.lower().replace(' ', '-')}-text">${priority.PriorityName}</span></td>
%if request.user:
<% priority = priority_map[result.UserPriority] %>
<td><span class="${priority.PriorityCode.lower().replace(' ', '-')}-text bold-text">${priority.PriorityName}</span></td>
%endif
<td>${result.TimesRankedByMemberTotal}</td>
<td>${result.TimesRankedByUserTotal}</td>
<td>${result.TimesTop30}</td>


</tr>
%endfor

</table>



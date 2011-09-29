<%inherit file="master.mak"/>
<%block name="title">Search Results</%block>
<% 
searched_for_map = {
	'UserPriority': 'My Ranking',
	'CostRange': 'Estimate',
	'SysPriority': 'CIOC Internal Priority'
}

searched = searched_for.items()

%>

%if searched:
	%if len(searched) == 1:
		<p>You searched for <strong>${searched_for_map.get(searched[0][0], searched[0][0])}</strong> is <em>${searched[0][1]}</em>
	%else:
		<p>You searched for:
		<ul>
		%for field, val in sorted(searched, key=lambda x: searched_for_map.get(x[0], x[0])):
			<li><strong>${searched_for_map.get(field, field)}</strong> is <em>${val}</em></li>
		%endfor
		</ul>
	%endif

%endif

%if results:

<p>There are <strong>${len(results)}</strong> enhancements(s) that match your criteria. 
<br>Click on the enhancement name to view the full details of the enhancement.</p>
<% modules = [('CIC', 'Community Information'),('VOL', 'Volunteer Opportunities'),('TRACKER', 'Client Tracker')] %>
<ol class="results">

%for result in results:
<li class="result">

<h3 class="ui-state-default ui-corner-all clearfix"><span class="module-icons">
%for module, title in modules:
%if getattr(result, module):
<span class="module-icon module-icon-${module.lower()}" title="${title}"></span>
%endif
%endfor
</span>
<a href="${request.route_url('enhancement', id=result.ID)}">#${result.ID} ${result.Title}</a>
</h3>

<p class="status-line status-line1">Module(s): ${result.Modules} ; 
Status: ${result.Status}</p>

<p class="status-line status-line2">Last Modified: ${result.LastModified} ; 
<% priority = priorities[result.SysPriority] %>
Priority: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-results">${priority.PriorityName}</span> ;
Est. Cost: ${result.CostRange}</p>

<p class="short-description">${result.ShortDescription}</p>


<% priority = priorities[result.UserPriority] %>
<p class="status-my-rank"><span class="ui-icon ui-icon-circle-triangle-e inline-icon"></span> 
My Ranking: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-text align-bottom">${priority.PriorityName}</span></p>

</li>
%endfor

</ol>
%else:
<p><strong>There are no enhancements that match your criteria. Please modify your search to be less restrictive and try again.</strong></p>
%endif

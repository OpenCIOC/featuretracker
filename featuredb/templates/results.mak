<%inherit file="master.mak"/>

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


<ol class="results">

%for result in results:
<li class="result">

<h3 class="ui-state-default ui-corner-all"><a href="${request.route_url('enhancement', id=result.ID)}">#${result.ID} ${result.Title}</a></h3>

<p class="status-line status-line1">Module(s): ${result.Modules} ; 
Status: ${result.Status}</p>

<p class="status-line status-line2">Last Modified: ${result.LastModified} ; 
<% priority = priorities[result.SysPriority] %>
Priority: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-text">${priority.PriorityName}</span> ;
Est. Cost: ${result.CostRange}</p>

<p class="short-description">${result.ShortDescription}</p>


<% priority = priorities[result.UserPriority] %>
<p class="status-my-rank"><span class="ui-icon ui-icon-circle-triangle-e inline-icon"></span> 
My Ranking: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-text align-bottom">${priority.PriorityName}</span></p>

</li>
%endfor

</ol>

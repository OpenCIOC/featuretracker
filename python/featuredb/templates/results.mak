<%inherit file="priority.mak"/>
<%block name="title">Search Results</%block>
<%! 
from markupsafe import Markup
searched_for_map = {
	'UserPriority': 'My Ranking',
	'CostRange': 'Estimate',
	'SysPriority': 'CIOC Internal Priority'
}

searched_for_tmpl = Markup('<strong>%s</strong> is <em>%s</em>')
%>

<%
searched = sorted(((searched_for_map.get(name, name),val) for name, val in searched_for.items()), key=lambda x: x[0])
searched = [searched_for_tmpl % x for x in searched]
if fulltext_keywords:
	searched.insert(0,Markup('<strong>Full-text Search</strong> is <em>%s</em>') % fulltext_keywords)
if created_in_the_last_number:
	searched.append(Markup('<strong>Created in the Last</strong> <em>%s</em> <strong>days</strong>') % created_in_the_last_number)
if modified_in_the_last_number:
	searched.append(Markup('<strong>Modified in the Last</strong> <em>%s</em> <strong>days</strong>') % modified_in_the_last_number)
if include_closed:
	searched.append(Markup('<strong>Include Closed and Cancelled Requests</strong>'))
%>

%if searched:
	%if len(searched) == 1:
		<p>You searched for ${searched[0]}
	%else:
		<p>You searched for:
		<ul>
		%for searched_item in searched:
			<li>${searched_item}</li>
		%endfor
		</ul>
	%endif
%endif

%if not include_closed:
<p class="small-note">Closed and Cancelled enhancements are not included in this list.</p>
%endif

%if results:

<p>There are <strong>${len(results)}</strong> enhancements(s) that match your criteria. 
<br>Click on the enhancement name to view the full details of the enhancement.</p>
<% modules = [('CIC', 'Community Information'),('VOL', 'Volunteer Opportunities'),('TRACKER', 'Client Tracker'),('OFFLINE','Offline Tools'),('ENHANCEMENT','Feature Request Database'),('COMMUNITY','Communities Repository')] %>
<ol class="results">

%for result in results:
<li class="result">

<h3 class="ui-state-default ui-corner-all clearfix"><span class="module-icons">
%for module, title in modules:
%if getattr(result, module):
<span class="module-icon module-icon-${module.lower()}" title="${title}">Community Information</span>
%endif
%endfor
</span>
<a href="${request.route_url('enhancement', id=result.ID)}">#${result.ID} ${result.Title}</a>
</h3>

<p class="status-line status-line1">Module(s): ${result.Modules} ; 
Status: ${result.Status}
%if result.Funder:
 ; Funder: ${result.Funder}
%endif
</p>

<p class="status-line status-line2">Last Modified: ${result.LastModified} ; 
<% priority = priority_map[result.SysPriority] %>
Priority: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-results">${priority.PriorityName}</span> ;
Est. Cost: ${result.CostRange}</p>

%if result.Releases:
<p class="status-line status-line3">Release(s): ${result.Releases}</p>
%endif

%if result.ShortDescription:
<p class="short-description">${result.ShortDescription}</p>
%endif


%if request.user:
<% priority = priority_map[result.UserPriority] %>
<p class="status-my-rank"><span class="ui-icon ui-icon-circle-triangle-e inline-icon" aria-hidden="true"></span> 
My Ranking: <span class="${priority.PriorityCode.lower().replace(' ', '-')}-text align-bottom">${priority.PriorityName}</span></p>
%endif

</li>
%endfor

</ol>
%else:
<p><strong>There are no enhancements that match your criteria. Please modify your search to be less restrictive and try again.</strong></p>
%endif


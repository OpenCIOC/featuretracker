<%inherit file="priority.mak"/>
<%!
from datetime import date, timedelta
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
				${renderer.text('Terms', maxlength=100)}
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
		%if request.user:
		<tr>
			<td class="ui-widget-header">${renderer.label('UserPriority', 'My Rating')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('UserPriority')}
				${renderer.select('UserPriority', options=priorities_formatted)}
				</td>
		</tr>
		%endif
		<tr>
			<td class="ui-widget-header">${renderer.label('SysPriority', 'CIOC Ratings')} <span class="ui-reset ui-widget ui-state-default ui-content"><span class="open-dialog ui-icon ui-icon-help inline-icon" title="What's This?">What's This?</span></span></td>
			<td class="ui-widget-content">
				${renderer.errorlist('SysPriority')}
				${renderer.select('SysPriority', options=priorities_formatted)}
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
			<td class="ui-widget-header">${renderer.label('CreatedInTheLastXDays', 'Created')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('CreatedInTheLastXDays')}
				Created in the last
				<% days = ['', 120, 90, 60, 30, 14, 7, 2, 1] %>
				${renderer.select('CreatedInTheLastXDays', options=days, class_='smallselect')}
				day(s).
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('ModifiedInTheLastXDays', 'Modified')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ModifiedInTheLastXDays')}
				Modified in the last
				<% days = ['', 120, 90, 60, 30, 14, 7, 2, 1] %>
				${renderer.select('ModifiedInTheLastXDays', options=days, class_='smallselect')}
				day(s).
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Release', 'Release')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Release')}
				${renderer.select('Release', options=[('','')] + 
						[(r.RELEASE_ID, r.ReleaseName) for r in releases])}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Funder', 'Funder')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Funder')}
				${renderer.select('Funder', options=[('','')] + 
						[(f.FUNDER_ID, f.FunderName) for f in funders])}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('Status', 'Status')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('Status')}
				${renderer.select('Status', options=[('','')] + 
						[(s.STATUS_ID, s.StatusName) for s in statuses])}
				</td>
		</tr>
		<tr>
			<td class="ui-widget-header">${renderer.label('IncludeClosed', 'Closed/Cancelled')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('IncludeClosed')}
				${renderer.checkbox('IncludeClosed', checked=True)}&nbsp;<label for="IncludeClosed">Include Closed and Cancelled Requests</label>
				</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Submit"> <input type="reset" value="Clear">
</form>

<h2 class="ui-state-default ui-corner-all search-type">Go To Specific Enhancement</h2>
<form method="get" action="${request.route_url('search_results')}">
	<table class="form-table">
		<tr>
			<td class="ui-widget-header">${renderer.label('ID', 'ID #')}</td>
			<td class="ui-widget-content">
				${renderer.errorlist('ID')}
				${renderer.text('ID', size=5, maxlength=4)}
				<input type="submit" value="Submit">
			</td>
		</tr>
	</table>
</form>
<% 
priority_types = [('My Ratings', 'User', False), ("CIOC's Internal System Ratings", 'Sys', True)]
if not request.user:
	del priority_types[0]

%>
<h2 class="ui-state-default ui-corner-all search-type">Browse by Priority</h2>
%for label, prefix, show_help in priority_types:
<h3>${label}
%if show_help:
<span class="open-dialog ui-state-default ui-icon ui-icon-help inline-icon" title="What's This?">What's This?</span>
%endif
</h3>
<%block name="closed_note"><p class="small-note">This search does not include closed or cancelled feature requests</p></%block>
<div class="priority-list clearfix">
%for priority in priorities:
<a class="priority ${priority.PriorityCode.lower().replace(' ', '-')}" href="${request.route_url('search_results', _query=[(prefix + 'Priority',priority[0])])}">${priority.PriorityName} (${getattr(priority, prefix + 'EnhancementCount')})</a>
%endfor
</div>
%endfor


<h2 class="ui-state-default ui-corner-all search-type">Browse by Keyword</h2>
${closed_note()}
<table class="ui-widget-content browse-table">
<% keywords_tmp = [x for x in keywords if x.EnhancementCount] %>
%for group in grouper(min([len(keywords_tmp),3]), keywords_tmp):
	<tr>
	%for keyword in group:
		<td class="ui-widget-content">
			%if keyword:
			<a href="${request.route_url('search_results', _query=[('Keyword',keyword[0])])}">${keyword.Keyword} (${keyword.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<h2 class="ui-state-default ui-corner-all search-type">Browse by Estimated Price Range</h2>
${closed_note()}
<table class="ui-widget-content browse-table">
<% tmp_estimates = [x for x in estimates if x.EnhancementCount] %>
%for group in grouper(min([len(tmp_estimates),3]), tmp_estimates):
	<tr>
	%for estimate in group:
		<td class="ui-widget-content">
			%if estimate:
			<a href="${request.route_url('search_results', _query=[('Estimate',estimate[0])])}">${estimate.CostRange} (${estimate.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<h2 class="ui-state-default ui-corner-all search-type">Browse by Status</h2>
<table class="ui-widget-content browse-table">
%for group in grouper(min([len(statuses),3]), statuses):
	<tr>
	%for status in group:
		<td class="ui-widget-content">
			%if status:
			<a href="${request.route_url('search_results', _query=[('Status',status[0]), ('IncludeClosed', 'on')])}">${status.StatusName} (${status.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>


<h2 class="ui-state-default ui-corner-all search-type">Browse by Release</h2>
<table class="ui-widget-content browse-table">
%for group in grouper(min([len(releases),3]), releases):
	<tr>
	%for release in group:
		<td class="ui-widget-content">
			%if release:
			<a href="${request.route_url('search_results', _query=[('Release',release[0]), ('IncludeClosed', 'on')])}">${release.ReleaseName} (${release.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<h2 class="ui-state-default ui-corner-all search-type">Browse by Funder</h2>
<table class="ui-widget-content browse-table">
%for group in grouper(min([len(funders),3]), funders):
	<tr>
	%for funder in group:
		<td class="ui-widget-content">
			%if funder:
			<a href="${request.route_url('search_results', _query=[('Funder',funder[0]), ('IncludeClosed', 'on')])}">${funder.FunderName} (${funder.EnhancementCount})</a>
			%endif
		</td>
	%endfor
	</tr>
%endfor
</table>

<div id="whatsthisciocranking" style="display:none">
CIOC Internal System Rating is a baseline rating for all features, independent of member input, which takes into account the priority of the user or users whose problem or request is behind the feature, as well as the feature's overall importance to CIOC's overall sustainability, security, stability, usability, and/or performance, etc.
</div>


<%block name="bottomscripts">
${parent.bottomscripts()}

<script type="text/javascript">
jQuery(function($) {
	var $dialog = $('#whatsthisciocranking')
		.dialog({
			autoOpen: false,
			title: 'About CIOC Internal Ranking'
		});

	$('.open-dialog').click(function() {
		$dialog.dialog('open');
		// prevent the default action, e.g., following a link
		return false;
	});

});
</script>
</%block>

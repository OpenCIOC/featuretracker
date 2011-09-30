<%inherit file="master.mak"/>

<%! 
from itertools import groupby 
from operator import attrgetter
def group_priorities(user_priorities):
	groups = {}
	for g,l in groupby(user_priorities, attrgetter('PRIORITY_ID')):
		groups[g] = list(l)

	return groups
%>

<%block name="priority_mgmt">
%if request.user:
<div id="priority-mgmt" class="col2">

<h1>My Enhancements</h1>
<p class="small-note">Click and drag the enhancement to re-order or re-prioritize.
<br>Click the info icon to view the enhancement.
<br>Click the remove icon to reset to neutral priority.</p>

<% priority_groups = group_priorities(user_priorities) %>
%for priority in (p for p in priorities if p.Weight != 0):
<% priority_class = priority.PriorityCode.lower().replace(' ', '-') %>
<h3 class="priority ${priority_class}">${priority.PriorityName}</h3>
<div class="priority-en ${priority_class}-en"> 
	<ol class="enhancement-list connectedSortable ui-sortable">
	%for enhancement in priority_groups.get(priority.PRIORITY_ID,[]):
		<li data-enhancement-id="${enhancement.ID}">${enhancement.Title}
		<a class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;" href="${request.route_path('enhangement', id=enhancement.ID)}">
		</a>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;"></span>
		</li>
	%endfor
	</ol>
</div>
%endfor
<%doc>
<h3 class="very-high priority">Very High</h3>
<div class="very-high-en priority-en">
	<ol id="sortable-very-high" class="enhancement-list connectedSortable ui-sortable">
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
<h3 class="high priority">High</h3>
<div class="high-en priority-en">
	<ol id="sortable-high" class="enhancement-list connectedSortable ui-sortable">
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
<h3 class="moderate priority">Moderate</h3>
<div class="moderate-en priority-en">
	<ol id="sortable-moderate" class="enhancement-list connectedSortable ui-sortable">
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
<h3 class="low priority">Low</h3>
<div class="low-en priority-en">
	<ol class="enhancement-list">
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
<h3 class="very-low priority">Very Low</h3>
<div class="very-low-en priority-en">
	<ol class="enhancement-list">
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
<h3 class="do-not-want priority">Not Desired (Dislike)</h3>
<div class="do-not-want-en priority-en">
	<ol class="enhancement-list">
		<li>Enhancement Text
		<a class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;" href="${request.route_path('enhancement', id='1')}"> </a>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
		<li>Enhancement Text
		<span class="ui-state-default ui-icon ui-icon-info" style="display: inline-block; vertical-align: bottom;">
		</span>
		<span class="ui-state-default ui-icon ui-icon-circle-close" style="display: inline-block; vertical-align: bottom;">
		</span></li>
	</ol>
</div>
</%doc>

</div><!-- #priority-mgmt -->
%endif
</%block>


<%block name="bottomscripts">
<script type="text/javascript">
	$(function() {
		$( ".enhancement-list" ).sortable({
			connectWith: ".enhancement-list"
		}).disableSelection();
	});
</script>
</%block>

${next.body()}

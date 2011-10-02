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
	<ol class="enhancement-list connectedSortable ui-sortable" data-priority="${priority.PRIORITY_ID}" id="selected-priority-list-${priority.PRIORITY_ID}">
	%for enhancement in priority_groups.get(priority.PRIORITY_ID,[]):
		${enhancement_item(enhancement.ID, enhancement.Title)}
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

<%def name="enhancement_item(id, title)">
	<li data-enh-id="${id}" id="selected-enhancement-${id}" class="selected-enhancement">
	<span class="priority-enhancement-actions"><a class="ui-state-default ui-icon ui-icon-info selected-enhancement-details" style="display: inline-block; vertical-align: bottom;" href="${request.route_path('enhancement', id=id)}"> </a>
	<span class="ui-state-default ui-icon ui-icon-circle-close selected-enhancement-remove" style="display: inline-block; vertical-align: bottom; "></span></span>
	${title}
	</li>
</%def>

<%block name="bottomscripts">
<script type="text/html" id="enhancement-item-tmpl">
${enhancement_item('IDIDID', '[TITLE]')}
</script>
<script type="text/javascript">
	(function() {
		var neutral_priority = ${[p.PRIORITY_ID for p in priorities if p.Weight == 0][0]},
			enh_item_tmpl = null,
		gen_enh_item = function(id, title) {
			if (!enh_item_tmpl) {
				enh_item_tmpl = $('#enhancement-item-tmpl').html()
			}
			return $(enh_item_tmpl.replace(/IDIDID/g, id).replace(/\[TITLE\]/g, title));
		},
		add_enhancement = function(id, title, priority) {
			var list_item = $('#selected-enhancement-' + id), old_priority_list = list_item.parent(),
				old_priority = old_priority_list.data('priority'), priority_list = $('#selected-priority-list-' + priority);
			if (!list_item.length && priority !== neutral_priority) {
				list_item = gen_enh_item(id, title);
			}
			
			if (old_priority && old_priority === priority) {
				//XXX same priority
				return;
			}


			if (priority != neutral_priority) {
				priority_list.append(list_item);
			} else {
				list_item.remove();
			}

			;
			
			update_priorities(priority_list.add(old_priority_list));

		},
		update_priorities = function(priority_lists) {
			var priorities = [], ajax_settings = {cache: false, contentType: 'application/json', type:'POST'};
			priority_lists.each(function(idx, el) {
				var enhancements = [], self = $(el), priority = self.data('priority'), 
					priority_obj = {id: priority, enhancements: enhancements};
				priorities.push(priority_obj);
				self.find('li').each(function(idx, el) {
					enhancements.push($(el).data('enhId'));
				})
			});
			ajax_settings['data'] = JSON.stringify(priorities);
			$.ajax("${request.route_path('priority')}", ajax_settings);
			
		},
		set_enhancement_priority = function(enhId, priority){
			$("#priority-selector-" + enhId).find('option[value="' + priority + '"]').prop('selected', true);
		}, 
		refresh_priorities = function(data) {
			$('.enhancement-list').each(function(index, el) {
				// clear old priority information
				var self = $(this), priority = self.data('priority'), 
					enhancements = data[priority], i, list_item, enh;

				self.find('li').each(function(index, el) {
					set_enhancement_priority($(el).data('enhId'), priority);
				})
				
				self.empty();
				
				if (!enhancements) {
					return;
				}

				for (i = 0; i < enhancements.length; i++) {
					
					enh = enhancements[i];
					list_item = gen_enh_item(enh.ID, enh.Title);
					self.append(list_item);
					set_enhancement_priority(enh.ID, priority);
				}
			});


		}, fetch_latest_values = function() {
			$.ajax("${request.route_path('priority')}", {cache: false, dataType: 'json', success:refresh_priorities});
		};

		window['add_enhancement'] = add_enhancement;

		$(function() {
			var old_priority_list = null;
			$( ".enhancement-list" ).sortable({
				connectWith: ".enhancement-list"
			}).disableSelection().bind('sortstop', function(evt, ui) {
				var priority_list = ui.item.parent(), priority=priority_list.data('priority'), 
					old_priority=(old_priority_list ? old_priority_list.data('priority') : null);
				if (old_priority !== priority) {
					priority_list = priority_list.add(old_priority_list);
					set_enhancement_priority(ui.item.data('enhId'), priority);
				}
				old_priority_list = null;
				update_priorities(priority_list);

			}).bind('sortstart', function(evt,ui) {
				old_priority_list = ui.item.parent();
			});

			$('.priority-selector').live('change', function(evt) {
				var priority = this.value, self = $(this), data = self.data();
				add_enhancement(data.enhId, data.enhTitle, priority);
			});
			$('.selected-enhancement-remove').live('click', function(evt) {
				var self = $(this), priority = self.parents('li').first(), priority_list = priority.parent();
				set_enhancement_priority(priority.data('enhId'), neutral_priority);
				priority.remove();
				update_priorities(priority_list);
			});

			fetch_latest_values();

		});
		/*
		window.addEventListener('pageshow', function(evt) {
			//if (evt.persisted) {
				fetch_latest_values();
			//}
		}, false);
		*/
	})();
</script>
</%block>

${next.body()}

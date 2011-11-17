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
%if request.user and user_priorities is not Undefined:
<div id="priority-mgmt" class="col2" style="position">

<h1>My Enhancements</h1>
<p class="small-note">Click and drag the enhancement to re-order or re-prioritize.
<br>Click the info icon to view the enhancement.
<br>Click the remove icon to reset to neutral priority.
<br>List does not include funded, closed, or cancelled items.</p>
<div id="cart-total" ${'style="display:none;"' if not any(cart.values()) else ''|n}><strong>Total Cost of selections:</strong><br>
<span id="cart-cost" ${'style="display:none;"' if not any(cart.get(x) for x in ['CostLow','CostHigh','CostAvg']) else ''|n}>$<span id="cost-low">${cart.get('CostLow') or 0}</span> - $<span id="cost-high">${cart.get('CostHigh') or 0}</span> ($<span id="cost-avg">${cart.get('CostAvg') or 0}</span> Avg.)</span><span id="cart-both" ${'style="display:none;"' if not all(cart.values()) else ''|n}>
<br>+</span><span id="cart-not-estimated" ${'style="display:none;"' if not cart.get('NotEstimated') else ''|n}><span id="cart-none">${cart.get('NotEstimated')}</span> enhacement(s) with no estimate.</span></div>
<% priority_groups = group_priorities(user_priorities) %>
%for priority in (p for p in priorities if p.PriorityCode != 'NEUTRAL'):
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

</div><!-- #priority-mgmt -->
%endif
</%block>

<%def name="enhancement_item(id, title)">
	<li data-enh-id="${id}" id="selected-enhancement-${id}" class="selected-enhancement"><span class="priority-enhancement-actions"><a class="ui-state-default ui-icon ui-icon-info selected-enhancement-details inline-icon" href="${request.route_path('enhancement', id=id)}" title="more info"> </a>
	<span class="ui-state-default ui-icon ui-icon-circle-close selected-enhancement-remove inline-icon" title="remove"></span></span>${title}
	</li>
</%def>

<%block name="bottomscripts">
%if request.user and user_priorities is not Undefined:
<script type="text/html" id="enhancement-item-tmpl">
${enhancement_item('IDIDID', '[TITLE]')}
</script>
<script type="text/javascript">
	(function() {
		var neutral_priority = ${[p.PRIORITY_ID for p in priorities if p.PriorityCode == 'NEUTRAL'][0]},
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
			var priorities = [], ajax_settings = {
				cache: false, contentType: 'application/json', 
				type:'POST', dataType: 'json', 
				success: function(data) {
					if (!data.failed) {
						update_cart(data.cart);
					}
				}
			};

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
			var primgmt = $('#priority-mgmt').hide(), 
				priorities = data.priorities, cart = data.cart;
			$('.enhancement-list').each(function(index, el) {
				// clear old priority information
				var self = $(this), priority = self.data('priority'), 
					enhancements = priorities[priority], i, list_item, enh;

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


			primgmt.show();


		}, fetch_latest_values = function() {
			$.ajax("${request.route_path('priority')}", {cache: false, dataType: 'json', success:refresh_priorities});
		}, update_cart = function(cart) {
			if (!cart) {
				$("#cart-total").hide()
			} else {
				$("#cart-total").show()
				var cost = cart.CostLow || cart.CostAvg || cart.CostHigh,
					noestimate = cart.NotEstimated;

				if (noestimate === '0') {
					noestimate = null;
				}

				if (!cost) {
					$('#cart-cost').hide();
				} else {
					$('#cart-cost').show();
					$("#cost-low").text(cart.CostLow);
					$("#cost-high").text(cart.CostHigh);
					$("#cost-avg").text(cart.CostAvg);
				}

				if (!noestimate) {
					$('#cart-not-estimated').hide();
				} else {
					$('#cart-not-estimated').show();
					$('#cart-none').text(cart.NotEstimated);
				}

				if (cost && noestimate) {
					$('#cart-both').show();
				} else {
					$('#cart-both').hide();
				}
			}
		};

		window['add_enhancement'] = add_enhancement;

		$(function() {
			var old_priority_list = null;
			fetch_latest_values();
			$( ".enhancement-list" ).sortable({
				connectWith: ".enhancement-list",
				// Mozilla breaks the dragging
				sort: $.browser.mozilla ?  function(event, ui) {  
				   ui.helper.css({'top' : ui.position.top + $(window).scrollTop() + 'px'});
				} : null

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
%endif
</%block>

${next.body()}

<%block name="body_open_tag">
%if request.user and user_priorities is not Undefined:
<body class="priority-sidebar">
%else:
${parent.body_open_tag()}
%endif
</%block>

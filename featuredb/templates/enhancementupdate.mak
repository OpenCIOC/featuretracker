<%inherit file="master.mak"/>
<%block name="title">Update Enhancement</%block>
<%!
from itertools import izip_longest
def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)
%>

<% renderer = request.model_state.renderer %>

${renderer.error_notice()}
<form method="post" action="${request.current_route_path()}">
%if not is_add:
	<input type="hidden" name="ID" value="${enhancement.ID}">
%endif
	<table class="form-table">
%if not is_add:
${self.makeMgmtInfo(enhancement)}
%endif
	<tr>
		<td class="ui-widget-header">${renderer.label('Title', 'Title')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('Title')}
			${renderer.text('Title', maxlength=255, class_='textwide')}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('Basic Description', 'Description')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('BasicDescription')}
			${renderer.textarea('BasicDescription', class_='smalltextarea')}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('AdditionalNotes', 'Notes')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('AdditionalNotes')}
			${renderer.textarea('AdditionalNotes', class_='smalltextarea')}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SYS_PRIORITY', 'Priority')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SYS_PRIORITY')}
			${renderer.select('SYS_PRIORITY', options=[('','')] + map(tuple, priorities))}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SYS_ESTIMATE', 'Estimate')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SYS_ESTIMATE')}
			${renderer.select('SYS_ESTIMATE', options=map(tuple, estimates))}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SYS_STATUS', 'Status')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SYS_STATUS')}
			${renderer.select('SYS_STATUS', options=map(tuple, statuses))}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SYS_FUNDER', 'Funder')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SYS_FUNDER')}
			${renderer.select('SYS_FUNDER', options=[('','')] + map(tuple, funders))}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SYS_SOURCETYPE', 'Source')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SYS_SOURCETYPE')}
			${renderer.select('SYS_SOURCETYPE', options=[('','')] + map(tuple, source_types))}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">${renderer.label('SourceDetail', 'Source Detail')}</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SourceDetail')}
			${renderer.text('SourceDetail', maxlength=255, class_='textwide')}
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">Modules</td>
		<td class="ui-widget-content">
			${renderer.errorlist('Modules')}
			<table class="ui-widget-content browse-table">
			%for group in grouper(min([len(modules),3]), modules):
				<tr>
				%for module in group:
					<td class="ui-widget-content">
						%if module:
							${renderer.ms_checkbox('Modules', module.MODULE_ID, label=' ' + module.ModuleCode)}
						%endif
					</td>
				%endfor
				</tr>
			%endfor
			</table>
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">Keywords</td>
		<td class="ui-widget-content">
			${renderer.errorlist('Keywords')}
			<table class="ui-widget-content browse-table">
			%for group in grouper(min([len(keywords),3]), keywords):
				<tr>
				%for keyword in group:
					<td class="ui-widget-content">
						%if keyword:
							${renderer.ms_checkbox('Keywords', keyword[0], label=' ' + keyword.Keyword)}
						%endif
					</td>
				%endfor
				</tr>
			%endfor
			</table>
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">Releases</td>
		<td class="ui-widget-content">
			${renderer.errorlist('Releases')}
			<table class="ui-widget-content browse-table">
			%for group in grouper(min([len(releases),3]), releases):
				<tr>
				%for release in group:
					<td class="ui-widget-content">
						%if release:
							${renderer.ms_checkbox('Releases', release[0], label=' ' + release.ReleaseName)}
						%endif
					</td>
				%endfor
				</tr>
			%endfor
			</table>
		</td>
	</tr>
	<tr>
		<td class="ui-widget-header">See Also</td>
		<td class="ui-widget-content">
			${renderer.errorlist('SeeAlso')}
			<table class="ui-widget-content browse-table" id="see_also_table">
				%for see_also in see_alsos:
					${see_also_row(see_also.ID, see_also.Title)}
				%endfor
			</table>
			<p>
			<input type="text" class="text" id="add_see_also_source"> <button id="add_see_also">Add Enh ID</button>
			</p>
		</td>
	</tr>
</table>
<br>
<input type="submit" value="Submit">
</form>

<%def name="see_also_row(id, title, force_checked=False)">
	<tr>
		<td class="ui-widget-content">
			${request.model_state.renderer.ms_checkbox('SeeAlso', id, checked=force_checked, label=' ' + title)}
		</td>
	</tr>
</%def>

<%block name="bottomscripts">
${parent.bottomscripts()}
<script type="text/html" id="see_also_row_template">
${see_also_row('[ID]', '[TITLE]', True)}
</script>
<script type="text/html" id="error_message_template">
${request.model_state.renderer.error_msg('MSGMSGMSG')}
</script>

<script type="text/javascript">
jQuery(function($) {
var source = $('#add_see_also_source'),
	template = $('#see_also_row_template').html(),
	sa_table = $('#see_also_table'),
	error_template = $('#error_message_template').html(),
	get_existing = function(value) {
		return $('#see_also_table input').filter(function(idx) { return this.value === value; });
	},
	show_error = function(errmsg) {
		var error = $(error_template.replace(/MSGMSGMSG/g, $('<div>').text(errmsg).html())).
			hide().insertAfter(sa_table);
		error.show('fast');
	},
	clear_error = function() {
		sa_table.siblings('.error-notice').hide('fast', function(){$(this).remove();});
	},
	do_fetch = function(evt) {
		var value = source[0].value;
		clear_error();
		if (!value){
			return false;
		}
		var existing = get_existing(value);
		if (existing.length) {
			existing.prop('checked', true);
			source[0].value = '';
			return false;
		}

		$.ajax({url: "${request.route_path('enhancementupdate', action='getenh')}", cache: false, dataType: 'json', data: {'ID': value}, success: function(data) {
			if (data.success) {
				var existing = get_existing(value);
				if (existing.length) {
					existing.prop('checked', true);
					return;
				}

				$(template.replace(/\[ID\]/g, $('<div>').text(data.ID).html()).
					replace(/\[TITLE\]/g, $('<div>').text(data.Title).html())).appendTo('#see_also_table');

				source[0].value = '';

			} else {
				show_error(data.errmsg);
			}
		}});
		return false;
	};

	$('#add_see_also').click(do_fetch);
	source.keypress(function(evt) {
		if (evt.keyCode == '13') {
			return do_fetch(evt);
		}
	});
});
</script>
</%block>


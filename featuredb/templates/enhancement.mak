<%inherit file="master.mak" />

<% model_state = request.model_state %>
%if not model_state.is_valid:

${request.model_state.renderer.error_notice(model_state.errors_for('*')[0])}


%else:
<div class="enhancement">
<h2 class="ui-state-default ui-corner-all clearfix">
<span class="module-icons">
%for module in enhancement.Modules:
%if module['ModuleCode'] != 'ADMIN':
<span class="module-icon module-icon-${module['ModuleCode'].lower()}" title="${module['ModuleName']}"></span>
%endif
%endfor
</span>
#${enhancement.ID} ${enhancement.Title}
</h2>
<%doc>
<ul class="modules clearfix">
<li class="title">Modules:</li>
%for module in enhancement.Modules:
<li><a href="${request.route_url('home', action='results', _query=[('Module', module['MODULE_ID'])])}">${module['ModuleName']}</a></li>
%endfor
</ul>
</%doc>
<div class="enhancement-status-row clearfix">
<dl> <dt>Priority</dt><dd class="${enhancement.SysPriority['PriorityCode'].lower().replace(' ', '-')}-text">${enhancement.SysPriority['PriorityName']}</dd></dl>

<dl><dt>Estimate</dt><dd>${enhancement.CostRange}</dd></dl>

<dl><dt>Status</dt><dd>${enhancement.Status}</dd></dl>

<dl><dt>Modules</dt>
%for module in enhancement.Modules:
<dd><a href="${request.route_url('home', action='results', _query=[('Module', module['MODULE_ID'])])}">${module['ModuleName']}</a></dd>
%endfor
</dl>
</div>

<p class="description"><strong>Description:</strong> ${enhancement.BasicDescription}</p>


%if enhancement.AdditionalNotes:
<p><strong>Notes:</strong> ${enhancement.AdditionalNotes }</p>
%endif

<ul class="keywords clearfix">
<li class="title">Keywords:</li>
%for keyword in enhancement.Keywords:
<li><a href="${request.route_url('home', action='results', _query=[('Keyword', keyword['KEYWORD_ID'])])}">${keyword['Keyword']}</a></li>
%endfor
</ul>


<p class="status-line status-line2">Last Modified: ${enhancement.LastModified} ; Modified By: ${enhancement.ModifiedBy}</p>
</div>



%endif

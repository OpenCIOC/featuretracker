<%inherit file="master.mak" />

<% model_state = request.model_state %>
%if not model_state.is_valid:

${request.model_state.renderer.error_notice(model_state.errors_for('*')[0])}


%else:

<div class="enhancement">
<h2 class="ui-state-default ui-corner-all">#${enhancement.ID} ${enhancement.Title}
<%doc>
<span class="module-icons">
%for module, title in modules:
%if getattr(enhancement, module):
<span class="module-icon module-icon-${module.lower()}" title="${title}"></span>
%endif
%endfor
</span>
</%doc>
</h2>
<div class="enhancement-status-row clearfix">
<dl> <dt>Priority</dt><dd class="${enhancement.SysPriority['PriorityCode'].lower().replace(' ', '-')}-text">${enhancement.SysPriority['PriorityName']}</dd></dl>

<dl><dt>Estimate</dt><dd>${enhancement.CostRange}</dd></dl>

<dl><dt>Status</dt><dd>${enhancement.Status}</dd></dl>
</div>

<p class="description">${enhancement.BasicDescription}</p>


<p><strong>Notes:</strong> ${enhancement.AdditionalNotes}</p>

<div class="keywords-and-modules clearfix">
<ul class="keywords">
<li class="title">Keywords:</li>
%for keyword in enhancement.Keywords:
<li><a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" class="ui-button-text" href="${request.route_url('home', action='results', _query=[('Keyword', keyword['KEYWORD_ID'])])}"><span class="ui-button-text">${keyword['Keyword']}</span></a></li>
%endfor
</ul>
<ul class="modules">
<li class="title">Modules:</li>
%for module in enhancement.Modules:
<li><a class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" href="${request.route_url('home', action='results', _query=[('Module', module['MODULE_ID'])])}"><span class="ui-button-text">${module['ModuleName']}</a></span></li>
%endfor
</ul>
</div>


<p class="status-line status-line2">Last Modified: ${enhancement.LastModified} ; Modified By: ${enhancement.ModifiedBy}</p>
</div>



%endif

<%inherit file="master.mak" />
<%! from markupsafe import Markup %>

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
<li><a href="${request.route_url('search_results', _query=[('Module', module['MODULE_ID'])])}">${module['ModuleName']}</a></li>
%endfor
</ul>
</%doc>
<div class="enhancement-status-row clearfix">
<dl> <dt>Priority</dt><dd class="${enhancement.SysPriority['PriorityCode'].lower().replace(' ', '-')}-text">${enhancement.SysPriority['PriorityName']}</dd></dl>

<dl><dt>Estimate</dt><dd>${enhancement.CostRange}</dd></dl>

<dl><dt>Status</dt><dd>${enhancement.Status}</dd></dl>

<dl><dt>Modules</dt>
%for module in enhancement.Modules:
<dd><a href="${request.route_url('search_results', _query=[('Module', module['MODULE_ID'])])}">${module['ModuleName']}</a></dd>
%endfor
</dl>
</div>

<p class="description"><strong>Description:</strong> ${enhancement.BasicDescription}</p>


%if enhancement.AdditionalNotes:
<p><strong>Notes:</strong> ${enhancement.AdditionalNotes }</p>
%endif

%if enhancement.Keywords:
<%
link_tmpl = Markup('<a href="%s">%s</a>')
url_gen = lambda x: request.route_url('search_results', _query=[('Keyword', x['KEYWORD_ID'])])

keywords = ((url_gen(k), k['Keyword']) for k in enhancement.Keywords)
keywords = (link_tmpl % k for k in keywords)
%>
<p><strong>Keywords:</strong> ${Markup(', ').join(keywords)} </p>
%endif

<p class="status-line status-line2">Last Modified: ${enhancement.LastModified} ; Modified By: ${enhancement.ModifiedBy}</p>
</div>



%endif

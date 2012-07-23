<%inherit file="master.mak"/>
<%block name="title">Access Denied</%block>

<% renderer = request.model_state.renderer %>

${renderer.error_notice('You do not have permission to view this page.')}

<%inherit file="master.mak"/>
<%block name="title">${page_title}</%block>

<% renderer = request.model_state.renderer %>

${renderer.error_msg(error_message)}

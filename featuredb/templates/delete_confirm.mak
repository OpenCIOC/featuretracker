<%inherit file="master.mak"/>
<%block name="title">${page_title}</%block>

<p>Are you sure you want to delete this item?</p>
<form action="${request.current_route_path()}" method="post">
<input type="hidden" name="ID" value="${ID}">
<input type="submit" value="Yes, delete this item.">
</form>

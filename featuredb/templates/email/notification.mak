<%page expression_filter="unicode"/>
%if FirstName:
Hi ${FirstName},
%else:
Hi,
%endif

You requested to be notified when ${ notification_type }. If you no longer wish to receive these emails please go to ${BASEURL}/account and alter your email settings.

%if created_enhancements:
The following enhancements were created since ${since_date}:

%for enhancement in created_enhancements:
${enhancement.Title}
${BASEURL}/enhancement/${enhancement.ID} 

%endfor
%endif
%if updated_enhancements:
The following enhancements that you have ranked have been updated since ${since_date}:

%for enhancement in updated_enhancements:
${enhancement.Title}
${BASEURL}/enhancement/${enhancement.ID} 

%endfor
%endif

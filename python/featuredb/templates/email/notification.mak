<%doc>
  =========================================================================================
   Copyright 2015 Community Information Online Consortium (CIOC) and KCL Software Solutions
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
  =========================================================================================
</%doc>

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

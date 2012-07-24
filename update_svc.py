import os, win32serviceutil

app_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
app_name = os.path.split(app_path)[1]
paster_path = os.path.abspath(os.path.join(app_path, '..', 'ciocenv31', 'Scripts', 'paster.exe'))

service_start_path = os.path.join(app_path, 'python')

virtualenv = os.path.abspath(r'..\..\ciocenv31')

win32serviceutil.SetServiceCustomOption("PyCioc" + app_name,'wsgi_virtual_env',virtualenv)

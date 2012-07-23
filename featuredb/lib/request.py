# =================================================================
# Copyright (C) 2011 Community Information Online Consortium (CIOC)
# http://www.cioc.ca
# Developed By Katherine Lambacher / KCL Custom Software
# If you did not receive a copy of the license agreement with this
# software, please contact CIOC via their website above.
#==================================================================

#Python STD Lib

import logging

# 3rd party libs
from pyramid.request import Request
from pyramid.decorator import reify
from pyramid.security import unauthenticated_userid

# This app
from featuredb.lib import config, connection, const

log = logging.getLogger(__name__)

class CommunityManagerRequest(Request):
    @reify
    def config(self):
        return config.get_config(const._config_file)

    @reify
    def connmgr(self):
        return connection.ConnectionManager(self)

    @reify
    def user(self):
        # <your database connection, however you get it, the below line
        # is just an example>
        userid = unauthenticated_userid(self)
        if userid is not None:
            # this should return None if the user doesn't exist
            # in the database
            with self.connmgr.get_connection() as conn:
                user = conn.execute('EXEC sp_User_Login ?', userid).fetchone()

            return user

        return None

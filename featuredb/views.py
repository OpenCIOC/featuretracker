from featuredb.models import DBSession
from featuredb.models import MyModel
from pyramid_handlers import action


class Index(object):
    def __init__(self, request):
        self.request = request


    @action(renderer='search.mak')
    def index(self):
        request = self.request

        return {}


    @action(renderer='priority.mak')
    def priority(self):
        request = self.request

        return {}

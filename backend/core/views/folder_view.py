from rest_framework import viewsets
from django_filters.rest_framework import DjangoFilterBackend
from core.models import Folder
from core.serializers import FolderSerializer

class FolderViewSet(viewsets.ModelViewSet):
    queryset = Folder.objects.all()
    serializer_class = FolderSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['parent'] 
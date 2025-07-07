from rest_framework import viewsets
from core.models import File
from core.serializers import FileSerializer
from rest_framework.permissions import AllowAny
from django_filters.rest_framework import DjangoFilterBackend

class FileViewSet(viewsets.ModelViewSet):
    queryset = File.objects.all()
    serializer_class = FileSerializer
    permission_classes = [AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['folder']
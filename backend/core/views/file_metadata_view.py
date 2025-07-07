from core.serializers.file_serializer import FileMetadataSerializer
from rest_framework import viewsets
from core.models import  FileMetadata
from rest_framework.permissions import AllowAny

class FileMetadataViewSet(viewsets.ModelViewSet):
    queryset = FileMetadata.objects.all()
    serializer_class = FileMetadataSerializer
    permission_classes = [AllowAny] 
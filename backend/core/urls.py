from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import FolderViewSet, FileViewSet, FileMetadataViewSet

router = DefaultRouter()
router.register(r'folders', FolderViewSet, basename='folder')
router.register(r'files', FileViewSet, basename='file')
router.register(r'files_metadata', FileMetadataViewSet, basename='file_metadata')

urlpatterns = [
    path('', include(router.urls)),
]
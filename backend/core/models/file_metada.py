from django.db import models

from core.models import File

class FileMetadata(models.Model):
    file = models.OneToOneField(File, on_delete=models.CASCADE, related_name='metadata')
    language = models.CharField(max_length=50, null=True, blank=True)
    named_entities = models.JSONField(null=True, blank=True)
    line_count = models.IntegerField(null=True, blank=True)
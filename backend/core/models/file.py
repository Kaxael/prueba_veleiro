from django.db import models

from core.models.folder import Folder


class File(models.Model):
    folder = models.ForeignKey(Folder, on_delete=models.CASCADE, related_name='files')
    name = models.CharField(max_length=255)
    file = models.FileField(upload_to='uploads/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
from core.models.file_metada import FileMetadata
from core.services.pulse import extract_metadata
from rest_framework import serializers
from core.models import File

class FileMetadataSerializer(serializers.ModelSerializer):
    class Meta:
        model = FileMetadata
        fields = ['language', 'named_entities', 'line_count']

class FileSerializer(serializers.ModelSerializer):
    metadata = FileMetadataSerializer(read_only=True)
    class Meta:
        model = File
        fields = ['id', 'name', 'file', 'folder', 'uploaded_at','metadata']

    def create(self, validated_data):
        file_instance = super().create(validated_data)

        try:
            metadata_response = extract_metadata(file_instance.file.path)
            FileMetadata.objects.create(
                file=file_instance,
                language=metadata_response.get("language"),
                named_entities=metadata_response.get("entities"),
                line_count=metadata_response.get("line_count"),
            )
        except Exception as e:
            print("❌ Error extrayendo metadata:", e)

        return file_instance
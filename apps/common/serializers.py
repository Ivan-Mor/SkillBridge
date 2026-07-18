from rest_framework import serializers


class BaseModelSerializer(serializers.ModelSerializer):
    """Базовый сериализатор: id + created_at + updated_at только для чтения."""
    class Meta:
        abstract = True
        fields = ["id", "created_at", "updated_at"]
        read_only_fields = ["id", "created_at", "updated_at"]
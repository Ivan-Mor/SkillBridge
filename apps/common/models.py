from django.db import models


class TimeStampedModel(models.Model):
    """Базовая модель с created_at / updated_at. Наследуют все доменные модели."""

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

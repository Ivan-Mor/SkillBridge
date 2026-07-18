from rest_framework import status
from rest_framework.test import APITestCase


class HealthCheckTests(APITestCase):
    """Тесты для healthcheck API."""

    def test_healthcheck_returns_ok(self) -> None:
        """GET /health/ должен вернуть 200 и статус ok."""
        response = self.client.get("/health/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {"status": "ok"})

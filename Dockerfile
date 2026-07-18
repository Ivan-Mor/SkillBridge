FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN groupadd --gid 1000 app \
 && useradd --uid 1000 --gid app --create-home app \
 && mkdir -p /opt/venv && chown -R app:app /opt/venv

COPY --from=ghcr.io/astral-sh/uv:0.11.16 /uv /bin/uv

COPY pyproject.toml uv.lock ./
# --dev: ставим dev-зависимости (pytest, ruff) для dev-контейнера.
# Для prod-сборки нужен отдельный Dockerfile.prod или multi-stage build.
RUN uv sync --frozen --dev

COPY . .

RUN chown -R app:app /app
USER app

EXPOSE 8000

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]

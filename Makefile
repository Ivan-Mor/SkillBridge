# SkillBridge Makefile
# Короткие алиасы для типовых команд. Запускается через `make <target>`.
# Требования: Docker Desktop + (на Windows) `make` через chocolatey/scoop/WSL.

.PHONY: help sync up down down-v restart build logs logs-web ps migrate migration superuser shell dbshell test test-app lint format fix check clean

# Префикс для docker compose.
DC = docker compose

help:  ## Показать список доступных команд
	@echo "SkillBridge - доступные команды:"
	@echo ""
	@echo "=== Docker (окружение) ==="
	@echo "  make up          Поднять стек (db+redis+web) в фоне"
	@echo "  make down        Остановить стек (данные БД сохранятся)"
	@echo "  make down-v      Остановить и УДАЛИТЬ том Postgres (осторожно!)"
	@echo "  make restart     Перезапустить все сервисы"
	@echo "  make build       Пересобрать образ web"
	@echo "  make logs        Логи всех сервисов в реальном времени"
	@echo "  make logs-web    Только логи Django"
	@echo "  make ps          Статус контейнеров"
	@echo ""
	@echo "=== Django (внутри web) ==="
	@echo "  make migrate     Применить миграции"
	@echo "  make migration   Создать новые миграции (makemigrations)"
	@echo "  make superuser   Создать суперпользователя"
	@echo "  make shell       Django shell (python manage.py shell)"
	@echo "  make dbshell     psql внутри контейнера db"
	@echo ""
	@echo "=== Качество кода ==="
	@echo "  make test        pytest (в контейнере, с тестовой БД)"
	@echo "  make test-app    pytest для приложения: make test-app app=accounts"
	@echo "  make lint        ruff check (на хосте)"
	@echo "  make format      ruff format (на хосте)"
	@echo "  make fix         ruff check --fix (на хосте)"
	@echo "  make check       Полный чек: fix + lint + format + test"
	@echo ""
	@echo "=== Прочее ==="
	@echo "  make sync        uv sync (поставить зависимости на хост)"
	@echo "  make clean       Удалить кэши (__pycache__, .pytest_cache, .ruff_cache)"

# ============ Docker (окружение) ============

up:  ## Поднять стек в фоне
	$(DC) up -d

down:  ## Остановить стек
	$(DC) down

down-v:  ## Остановить и УДАЛИТЬ тома (ВНИМАНИЕ: потеря данных БД)
	$(DC) down -v

restart:  ## Перезапустить все сервисы
	$(DC) restart

build:  ## Пересобрать образ web
	$(DC) up -d --build

logs:  ## Логи всех сервисов
	$(DC) logs -f

logs-web:  ## Только логи Django
	$(DC) logs -f web

ps:  ## Статус контейнеров
	$(DC) ps -a

# ============ Django (внутри web) ============

migrate:  ## Применить миграции
	$(DC) exec web python manage.py migrate

migration:  ## Создать новые миграции
	$(DC) exec web python manage.py makemigrations

superuser:  ## Создать суперпользователя
	$(DC) exec web python manage.py createsuperuser

shell:  ## Django shell
	$(DC) exec web python manage.py shell

dbshell:  ## psql внутри контейнера db
	$(DC) exec db psql -U postgres -d skill_bridge_db

# ============ Качество кода ============

test:  ## pytest (в контейнере, с тестовой БД)
	$(DC) exec web pytest -v

test-app:  ## pytest для конкретного приложения. Пример: make test-app app=accounts
	$(DC) exec web pytest apps/$(app)/ -v

lint:  ## ruff check (на хосте)
	uv run ruff check .

format:  ## ruff format (на хосте)
	uv run ruff format .

fix:  ## ruff check --fix (на хосте)
	uv run ruff check . --fix

check: fix lint format test  ## Полный чек перед PR (fix + lint + format + test)

# ============ Прочее ============

sync:  ## uv sync (поставить зависимости)
	uv sync

clean:  ## Удалить локальные кэши
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@rm -rf .pytest_cache .ruff_cache .coverage htmlcov 2>/dev/null || true
	@echo "Кэши очищены"

sync:
	uv sync

lint:
	uv run ruff check .

format:
	uv run ruff format .

fix:
	uv run ruff check . --fix

test:
	uv run pytest

run:
	uv run python manage.py runserver

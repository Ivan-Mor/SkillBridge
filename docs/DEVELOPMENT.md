# Команды проверок и разработка

Короткий справочник: как запускать проверки, тесты и типовые операции. Для всей команды (включая Кирилла и Женю).

---

## TL;DR — что делать перед каждым PR

```bash
make check    # fix + lint + format + test одной командой
```

Если всё зелёное — можно пушить и открывать PR.

---

## 1. Что такое `make` и зачем он нужен

**Makefile** — это файл с алиасами для команд. Вместо того чтобы каждый раз набирать длинную строку вроде:

```bash
docker compose exec web python manage.py makemigrations
```

Ты пишешь:

```bash
make migration
```

`make` — это утилита, которая читает `Makefile` в корне проекта и выполняет соответствующую команду. Экономит время и избавляет от опечаток.

### Установка `make`

| ОС | Команда установки |
|---|---|
| **WSL / Linux / macOS** | Уже установлен (`make --version` проверит) |
| **Windows (PowerShell)** | `choco install make` или `scoop install make` |

> **Альтернатива:** Если `make` не установлен, можно копировать команды прямо из `Makefile` и выполнять вручную. Но удобнее поставить.

### Как пользоваться

```bash
make              # покажет список всех команд
make help         # то же самое
make up           # выполнит команду `up` из Makefile
make test         # выполнит команду `test`
make test-app app=accounts  # передаст аргумент app=accounts
```

---

## 2. Два мира: хост vs контейнер

Важно понимать — у нас **два окружения**:

```
Хост (Windows/Linux)              Контейнер web (Linux)
─────────────────────             ──────────────────────
Python 3.13 (через uv)            Python 3.13 (через uv)
.venv/                            /opt/venv/
Postgres НЕ доступен              Postgres доступен по db:5432
Redis НЕ доступен                 Redis доступен по redis:6379

Можно: ruff check, ruff format   Можно: pytest, manage.py commands
Нельзя: pytest (упадёт на БД)    Нельзя: запускать ruff на код хоста
```

**Правило простое:**
- Команды без БД → на хосте (`make lint`, `make format`, `make fix`)
- Команды с БД → в контейнере (`make test`, `make migrate`)

---

## 3. Проверки через Docker

Все команды ниже можно запускать **с хоста** через `make` — Makefile сам проксирует их в контейнер через `docker compose exec`.

### 3.1. Запуск тестов

```bash
make test                    # все тесты проекта
make test-app app=accounts   # тесты конкретного приложения
make test-app app=skills
```

Эквивалентно:
```bash
docker compose exec web pytest -v
docker compose exec web pytest apps/accounts/ -v
```

### 3.2. Линтер и форматирование

Запускаются **на хосте** (быстрее, не нужен контейнер):

```bash
make lint      # проверить ошибки (ruff check .)
make format    # отформатировать код (ruff format .)
make fix       # автоматически исправить что можно (ruff check . --fix)
```

### 3.3. Полная проверка перед PR

```bash
make check
```

Это эквивалент:
```bash
make fix && make lint && make format && make test
```

### 3.4. Проверка миграций

```bash
make migration    # создаст новые миграции, если модели изменились
```

Если ты менял модель в `models.py` — **обязательно** запусти это, иначе CI упадёт на шаге `makemigrations --check --dry-run`.

---

## 4. Управление Docker-окружением

```bash
make up         # поднять стек (db+redis+web) в фоне
make down       # остановить стек (данные сохранятся)
make down-v     # ОСТАНОВИТЬ И УДАЛИТЬ ТОМ БД (осторожно!)
make restart    # перезапустить
make build      # пересобрать образ web (если менялся Dockerfile/pyproject)
make logs       # логи всех сервисов в реальном времени
make logs-web   # только логи Django
make ps         # статус контейнеров
```

### Когда что запускать

| Ситуация | Команда |
|---|---|
| Первый запуск на новой машине | `make build && make migrate` |
| Сменил ветку, изменился код | ничего (bind mount подхватит) |
| Обновился `pyproject.toml` | `make build` |
| Добавил новую модель | `make migration && make migrate` |
| Хочу очистить БД и начать заново | `make down-v && make build` |
| Тесты зависают/ведут себя странно | `make restart` |
| Хочу проверить логи | `make logs-web` |

---

## 5. Django-команды (внутри web)

```bash
make migrate       # применить миграции
make migration     # создать новые миграции
make superuser     # создать суперпользователя (интерактивный ввод)
make shell         # интерактивная Django shell
make dbshell       # psql внутри контейнера db
```

### Полезные примеры в Django shell

```python
# make shell
>>> from django.contrib.auth import get_user_model
>>> User = get_user_model()
>>> User.objects.count()
1
>>> User.objects.first().email
'root@example.com'

>>> from apps.skills.models import Skill
>>> Skill.objects.all()
<QuerySet [<Skill: Python>, <Skill: English>]>
```

---

## 6. CI на GitHub

CI запускается автоматически на каждый push/PR в ветки `main` и `develop`. Делает то же, что и `make check` локально, но в чистом окружении:

1. **Ruff lint + format check** — статический анализ
2. **Django check** — валидность настроек
3. **Check migrations** — `makemigrations --check --dry-run` (упадёт, если забыл закоммитить миграцию)
4. **pytest** — тесты с service-container Postgres
5. **docker-build** — отдельный job: сборка образа + smoke-test

Смотреть статус: вкладка **Actions** в репозитории или внизу PR.

### Если CI упал

1. Открой упавший job → посмотри красный шаг → прочитай ошибку
2. Воспроизведи локально: `make check`
3. Почини → закоммить → запушь → CI автоматически перезапустится

---

## 7. Типовые сценарии

### Сценарий A: добавил новое поле в модель User

```bash
# 1. Отредактировал apps/accounts/models.py (добавил поле bio)
# 2. Создай миграцию
make migration

# 3. Примените её
make migrate

# 4. Проверь что всё работает
make check

# 5. Закоммить и модель, и миграцию В ОДНОМ КОММИТЕ
git add apps/accounts/models.py apps/accounts/migrations/
git commit -m "feat(accounts): add bio field to User"
```

### Сценарий B: тесты падают локально, но CI зелёный

**Причина:** на хосте конфликт с локальным Postgres.

**Решение:** ВСЕГДА гоняй тесты через `make test` (в контейнере), а не через `uv run pytest` (на хосте).

### Сценарий C: после `git pull` ничего не работает

```bash
# 1. Обнови зависимости (если pyproject.toml изменился)
make sync         # обновит .venv на хосте
make build        # пересоберёт venv в контейнере

# 2. Примени новые миграции
make migrate

# 3. Перезапусти стек
make restart
```

### Сценарий D: контейнер web в restart-loop

```bash
# 1. Посмотри логи — там будет traceback
make logs-web

# 2. Если проблема с зависимостями
make build

# 3. Если проблема с БД (InconsistentMigrationHistory и т.п.)
make down-v
make build
make migrate
make superuser
```

### Сценарий E: хочу exploratory-тест API руками

```bash
make up
# Открой в браузере:
#   http://localhost:8000/admin/       — админка
#   http://localhost:8000/api/         — DRF browsable API (после Task 0)
#   http://localhost:8000/health/      — healthcheck (после Task 0)
```

---

## 8. Шпаргалка по командам

### Перед PR (ВСЕГДА)
```bash
make check
```

### Daily routine
```bash
make up           # начал день
make logs-web     # открыл логи в соседнем терминале
# ... работаешь ...
make test         # периодически проверяешь
make down         # закончил день
```

### Emergency
```bash
make down-v && make build   # полный reset окружения
```

---

## 9. Частые ошибки

| Ошибка | Причина | Решение |
|---|---|---|
| `password authentication failed for user "postgres"` | Запуск тестов на хосте | Используй `make test`, не `uv run pytest` |
| `Cannot connect to the Docker daemon` | Docker Desktop не запущен | Запусти Docker Desktop |
| `Container is restarting` | Упал запуск web | `make logs-web`, читай traceback |
| `InconsistentMigrationHistory` | Сменилась схема User | `make down-v && make build` |
| `make: command not found` | Нет `make` на Windows | `choco install make` или работай в WSL |
| `ruff: command not found` | Не установлен venv на хосте | `make sync` (= `uv sync`) |
| CI упал на `makemigrations --check` | Забыл закоммитить миграцию | `make migration`, закоммить файл в `migrations/` |

---

## 10. Если не хочешь использовать `make`

Все команды продублированы в `Makefile` — открой файл и копируй команды вручную. Примеры:

```bash
# Вместо make test:
docker compose exec web pytest -v

# Вместо make migrate:
docker compose exec web python manage.py migrate

# Вместо make lint:
uv run ruff check .
```

Но `make` сильно быстрее и удобнее. Рекомендуем поставить.

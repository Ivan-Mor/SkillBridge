# Contributing — SkillBridge

Короткий гайд для команды из 3 разработчиков. Читать всем перед первым PR.

---

## 1. Окружение

- **Python 3.13+**, **Django 6.0**
- **Менеджер пакетов:** `uv` (не pip). [Установка](https://docs.astral.sh/uv/getting-started/installation/)
- **БД:** PostgreSQL 16, **Кэш/брокер:** Redis 7
- **Запуск:** через Docker (см. раздел 3)

Форк не нужен — все работают в одном репо по веткам.

---

## 2. Структура проекта

```
SkillBridge/
├── apps/                      # Django-приложения
│   ├── accounts/              # User, auth (Epic 1)
│   ├── profiles/              # UserProfile, Certificates (Epic 2)
│   ├── skills/                # Skill, UserSkill, SkillRequest (Epic 2)
│   ├── common/                # Шаренные утилиты, базовые классы
│   └── reviews/               # Отзывы (позже)
├── config/                    # Настройки проекта
│   ├── settings.py            # База (в git)
│   ├── local_settings.py      # Локальные переопределения (в .gitignore)
│   └── ...
├── docs/                      # ТЗ, архитектура
├── skillbridge_memory/        # Журнал решений (не коммитить)
├── pyproject.toml             # Зависимости (через uv)
├── Dockerfile
├── docker-compose.yml
└── Makefile
```

Приложения лежат в `apps/`, но подключаются в `INSTALLED_APPS` без префикса (`"accounts"`, не `"apps.accounts"`). Это работает через `sys.path` в `config/settings.py` — **не удаляй**.

---

## 3. Локальный запуск

```bash
# 0. Установить зависимости (один раз)
uv sync

# 1. Поднять весь стек (db + redis + web)
docker compose up -d --build

# 2. Применить миграции
docker compose exec web python manage.py migrate

# 3. Создать суперпользователя
docker compose exec web python manage.py createsuperuser

# 4. Логи / остановка
docker compose logs -f web
docker compose down              # остановить (данные БД сохранятся)
docker compose down -v           # ВНИМАНИЕ: удалит том Postgres
```

Сайт: `http://localhost:8000/` · Админка: `http://localhost:8000/admin/`

---

## 4. Git workflow (GitHub Flow)

### Ветвление

| Ветка | Назначение |
|---|---|
| `main` | Защищена. Только через PR. Всегда деплой-ready. |
| `feature/<task-id>-<slug>` | Новая фича. Пример: `feature/task-1.2-custom-user-model` |
| `fix/<slug>` | Багфикс. Пример: `fix/docker-restart-loop` |
| `chore/<slug>` | Инфраструктура, зависимости. |
| `docs/<slug>` | Документация. |

### Жизненный цикл задачи

```bash
# Перед стартом — всегда обновляться
git checkout main
git pull origin main

# Создать ветку
git checkout -b feature/task-1.2-custom-user-model

# Работать, коммитить часто
git add .
git commit -m "feat(accounts): add custom User model with email login"

# Запушить
git push -u origin feature/task-1.2-custom-user-model

# Открыть PR на GitHub → main
# Дождаться: CI зелёный + 1 approval от коллеги
# "Squash and merge"

# Почистить
git checkout main
git pull origin main
git branch -d feature/task-1.2-custom-user-model
```

### Если PR протух (пока ревьюили, main ушёл вперёд)

```bash
git checkout feature/task-1.2-custom-user-model
git fetch origin
git rebase origin/main
# решить конфликты, если есть
git push --force-with-lease    # НЕ использовать --force
```

---

## 5. Стиль коммитов (Conventional Commits)

```
<тип>(<scope>): <краткое описание в настоящем времени>
```

**Типы:**
- `feat` — новая функциональность
- `fix` — исправление бага
- `docs` — документация
- `chore` — зависимости, конфиг, инфраструктура
- `refactor` — рефакторинг без изменения поведения
- `test` — тесты
- `style` — форматирование (только если ruff не справился в CI)

**Scopes:** имя приложения или модуля — `accounts`, `skills`, `docker`, `ci`, `settings`.

**Примеры:**
```
feat(accounts): add custom User with email login and role field
fix(docker): move venv to /opt to avoid bind mount collision
docs(readme): add setup instructions
chore(deps): add djangorestframework-simplejwt
test(skills): cover SkillRequest approval flow
```

**Не делай так:**
- ❌ `update` (что обновил?)
- ❌ `fix bug` (какой?)
- ❌ `wip` (зачем пушить WIP в main-ветку?)
- ❌ Коммиты с `.env` или `local_settings.py`

---

## 6. Качество кода

Перед каждым push/PR прогнать локально:

```bash
make lint     # ruff check .
make format   # ruff format .
make fix      # ruff check . --fix
make test     # pytest
```

Или одной командой:
```bash
make fix && make lint && make test
```

**Правила:**
- Линтер — `ruff` с правилами `E, F, I, UP, B, DJ` (см. `pyproject.toml`).
- Длина строки — 88.
- Импорты — автоматически сортируются (`isort` совместимый).
- В `config/settings.py` отключено `E501` (длинные строки с URL/комментариями — ок).

CI упадёт, если `ruff check` или `pytest` не пройдут — PR не вмержится.

---

## 7. Безопасность — секреты

**Никогда не коммить:**
- `.env` (реальные пароли, `SECRET_KEY`)
- `config/local_settings.py` (содержит `environ.Env()` логику + твои креды, если дописал)
- Файлы с токенами (`*.pem`, `credentials.json`)

Оба файла уже в `.gitignore`. **Если случайно закоммитил секрет:**
1. Не пушить.
2. `git reset HEAD~1` если коммит локальный.
3. Если уже в remote — ротация секрета **обязательна**, потом `git filter-repo` или BFG.

В коде — только через `django-environ`:
```python
import environ
env = environ.Env()
environ.Env.read_env()
SECRET_KEY = env.str("SECRET_KEY")
```

---

## 8. Модели и миграции

- **Кастомный `User`** — `AUTH_USER_MODEL = "accounts.User"` (Task 1.2, в работе).
- Создание миграции:
  ```bash
  docker compose exec web python manage.py makemigrations
  docker compose exec web python manage.py migrate
  ```
- Миграции коммитим **вместе** с изменениями моделей в одном PR.
- Не редактируем миграции из `main` — только создаём новые через `makemigrations`.
- Именование полей — `snake_case`. Модели — `PascalCase`.

---

## 9. Чек-лист перед PR

- [ ] Ветка создана от свежего `main`
- [ ] `make fix && make lint && make test` — зелёные
- [ ] Коммиты по Conventional Commits
- [ ] Нет `.env` / `local_settings.py` / `db.sqlite3` в diff
- [ ] Миграции включены в PR (если менял модели)
- [ ] Добавил тесты на новую функциональность
- [ ] В PR-описании: что делает, как тестировать, скриншот (если UI)
- [ ] Запросил ревью у одного из напарников
- [ ] CI на GitHub зелёный

---

## 10. Контакты и процесс

- **Стендап:** ежедневный, 10 минут (что сделал / что делаешь / блокеры)
- **PR висит >24ч без ревью** — пингуй коллегу напрямую
- **Срочный хотфиккс в main** — через hotfix branch + fast review, потом ретро
- **Доступ к секретам прод** — только у lead, через менеджер паролей

---

## TL;DR

```
main защищён → работаешь в feature/* → PR → 1 approval + CI → squash merge
 secretы только в .env → ruff + pytest перед пушем → коммиты по conventional
```

<div align="center">

# 🚀 SkillBridge

### Learn. Teach. Grow Together.

Современная веб-платформа для обмена знаниями и навыками между людьми.

![Python](https://img.shields.io/badge/Python-3.13-blue)
![Django](https://img.shields.io/badge/Django-5.x-success)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue)
![Redis](https://img.shields.io/badge/Redis-8-red)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

# 📖 О проекте

**SkillBridge** — это веб-платформа, позволяющая пользователям обмениваться знаниями и навыками без денежного взаимодействия.

Основная идея проекта заключается в том, что каждый человек обладает знаниями, которыми может поделиться, и одновременно хочет освоить новые навыки.

Пример:

> 👨 Алексей умеет Django и хочет изучить Blender.

> 👩 Мария отлично владеет Blender и хочет научиться Python.

SkillBridge помогает таким пользователям найти друг друга и организовать взаимное обучение.

---

# ✨ Основные возможности

- 👤 регистрация и авторизация пользователей;
- 📝 персональный профиль;
- 🧠 каталог навыков;
- ❤️ избранные пользователи;
- 🔍 поиск пользователей по навыкам;
- 🎯 фильтрация по категориям;
- 🤝 отправка заявок на обмен навыками;
- ⭐ система отзывов;
- 🔔 уведомления;
- 📈 рейтинг пользователей;
- 🛡 административная панель;
- ⚡ кеширование данных через Redis.

---

# 🎯 Цели проекта

Проект создается как командный pet-проект и предназначен для:

- изучения коммерческой архитектуры Django;
- практики командной разработки;
- демонстрации навыков backend-разработки;
- изучения PostgreSQL;
- работы с Redis;
- применения Git Flow;
- наполнения портфолио.

---

# 🛠 Используемый стек

## Backend

- Python 3.13
- Django 5.x
- PostgreSQL
- Redis

## Frontend

- HTML5
- CSS3
- Bootstrap 5
- JavaScript

## Инфраструктура

- Docker
- Docker Compose
- Gunicorn
- Nginx

## Инструменты разработки

- Git
- GitHub
- GitHub Actions
- Ruff
- Black
- pre-commit

---

# 🏛 Архитектура

Проект разрабатывается согласно принципам:

- MTV (Django)
- Service Layer
- Thin Views
- Fat Models (только там, где это оправдано)
- DRY
- SOLID (по возможности)
- KISS
- YAGNI

Бизнес-логика выносится в сервисный слой, а представления отвечают только за обработку HTTP-запросов.

---

# 📂 Структура репозитория

```text
SkillBridge/
│
├── apps/
├── config/
├── docs/
├── media/
├── static/
├── templates/
│
├── docker/
├── nginx/
│
├── requirements/
│
├── .env.example
├── docker-compose.yml
├── Dockerfile
├── manage.py
│
└── README.md
```

---

# 📚 Документация

Вся техническая документация находится в папке `docs`.

| Документ | Описание |
|----------|----------|
| 01_Project_Overview.md | Общая информация о проекте |
| 02_Tech_Stack.md | Используемые технологии |
| 03_Project_Structure.md | Структура проекта |
| 04_Architecture.md | Архитектура приложения |
| 05_Database.md | Схема базы данных |
| 06_Models.md | Описание моделей |
| 07_Business_Logic.md | Бизнес-процессы |
| 08_Functional_Requirements.md | Функциональные требования |
| 09_User_Flows.md | Пользовательские сценарии |
| 10_URLs.md | Маршруты проекта |
| 11_Views.md | Представления |
| 12_Forms.md | Django Forms |
| 13_Services.md | Сервисный слой |
| 14_Redis.md | Использование Redis |
| 15_Testing.md | Тестирование |
| 16_Deployment.md | Развертывание |
| 17_Team.md | Организация команды |
| 18_RoadMap.md | План разработки |
| 19_ER_Diagram.md | ER-диаграмма |
| 20_Checklist.md | Критерии готовности |

---

# 🚀 Быстрый запуск

## Клонирование проекта

```bash
git clone https://github.com/your-username/skillbridge.git

cd skillbridge
```

---

## Создание виртуального окружения

```bash
python -m venv .venv
```

---

## Активация

Linux

```bash
source .venv/bin/activate
```

Windows

```powershell
.venv\Scripts\activate
```

---

## Установка зависимостей

```bash
pip install -r requirements/dev.txt
```

---

## Настройка окружения

Создать файл

```
.env
```

на основе

```
.env.example
```

---

## Применение миграций

```bash
python manage.py migrate
```

---

## Создание суперпользователя

```bash
python manage.py createsuperuser
```

---

## Запуск

```bash
python manage.py runserver
```

---

# 🧩 Основные сущности

- User
- Profile
- Skill
- Category
- Offer
- Review
- Notification
- Favorite

---

# 👥 Команда

| Роль | Обязанности |
|------|-------------|
| Team Lead | Архитектура, Backend, Code Review |
| Backend Developer | CRUD, поиск, фильтрация |
| Frontend Developer | Bootstrap, шаблоны, UI |

---

# 🗺 План развития

## Версия 1.0

- регистрация
- профиль
- навыки
- обмен
- отзывы

---

## Версия 1.1

- уведомления

- избранное

- рейтинг

---

## Версия 1.2

- рекомендации пользователей

- чат

- email

---

## Версия 2.0

- REST API

- мобильное приложение

- OAuth

- WebSocket

---

# 📜 Лицензия

Проект распространяется по лицензии MIT.

---

<div align="center">

Made with ❤️ using Django

</div>
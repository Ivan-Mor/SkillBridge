# MASTER_CONTEXT.md

# SkillBridge — Master Project Context

Версия: 1.0

---

# О проекте

Мы разрабатываем полноценный pet-проект уровня коммерческого веб-приложения.

Это НЕ учебный CRUD.

Это полноценный сервис с качественной архитектурой.

Название проекта:

# SkillBridge

Слоган

> Learn. Teach. Grow Together.

---

# Главная идея

SkillBridge — веб-платформа для обмена знаниями между людьми.

Пользователь может одновременно:

- обучать других;
- изучать новые навыки.

Пример

Алексей

умеет

- Python
- Django

хочет изучить

- Blender

Мария

умеет

- Blender

хочет изучить

- Python

SkillBridge помогает таким пользователям найти друг друга.

---

# Основные принципы

Мы НЕ хотим делать:

❌ ToDo

❌ Интернет-магазин

❌ Блог

❌ Социальную сеть

❌ Таск-трекер

Проект должен выглядеть как настоящий стартап.

---

# Цель проекта

Проект создается преимущественно для портфолио.

Нужно показать:

- хорошую архитектуру
- PostgreSQL
- Django
- Redis
- Bootstrap
- Git Flow
- работу в команде
- качественную документацию

---

# Команда

3 человека.

## Разработчик №1

Самый опытный.

Он является Team Lead.

Отвечает за:

- архитектуру
- PostgreSQL
- Django
- авторизацию
- Redis
- Code Review
- Docker
- Git
- Merge Request

---

## Разработчик №2

Backend Junior

Основные задачи:

CRUD

Поиск

Фильтрация

Отзывы

Избранное

Админка

---

## Разработчик №3

Frontend Junior

Bootstrap

HTML

Templates

Forms

UI

---

# Стек

Backend

Python 3.13

Django 5.x

PostgreSQL

Redis

---

Frontend

HTML5

CSS3

Bootstrap 5

JavaScript

---

Infrastructure

Docker

Docker Compose

Gunicorn

Nginx

---

Tools

Git

GitHub

GitHub Actions

Black

Ruff

pre-commit

---

# Архитектура

Используем современную архитектуру Django.

Не складываем всю бизнес-логику во View.

Используем Service Layer.

Каждое приложение имеет примерно такую структуру.

models.py

views.py

urls.py

forms.py

services.py

selectors.py

signals.py

admin.py

tests/

templates/

static/

---

# Структура проекта

apps/

accounts/

profiles/

skills/

offers/

reviews/

notifications/

common/

config/

templates/

static/

media/

docs/

---

# Документация

Мы решили писать полноценную документацию уровня коммерческого проекта.

Не одно ТЗ.

А папку docs.

План документации.

README.md

01_Project_Overview.md

02_Tech_Stack.md

03_Project_Structure.md

04_Architecture.md

05_Database.md

06_Models.md

07_Business_Logic.md

08_Functional_Requirements.md

09_User_Flows.md

10_URLs.md

11_Views.md

12_Forms.md

13_Services.md

14_Redis.md

15_Testing.md

16_Deployment.md

17_Team.md

18_RoadMap.md

19_ER_Diagram.md

20_Checklist.md

---

# Стиль документации

Документация должна выглядеть как настоящая документация коммерческого проекта.

Максимально подробно.

Использовать:

- большие таблицы
- Mermaid Diagram
- UML
- ER Diagram
- Sequence Diagram
- Component Diagram
- красивые Markdown-блоки
- GitHub Alerts
- примеры

Не экономить на объеме.

---

# Что уже сделано

README.md

Полностью написан.

01_Project_Overview.md

Полностью написан.

---

# Что дальше

Продолжаем строго по порядку.

Следующий документ:

02_Tech_Stack.md

После него

03_Project_Structure.md

И так далее.

---

# Требование к ChatGPT

Документация должна выглядеть так, словно ее писали Senior Backend Developer и Software Architect.

Никакой "учебной" документации.

Каждый файл должен быть максимально подробным.

Нужно объяснять не только "что используется", но и "почему именно это решение было принято".

Предпочтение отдавать реальным практикам коммерческой разработки.

Не сокращать объем.

При необходимости использовать несколько сообщений для одного документа.

Главная цель — получить документацию, которую не стыдно показать работодателю.
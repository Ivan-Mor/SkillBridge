# 07. HTTP Layer

> Документ описывает HTTP-слой проекта **SkillBridge**: маршрутизацию, представления, формы, шаблоны, обработку пользовательского ввода, права доступа и принципы взаимодействия между `urls.py`, `views.py`, `forms.py` и templates.

---

# Содержание

1. Назначение HTTP-слоя
2. Общий поток обработки запроса
3. URL Layer
4. View Layer
5. Form Layer
6. Template Layer
7. Access Control
8. Error Handling
9. URL → View → Form → Template
10. Правила разработки
11. Заключение

---

# Назначение HTTP-слоя

HTTP-слой отвечает за взаимодействие пользователя с приложением через браузер.

Он включает:

- маршруты;
- views;
- формы;
- шаблоны;
- обработку GET и POST-запросов;
- проверки доступа;
- отображение ошибок;
- перенаправления.

HTTP-слой не должен содержать бизнес-логику.

Бизнес-операции выполняются в Service Layer.

---

# Общий поток обработки запроса

```text
Browser

↓

URL Dispatcher

↓

View

↓

Form

↓

Service

↓

Selector / ORM

↓

Template

↓

HTTP Response
```

---

# URL Layer

## Назначение

`urls.py` отвечает за маршрутизацию HTTP-запросов.

Каждое Django-приложение имеет собственный файл маршрутов.

```text
apps/
├── accounts/
│   └── urls.py
├── profiles/
│   └── urls.py
├── skills/
│   └── urls.py
├── offers/
│   └── urls.py
├── reviews/
│   └── urls.py
└── notifications/
    └── urls.py
```

---

## Главный urls.py

Файл `config/urls.py` подключает маршруты всех приложений.

```python
urlpatterns = [
    path("admin/", admin.site.urls),
    path("accounts/", include("apps.accounts.urls")),
    path("profiles/", include("apps.profiles.urls")),
    path("skills/", include("apps.skills.urls")),
    path("offers/", include("apps.offers.urls")),
    path("reviews/", include("apps.reviews.urls")),
    path("notifications/", include("apps.notifications.urls")),
]
```

---

## Именование URL

Все маршруты должны иметь имена.

Пример:

```python
app_name = "offers"

urlpatterns = [
    path("", OfferListView.as_view(), name="list"),
    path("<int:pk>/", OfferDetailView.as_view(), name="detail"),
    path("create/<int:user_id>/", OfferCreateView.as_view(), name="create"),
]
```

Использование `name` позволяет избегать хардкода URL в шаблонах и views.

---

# View Layer

## Назначение

View принимает HTTP-запрос и возвращает HTTP-ответ.

View может:

- получить данные из запроса;
- проверить авторизацию;
- вызвать форму;
- вызвать сервис;
- подготовить context;
- вернуть template response;
- выполнить redirect.

View не должна:

- содержать бизнес-логику;
- выполнять сложные ORM-запросы;
- напрямую изменять несколько связанных моделей;
- рассчитывать рейтинги;
- создавать уведомления напрямую.

---

## Class-Based Views

Основной подход проекта — использование Class-Based Views.

Используются:

- `ListView`;
- `DetailView`;
- `CreateView`;
- `UpdateView`;
- `DeleteView`;
- `TemplateView`.

---

## Пример View

```python
class OfferCreateView(LoginRequiredMixin, FormView):
    template_name = "offers/offer_create.html"
    form_class = OfferCreateForm

    def form_valid(self, form):
        offer_create(
            sender=self.request.user,
            receiver=form.cleaned_data["receiver"],
            teach_skill=form.cleaned_data["teach_skill"],
            learn_skill=form.cleaned_data["learn_skill"],
            message=form.cleaned_data["message"],
        )
        return redirect("offers:list")
```

View только принимает данные и вызывает сервис.

---

# Form Layer

## Назначение

Forms отвечают за пользовательский ввод.

Форма выполняет:

- валидацию;
- очистку данных;
- отображение ошибок;
- подготовку данных для Service Layer.

Форма не должна создавать сложные бизнес-объекты самостоятельно.

---

## Пример формы

```python
class OfferCreateForm(forms.Form):
    receiver = forms.ModelChoiceField(queryset=User.objects.filter(is_active=True))
    teach_skill = forms.ModelChoiceField(queryset=Skill.objects.filter(is_active=True))
    learn_skill = forms.ModelChoiceField(queryset=Skill.objects.filter(is_active=True))
    message = forms.CharField(widget=forms.Textarea, required=False)
```

---

## Валидация

Форма может проверять:

- обязательные поля;
- формат email;
- длину текста;
- допустимые значения;
- корректность пользовательского ввода.

Бизнес-валидация выполняется в сервисах.

Например:

```text
Форма проверяет:

✓ поле заполнено

Сервис проверяет:

✓ можно ли создать Offer
✓ нет ли активного предложения
✓ sender != receiver
```

---

# Template Layer

## Назначение

Templates отвечают за отображение HTML.

Шаблоны не должны содержать бизнес-логику.

Они могут:

- выводить данные;
- показывать формы;
- отображать ошибки;
- использовать template tags;
- подключать компоненты интерфейса.

---

## Общая структура

```text
templates/
├── base.html
├── includes/
│   ├── navbar.html
│   └── footer.html
├── components/
│   ├── card.html
│   └── pagination.html
└── errors/
    ├── 403.html
    ├── 404.html
    └── 500.html
```

---

# Access Control

## Авторизация

Для защищённых страниц используется `LoginRequiredMixin`.

```python
class ProfileUpdateView(LoginRequiredMixin, UpdateView):
    ...
```

---

## Проверка владельца

Пользователь может редактировать только собственные данные.

```text
request.user == object.user
```

---

## Проверка ролей

Административные действия доступны только пользователям с правами staff.

```text
is_staff = True
```

---

# Error Handling

Проект должен корректно обрабатывать ошибки.

Основные страницы:

| Ошибка | Назначение |
|-------|------------|
| 403 | Нет доступа |
| 404 | Страница не найдена |
| 500 | Внутренняя ошибка сервера |

---

# URL → View → Form → Template

## Accounts

| URL | View | Form | Template |
|-----|------|------|----------|
| `/accounts/register/` | RegisterView | RegisterForm | `accounts/register.html` |
| `/accounts/login/` | LoginView | AuthenticationForm | `accounts/login.html` |
| `/accounts/logout/` | LogoutView | — | — |
| `/accounts/password-reset/` | PasswordResetView | PasswordResetForm | `accounts/password_reset.html` |

---

## Profiles

| URL | View | Form | Template |
|-----|------|------|----------|
| `/profiles/<int:pk>/` | ProfileDetailView | — | `profiles/detail.html` |
| `/profiles/me/edit/` | ProfileUpdateView | ProfileForm | `profiles/edit.html` |

---

## Skills

| URL | View | Form | Template |
|-----|------|------|----------|
| `/skills/` | SkillListView | SkillSearchForm | `skills/list.html` |
| `/skills/my/` | UserSkillListView | — | `skills/my_skills.html` |
| `/skills/my/add/` | UserSkillCreateView | UserSkillForm | `skills/user_skill_form.html` |
| `/skills/my/<int:pk>/edit/` | UserSkillUpdateView | UserSkillForm | `skills/user_skill_form.html` |

---

## Offers

| URL | View | Form | Template |
|-----|------|------|----------|
| `/offers/` | OfferListView | — | `offers/list.html` |
| `/offers/inbox/` | OfferInboxView | — | `offers/inbox.html` |
| `/offers/sent/` | OfferSentView | — | `offers/sent.html` |
| `/offers/<int:pk>/` | OfferDetailView | — | `offers/detail.html` |
| `/offers/create/<int:user_id>/` | OfferCreateView | OfferCreateForm | `offers/create.html` |
| `/offers/<int:pk>/accept/` | OfferAcceptView | — | redirect |
| `/offers/<int:pk>/decline/` | OfferDeclineView | — | redirect |
| `/offers/<int:pk>/cancel/` | OfferCancelView | — | redirect |
| `/offers/<int:pk>/complete/` | OfferCompleteView | — | redirect |

---

## Reviews

| URL | View | Form | Template |
|-----|------|------|----------|
| `/reviews/create/<int:offer_id>/` | ReviewCreateView | ReviewForm | `reviews/create.html` |
| `/reviews/user/<int:user_id>/` | UserReviewListView | — | `reviews/user_reviews.html` |

---

## Notifications

| URL | View | Form | Template |
|-----|------|------|----------|
| `/notifications/` | NotificationListView | — | `notifications/list.html` |
| `/notifications/<int:pk>/read/` | NotificationReadView | — | redirect |
| `/notifications/read-all/` | NotificationReadAllView | — | redirect |

---

# Правила разработки HTTP-слоя

## View

View должна быть тонкой.

Допустимо:

```text
получить request

↓

проверить доступ

↓

вызвать form

↓

вызвать service

↓

вернуть response
```

Недопустимо:

```text
создавать несколько моделей прямо во View

писать сложные ORM-запросы

рассчитывать бизнес-статусы

создавать уведомления напрямую
```

---

## Forms

Forms отвечают только за ввод.

Они не должны управлять бизнес-процессами.

---

## URLs

Все URL должны быть:

- читаемыми;
- именованными;
- сгруппированными по приложениям;
- стабильными.

---

## Templates

Templates должны быть простыми.

Вся сложная логика должна находиться во View, Selector или Service.

---

# Заключение

HTTP-слой SkillBridge построен вокруг принципа тонких представлений.

`urls.py` отвечает за маршрутизацию.

`views.py` отвечает за обработку HTTP-запросов.

`forms.py` отвечает за ввод и валидацию.

Templates отвечают за отображение интерфейса.

Бизнес-логика не размещается в HTTP-слое. Она выносится в Service Layer, что делает проект проще для тестирования, сопровождения и дальнейшего расширения.

import pytest
from django.contrib.auth import get_user_model
from django.db import IntegrityError

User = get_user_model()


@pytest.mark.django_db
def test_create_user_with_email():
    user = User.objects.create_user(email="test@example.com", password="pa55word!")
    assert user.pk is not None
    assert user.email == "test@example.com"
    assert user.check_password("pa55word!")
    assert not user.is_staff
    assert not user.is_superuser


@pytest.mark.django_db
def test_email_must_be_unique():
    User.objects.create_user(email="dup@example.com", password="pa55word!")
    with pytest.raises(IntegrityError):
        User.objects.create_user(email="dup@example.com", password="other123!")


@pytest.mark.django_db
def test_default_role_is_user():
    user = User.objects.create_user(email="r@example.com", password="pa55word!")
    assert user.role == User.Role.USER


@pytest.mark.django_db
def test_is_blocked_default_false():
    user = User.objects.create_user(email="b@example.com", password="pa55word!")
    assert not user.is_blocked


@pytest.mark.django_db
def test_create_superuser_is_staff_and_superuser():
    admin = User.objects.create_superuser(
        email="root@example.com", password="pa55word!"
    )
    assert admin.is_staff
    assert admin.is_superuser
    assert admin.role == User.Role.USER


@pytest.mark.django_db
def test_str_returns_email():
    user = User.objects.create_user(email="str@example.com", password="pa55word!")
    assert str(user) == "str@example.com"


@pytest.mark.django_db
def test_last_seen_nullable():
    user = User.objects.create_user(email="ls@example.com", password="pa55word!")
    assert user.last_seen is None

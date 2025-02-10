from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms

from .models import CustomUser


class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(required=True)
    first_name = forms.CharField(required=False)
    last_name = forms.CharField(required=False)

    class Meta:
        model = CustomUser
        fields = ("username", "email", "first_name", "last_name", "birth_date")


class CustomUserChangeForm(UserChangeForm):
    email = forms.EmailField(required=True)
    first_name = forms.CharField(required=False)
    last_name = forms.CharField(required=False)

    class Meta:
        model = CustomUser
        fields = ("username", "email", "first_name", "last_name", "birth_date")

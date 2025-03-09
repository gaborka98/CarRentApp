from unittest.mock import patch, MagicMock
from django.test import TestCase
from .forms import CustomUserCreationForm


# Create your tests here.
class CustomUserCreationFormTest(TestCase):
    @patch('accounts.models.CustomUser.save')  # Mockoljuk a model mentési metódusát
    def test_form_save_with_mock(self, mock_save):
        mock_save.return_value = MagicMock()  # Mockolt mentési eredmény

        form_data = {
            "username": "testuser",
            "email": "test@example.com",
            "first_name": "Test",
            "last_name": "User",
            "birth_date": "2000-01-01",
            "password1": "TestPassword123",
            "password2": "TestPassword123"
        }
        form = CustomUserCreationForm(data=form_data)

        self.assertTrue(form.is_valid())  # Ellenőrizzük, hogy a form valid-e
        user = form.save(commit=True)  # Meghívjuk a mentést, amit mockoltunk

        mock_save.assert_called_once()  # Ellenőrizzük, hogy a save() meghívódott-e
        self.assertIsNotNone(user)  # Ellenőrizzük, hogy kaptunk-e user objektumot

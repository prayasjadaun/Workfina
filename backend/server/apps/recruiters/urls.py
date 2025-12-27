from django.urls import path
from .views import HRRegistrationView, hr_profile

urlpatterns = [
    path('register/', HRRegistrationView.as_view(), name='hr-register'),
    path('profile/', hr_profile, name='hr-profile'),
]
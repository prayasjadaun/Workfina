from django.urls import path
from .views import CandidateRegistrationView, CandidateListView, unlock_candidate, get_unlocked_candidates

urlpatterns = [
    path('register/', CandidateRegistrationView.as_view(), name='candidate-register'),
    path('list/', CandidateListView.as_view(), name='candidate-list'),
    path('<int:candidate_id>/unlock/', unlock_candidate, name='unlock-candidate'),
    path('unlocked/', get_unlocked_candidates, name='unlocked-candidates'),
]
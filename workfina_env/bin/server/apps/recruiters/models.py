from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class HRProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='hr_profile')
    company_name = models.CharField(max_length=255)
    designation = models.CharField(max_length=100)
    phone = models.CharField(max_length=20)
    company_website = models.URLField(blank=True)
    company_size = models.CharField(max_length=50, choices=[
        ('1-10', '1-10 employees'),
        ('11-50', '11-50 employees'), 
        ('51-200', '51-200 employees'),
        ('201-1000', '201-1000 employees'),
        ('1000+', '1000+ employees')
    ])
    credits_balance = models.PositiveIntegerField(default=0)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def can_unlock(self, credits_required=10):
        return self.credits_balance >= credits_required
    
    def deduct_credits(self, amount=10):
        if self.can_unlock(amount):
            self.credits_balance -= amount
            self.save()
            return True
        return False
    
    def __str__(self):
        return f"{self.company_name} - {self.user.email}"
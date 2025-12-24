from django.contrib import admin
from .models import HRProfile

@admin.register(HRProfile)
class HRProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'company_name', 'designation', 'credits_balance', 'is_verified']
    list_filter = ['is_verified', 'company_size']
    search_fields = ['company_name', 'user__email']
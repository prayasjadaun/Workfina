from rest_framework import serializers
from .models import HRProfile

class HRRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = HRProfile
        fields = [
            'company_name', 'designation', 'phone', 
            'company_website', 'company_size'
        ]
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)

class HRProfileSerializer(serializers.ModelSerializer):
    email = serializers.CharField(source='user.email', read_only=True)
    
    class Meta:
        model = HRProfile
        fields = [
            'email', 'company_name', 'designation', 'phone',
            'company_website', 'company_size', 'credits_balance',
            'is_verified'
        ]
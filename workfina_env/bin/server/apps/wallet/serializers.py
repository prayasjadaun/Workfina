from rest_framework import serializers
from .models import Wallet, WalletTransaction

class WalletSerializer(serializers.ModelSerializer):
    company_name = serializers.CharField(source='hr_profile.company_name', read_only=True)
    
    class Meta:
        model = Wallet
        fields = ['id', 'company_name', 'balance', 'total_spent', 'created_at']
        read_only_fields = ['balance', 'total_spent', 'created_at']

class WalletTransactionSerializer(serializers.ModelSerializer):
    company_name = serializers.CharField(source='wallet.hr_profile.company_name', read_only=True)
    
    class Meta:
        model = WalletTransaction
        fields = [
            'id', 'company_name', 'transaction_type', 'credits_added',
            'credits_used', 'reference_id', 'description', 'created_at'
        ]

class RechargeWalletSerializer(serializers.Serializer):
    credits = serializers.IntegerField(min_value=1)
    payment_reference = serializers.CharField(max_length=100, required=False)
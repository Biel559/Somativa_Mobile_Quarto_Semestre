from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']

class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'phone', 'address', 'cep', 'created_at']
        read_only_fields = ['id', 'created_at']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, style={'input_type': 'password'})
    phone = serializers.CharField(max_length=15, required=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'phone']
    
    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError("Senhas não conferem!")
        if User.objects.filter(username=data['username']).exists():
            raise serializers.ValidationError("Usuário já existe!")
        if User.objects.filter(email=data['email']).exists():
            raise serializers.ValidationError("Email já registrado!")
        return data
    
    def create(self, validated_data):
        phone = validated_data.pop('password2')
        phone = validated_data.pop('phone')
        
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        
        UserProfile.objects.create(user=user, phone=phone)
        return user

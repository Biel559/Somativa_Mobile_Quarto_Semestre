from rest_framework import serializers
from .models import Food

class FoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Food
        fields = ['id', 'name', 'description', 'price', 'category', 'image', 'available', 'created_at']
        read_only_fields = ['id', 'created_at']
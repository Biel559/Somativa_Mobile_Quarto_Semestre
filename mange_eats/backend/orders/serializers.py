from rest_framework import serializers
from .models import Order, OrderItem
from menu.serializers import FoodSerializer

class OrderItemSerializer(serializers.ModelSerializer):
    food = FoodSerializer(read_only=True)
    food_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = OrderItem
        fields = ['id', 'food', 'food_id', 'quantity', 'price']
        read_only_fields = ['id', 'price']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = Order
        fields = ['id', 'username', 'total_price', 'delivery_fee', 'delivery_address', 
                  'delivery_cep', 'status', 'items', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

from django.contrib import admin
from .models import Order, OrderItem

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ['price']

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    inlines = [OrderItemInline]
    list_display = ['id', 'user', 'total_price', 'delivery_fee', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['user__username', 'delivery_cep']
    readonly_fields = ['created_at', 'updated_at']
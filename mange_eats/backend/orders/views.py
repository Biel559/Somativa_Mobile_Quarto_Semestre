from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderItemSerializer

class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Retorna apenas pedidos do usuário autenticado"""
        return Order.objects.filter(user=self.request.user)
    
    def create(self, request, *args, **kwargs):
        """Criar novo pedido"""
        items_data = request.data.get('items', [])
        total_price = request.data.get('total_price', 0)
        delivery_fee = request.data.get('delivery_fee', 0)
        delivery_address = request.data.get('delivery_address', '')
        delivery_cep = request.data.get('delivery_cep', '')
        
        if not items_data:
            return Response(
                {'error': 'Pedido precisa ter itens!'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Criar pedido
        order = Order.objects.create(
            user=request.user,
            total_price=total_price,
            delivery_fee=delivery_fee,
            delivery_address=delivery_address,
            delivery_cep=delivery_cep,
            status='pending'
        )
        
        # Adicionar itens ao pedido
        for item_data in items_data:
            OrderItem.objects.create(
                order=order,
                food_id=item_data['food_id'],
                quantity=item_data['quantity'],
                price=item_data['price']
            )
        
        serializer = self.get_serializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        """Confirmar pedido"""
        order = self.get_object()
        order.status = 'confirmed'
        order.save()
        
        return Response({
            'message': 'Pedido confirmado com sucesso!',
            'order': OrderSerializer(order).data
        }, status=status.HTTP_200_OK)
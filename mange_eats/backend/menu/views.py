from rest_framework import viewsets
from .models import Food
from .serializers import FoodSerializer

class FoodViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet para visualizar alimentos"""
    queryset = Food.objects.filter(available=True)
    serializer_class = FoodSerializer
    
    def get_queryset(self):
        queryset = Food.objects.filter(available=True)
        category = self.request.query_params.get('category', None)
        
        if category:
            queryset = queryset.filter(category=category)
        
        return queryset
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny
from django.contrib.auth.models import User
from .models import UserProfile
from .serializers import UserSerializer, UserProfileSerializer, RegisterSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        """Registrar novo usuário"""
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'message': 'Usuário criado com sucesso!',
                'token': token.key,
                'user': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])    
    def login(self, request):
        """Login de usuário COM DEBUG"""
        print("--------------------------------------------------")
        print(">>> INICIANDO TENTATIVA DE LOGIN")
        
        # Pega os dados brutos
        print(f">>> Dados recebidos (request.data): {request.data}")
        
        username = request.data.get('username')
        password = request.data.get('password')
        
        print(f">>> Username extraído: '{username}' (Tipo: {type(username)})")
        print(f">>> Password extraído: '{password}' (Tipo: {type(password)})")
        
        try:
            user = User.objects.get(username=username)
            print(f">>> Usuário '{username}' encontrado no Banco de Dados (ID: {user.id})")
            
            # Testa a senha
            senha_confere = user.check_password(password)
            print(f">>> Resultado da conferência de senha: {senha_confere}")
            
            if senha_confere:
                token, created = Token.objects.get_or_create(user=user)
                print(f">>> Login BEM SUCEDIDO. Token gerado: {token.key}")
                print("--------------------------------------------------")
                return Response({
                    'message': 'Login realizado com sucesso!',
                    'token': token.key,
                    'user': UserSerializer(user).data
                }, status=status.HTTP_200_OK)
            else:
                print(">>> ERRO: A senha não bateu com o hash do banco.")
                print("--------------------------------------------------")
                return Response({'error': 'Senha incorreta!'}, status=status.HTTP_401_UNAUTHORIZED)
                
        except User.DoesNotExist:
            print(f">>> ERRO: Usuário '{username}' NÃO existe no banco.")
            print("--------------------------------------------------")
            return Response({'error': 'Usuário não encontrado!'}, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Retorna dados do usuário autenticado"""
        try:
            profile = UserProfile.objects.get(user=request.user)
            serializer = UserProfileSerializer(profile)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except UserProfile.DoesNotExist:
            return Response({'error': 'Perfil não encontrado!'}, status=status.HTTP_404_NOT_FOUND)
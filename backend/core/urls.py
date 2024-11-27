from django.urls import path
from .views import admin_login, admin_dashboard, admin_logout, FarmerRegistrationView, BuyerRegistrationView, \
    LoginView, ProductListView, AddProductView, FarmerProductList, UpdateProductView

urlpatterns = [
    path('', admin_login, name='admin_login'),
    path('dashboard/', admin_dashboard, name='admin_dashboard'),
    path('logout/', admin_logout, name='admin_logout'),
    path('api/farmers/', FarmerRegistrationView.as_view(), name='farmer_registration'),
    path('api/buyers/', BuyerRegistrationView.as_view(), name='buyer_registration'),
    path('api/login/', LoginView.as_view(), name='login'),
    path('api/products/', ProductListView.as_view(), name='products_list'),
    path('api/add_product/', AddProductView.as_view(), name='product'),
    path('api/farmer/products/<int:farmer_id>/', FarmerProductList.as_view(), name='farmer_products'),
    path('api/products/<int:product_id>/update/', UpdateProductView.as_view(), name='update_product'),
]

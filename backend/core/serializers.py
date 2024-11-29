from rest_framework import serializers
from .models import *
from django.contrib.auth.hashers import make_password


class FarmerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farmer
        fields = '__all__'

    # Automatically hash passwords when creating or updating
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # Set the account status to 'pending' whenever updating the profile
        # validated_data['account_status'] = 'pending'

        if 'password' in validated_data:
            validated_data['password'] = make_password(validated_data['password'])

        return super().update(instance, validated_data)

    # Exclude the password field from API response
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation.pop('password', None)  # Remove 'password' field
        return representation





class BuyerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Buyer
        fields = '__all__'

    # Automatically hash passwords when creating or updating
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

    def update(self, instance, validated_data):
        if 'password' in validated_data:
            validated_data['password'] = make_password(validated_data['password'])
        return super().update(instance, validated_data)

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'
        
    def validate_farmer(self, value):
        # Check if the farmer exists
        if not Farmer.objects.filter(id=value.id).exists():
            raise serializers.ValidationError("Farmer with this ID does not exist.")
        return value

    def create(self, validated_data):
        return Product.objects.create(**validated_data)
    

        
class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = '__all__'

class CartSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = Cart
        fields = ['id', 'product_name', 'amount', 'total_price']


class OrderProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = '__all__'
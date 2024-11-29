import logging

from django.core.mail import send_mail
from django.shortcuts import get_object_or_404
from django.shortcuts import render, redirect
from django.contrib.auth.hashers import check_password, make_password
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import *

class BuyerCartAPIView(APIView):
    def get(self, request, user_id):
        try:
            carts = Cart.objects.filter(buyer__id=user_id)
            serializer = CartSerializer(carts, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
class AddToCartView(APIView):
    def post(self, request):
        try:
            user_id = request.data.get('user_id')
            product_id = request.data.get('product_id')
            quantity = request.data.get('quantity')

            # Validate fields
            if not user_id or not product_id or not quantity:
                return Response({"error": "Missing fields"}, status=status.HTTP_400_BAD_REQUEST)

            # Fetch related objects
            buyer = Buyer.objects.get(pk=user_id)
            product = Product.objects.get(pk=product_id)

            if product.quantity < quantity:
                return Response({"error": "Insufficient stock"}, status=status.HTTP_400_BAD_REQUEST)

            # Calculate total price
            total_price = product.price * quantity

            # Create cart entry
            cart_item = Cart.objects.create(
                product=product,
                buyer=buyer,
                amount=quantity,
                total_price=total_price
            )

            return Response({"message": "Product added to cart successfully"}, status=status.HTTP_200_OK)

        except Product.DoesNotExist:
            return Response({"error": "Product not found"}, status=status.HTTP_400_BAD_REQUEST)
        except Buyer.DoesNotExist:
            return Response({"error": "Buyer not found"}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class FarmerProfileView(APIView):
    def put(self, request, farmer_id, format=None):
        try:
            farmer = Farmer.objects.get(id=farmer_id)
        except Farmer.DoesNotExist:
            return Response({'message': 'Farmer not found'}, status=status.HTTP_404_NOT_FOUND)

        # Log incoming request data
        print(f"Incoming data: {request.data}")

        # Validate and update the data
        serializer = FarmerSerializer(farmer, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Profile updated successfully'}, status=status.HTTP_200_OK)
        else:
            print(f"Validation errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, farmer_id=None, email=None):
        try:
            # Fetch farmer by ID or email
            if farmer_id:
                farmer = Farmer.objects.get(id=farmer_id)
            elif email:
                farmer = Farmer.objects.get(email=email)
            else:
                return Response(
                    {"error": "Either farmer_id or email is required."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Serialize farmer data
            serializer = FarmerSerializer(farmer)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Farmer.DoesNotExist:
            return Response(
                {"error": "Farmer not found."},
                status=status.HTTP_404_NOT_FOUND
            )
class BuyerProfileView(APIView):
    def put(self, request, user_id, format=None):
        try:
            buyer = Buyer.objects.get(id=user_id)
        except Farmer.DoesNotExist:
            return Response({'message': 'Buyer not found'}, status=status.HTTP_404_NOT_FOUND)

        # Log incoming request data
        print(f"Incoming data: {request.data}")

        # Validate and update the data
        serializer = BuyerSerializer(buyer, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Profile updated successfully'}, status=status.HTTP_200_OK)
        else:
            print(f"Validation errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, user_id=None, email=None):
        try:
            # Fetch farmer by ID or email
            if user_id:
                buyer = Buyer.objects.get(id=user_id)
            elif email:
                buyer = Buyer.objects.get(email=email)
            else:
                return Response(
                    {"error": "Either user_id or email is required."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Serialize farmer data
            serializer = BuyerSerializer(buyer)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Farmer.DoesNotExist:
            return Response(
                {"error": "Buyer not found."},
                status=status.HTTP_404_NOT_FOUND
            )
class FarmerRegistrationView(APIView):
    def post(self, request):
        serializer = FarmerSerializer(data=request.data)
        if serializer.is_valid():
            decision_message = "Congratulations! Your account has been created (as Farmer)."
            send_mail(
                subject="Account Decision Notification",
                message=f"Dear {serializer.validated_data['name']},\n\n{decision_message}\n\nThank you.",
                from_email="ibrabekturgan@gmail.com",  # Replace with your email
                recipient_list=[serializer.validated_data['email']],
                fail_silently=False,
            )
            serializer.save(account_status='pending')  # Default status
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Buyer Registration
class BuyerRegistrationView(APIView):
    def post(self, request):
        serializer = BuyerSerializer(data=request.data)
        if serializer.is_valid():
            decision_message = "Congratulations! Your account has been created (as Buyer)."
            send_mail(
                subject="Account Decision Notification",
                message=f"Dear {serializer.validated_data['name']},\n\n{decision_message}\n\nThank you.",
                from_email="ibrabekturgan@gmail.com",
                recipient_list=[serializer.validated_data['email']],
                fail_silently=False,
            )
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class AddProductView(APIView):
    def post(self, request):
        serializer = ProductSerializer(data=request.data)
        if serializer.is_valid():
            product = serializer.save()
            return Response({"message": "Product added successfully", "id": product.id}, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class FarmerProductList(APIView):
    def get(self, request, farmer_id):
        try:
            # Fetch the products for the farmer
            products = Product.objects.filter(farmer_id=farmer_id)
            if products.exists():
                products_data = [{'id': product.id, 'name': product.name, 'description': product.description,
                                  'price': product.price, 'quantity': product.quantity, 'category': product.category} for product in products]
                return Response(products_data, status=status.HTTP_200_OK)
            else:
                return Response({"error": "No products found for this farmer."}, status=status.HTTP_404_NOT_FOUND)
        except Product.DoesNotExist:
            return Response({"error": "No products found for this farmer."}, status=status.HTTP_404_NOT_FOUND)

class ProductListView(APIView):
    def get(self, request):
        # products = Product.objects.all().values()
        # return Response({"success": True, "products": list(products)}, status=status.HTTP_200_OK)
        products = Product.objects.all()
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

# Login
class LoginView(APIView):
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        try:
            farmer = Farmer.objects.get(email=email)
            if check_password(password, farmer.password):
                return Response({
                    "id": farmer.id,
                    "role": "farmer",
                    "account_status": farmer.account_status  # Add account status here
                }, status=status.HTTP_200_OK)
        except Farmer.DoesNotExist:
            pass
        try:
            buyer = Buyer.objects.get(email=email)
            if check_password(password, buyer.password):
                return Response({"id": buyer.id, "role": "buyer"}, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            pass

        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)



def admin_dashboard(request):
    if 'admin_id' not in request.session:
        return redirect('admin_login')

    farmers = Farmer.objects.all()
    buyers = Buyer.objects.all()

    if request.method == "POST":
        farmer_id = request.POST.get("farmer_id")
        action = request.POST.get("action")

        # Fetch the Farmer object
        farmer = get_object_or_404(Farmer, id=farmer_id)

        # Determine the action and update account status
        if action == "approve":
            farmer.account_status = "approved"
            decision_message = "Congratulations! Your account has been approved."
        elif action == "reject":
            farmer.account_status = "rejected"
            decision_message = "We regret to inform you that your account has been rejected."

        farmer.save()

        # Send email to the farmer
        send_mail(
            subject="Account Decision Notification",
            message=f"Dear {farmer.name},\n\n{decision_message}\n\nThank you.",
            from_email="ibrabekturgan@gmail.com",  # Replace with your email
            recipient_list=[farmer.email],
            fail_silently=False,
        )

        # Redirect to avoid re-submission on refresh
        return redirect("admin_dashboard")

    return render(request, "core/admin_dashboard.html", {
        "farmers": farmers,
        "buyers": buyers,
    })


def admin_login(request):
    if request.method == "POST":
        email = request.POST.get("email")
        password = request.POST.get("password")
        # Validate credentials
        try:
            admin = Admin.objects.get(email=email)
            if password == admin.password:
                request.session['admin_id'] = admin.id
                return redirect('admin_dashboard')
            else:
                return render(request, 'core/admin_login.html', {'error': 'Invalid password'})
        except Admin.DoesNotExist:
            return render(request, 'core/admin_login.html', {'error': 'Admin not found'})

    return render(request, 'core/admin_login.html')


def admin_logout(request):
    request.session.flush()
    return redirect('admin_login')

class UpdateProductView(APIView):
    def put(self, request, product_id):
        try:
            product = Product.objects.get(id=product_id)
            serializer = ProductSerializer(product, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Product.DoesNotExist:
            return Response({"error": "Product not found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
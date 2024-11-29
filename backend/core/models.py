from django.utils.timezone import now
from django.db import models
from django.contrib.auth.models import User
import pytz

ASTANA_TZ = pytz.timezone("Asia/Almaty")


class Admin(models.Model):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  # Store hashed passwords in production!

    def __str__(self):
        return self.email


class Farmer(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  # Store hashed passwords for security
    farm_name = models.CharField(max_length=100)
    farm_location = models.CharField(max_length=255)
    account_status = models.CharField(
        max_length=20,
        choices=[('pending', 'Pending'), ('approved', 'Approved'), ('rejected', 'Rejected')],
        default='pending'
    )

    def __str__(self):
        return self.name


class Buyer(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  # Store hashed passwords for security

    def __str__(self):
        return self.name


class Product(models.Model):
    CATEORY_CHOICES = [
        ("fruits", "Fruits"),
        ("vegetables", "Vegetables"),
        ("grains_and_cereals", "Grains and Cereals"),
        ("dairy_products", "Dairy Products"),
        ("meat_and_poultry", "Meat and Poultry"),
        ("seafood", "Seafood"),
        ("eggs", "Eggs"),
        ("nuts_and_seeds", "Nuts and Seeds"),
        ("organic_products", "Organic Products"),
    ]

    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField()
    category = models.CharField(max_length=100, choices=CATEORY_CHOICES, default="organic_products")
    farmer = models.ForeignKey(
        Farmer,
        on_delete=models.CASCADE,
        related_name="products"
    )

    def __str__(self):
        return self.name


def out_of_stock(instance):
    return f"{instance.name} out of stock"


def deleted_user():
    return "Deleted User"


def deleted_product():
    return "Deleted Product"


def farmer_not_available():
    return "Farmer no longer available"


def astana_now():
    return now().astimezone(ASTANA_TZ)


class Order(models.Model):
    STATUS_CHOICES = [
        ("awaiting", "Awaiting"),
        ("accepted", "Accepted"),
        ("delivery", "Delivery"),
        ("completed", "Completed"),
    ]

    buyer = models.ForeignKey(Buyer, on_delete=models.SET(deleted_user))
    order_date = models.DateTimeField(default=astana_now)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="awaiting")

    def __str__(self):
        return f"Order {self.id} by {self.buyer.name} ({self.status})"


class OrderProduct(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.SET(deleted_product))
    farmer = models.ForeignKey(Farmer, on_delete=models.SET(deleted_user), null=True)
    quantity = models.IntegerField()

    def __str__(self):
        return f"Order {self.order.id} - {self.product.name} x {self.quantity}"


class Cart(models.Model):
    product = models.ForeignKey(Product, on_delete=models.SET(out_of_stock))
    buyer = models.ForeignKey(Buyer, on_delete=models.SET(deleted_user))
    amount = models.IntegerField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Cart {self.id}: {self.amount} x {self.product.name if self.product else 'Product Unavailable'}"
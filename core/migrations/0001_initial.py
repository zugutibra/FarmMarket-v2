# Generated by Django 5.1.2 on 2024-11-27 08:05

import core.models
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Admin',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('password', models.CharField(max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Buyer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('password', models.CharField(max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Farmer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('password', models.CharField(max_length=255)),
                ('farm_name', models.CharField(max_length=100)),
                ('farm_location', models.CharField(max_length=255)),
                ('account_status', models.CharField(choices=[('pending', 'Pending'), ('approved', 'Approved'), ('rejected', 'Rejected')], default='pending', max_length=20)),
            ],
        ),
        migrations.CreateModel(
            name='Product',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=255)),
                ('description', models.TextField()),
                ('price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('quantity', models.PositiveIntegerField()),
                ('category', models.CharField(choices=[('fruits', 'Fruits'), ('vegetables', 'Vegetables'), ('grains_and_cereals', 'Grains and Cereals'), ('dairy_products', 'Dairy Products'), ('meat_and_poultry', 'Meat and Poultry'), ('seafood', 'Seafood'), ('eggs', 'Eggs'), ('nuts_and_seeds', 'Nuts and Seeds'), ('organic_products', 'Organic Products')], default='organic_products', max_length=100)),
                ('farmer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='products', to='core.farmer')),
            ],
        ),
        migrations.CreateModel(
            name='Order',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('order_date', models.DateTimeField(default=core.models.astana_now)),
                ('amount', models.IntegerField()),
                ('total_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('status', models.CharField(choices=[('awaiting', 'Awaiting'), ('delivery', 'Delivery'), ('delivered', 'Delivered')], default='awaiting', max_length=20)),
                ('buyer', models.ForeignKey(on_delete=models.SET(core.models.deleted_user), to='core.buyer')),
                ('farmer', models.ForeignKey(on_delete=models.SET(core.models.farmer_not_available), to='core.farmer')),
                ('product', models.ForeignKey(on_delete=models.SET(core.models.out_of_stock), to='core.product')),
            ],
        ),
        migrations.CreateModel(
            name='Cart',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('amount', models.IntegerField()),
                ('total_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('buyer', models.ForeignKey(on_delete=models.SET('deleted user'), to='core.buyer')),
                ('farmer', models.ForeignKey(on_delete=models.SET('farmer no longer available'), to='core.farmer')),
                ('product', models.ForeignKey(on_delete=models.SET(core.models.out_of_stock), to='core.product')),
            ],
        ),
    ]
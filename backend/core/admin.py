from django.contrib import admin
from .models import *

admin.site.register(Farmer)
admin.site.register(Buyer)
admin.site.register(Order)
admin.site.register(Cart)
admin.site.register(Product)
admin.site.register(Admin)
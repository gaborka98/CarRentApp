from django.contrib import admin
from .models import Rent, Category, Vehicle, Photo


# Register your models here.
class InlinePhoto(admin.TabularInline):
    model = Photo
    extra = 1


class VehicleAdmin(admin.ModelAdmin):
    inlines = [InlinePhoto]


admin.site.register(Vehicle, VehicleAdmin)
admin.site.register(Rent)
admin.site.register(Category)

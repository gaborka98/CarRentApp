import datetime
from django.db import models
from django.db.models import ForeignKey

from accounts.models import CustomUser


# Create your models here.

class Category(models.Model):
    name = models.CharField(max_length=30, null=False, blank=False)


class Vehicle(models.Model):
    build_year = models.IntegerField(choices=[(year, year) for year in range(1980, (datetime.datetime.now().year + 1))],
                                     null=False, blank=False)
    color = models.CharField(max_length=30, null=False, blank=False)
    make = models.CharField(max_length=30, null=False, blank=False)
    model = models.CharField(max_length=30, null=False, blank=False)
    rentable = models.BooleanField(default=False)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    caution = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, null=False, blank=False)


class Rent(models.Model):
    from_date = models.DateField()
    to_date = models.DateField()
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=False, blank=False)


class Photo(models.Model):
    car = ForeignKey(Vehicle, on_delete=models.CASCADE, null=False, blank=False)
    image = models.ImageField()

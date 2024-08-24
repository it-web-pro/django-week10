# Week 10 Tutorial

## Instructions

1. สร้าง venv แล้ว ติดตั้ง `pip install django psycopg2`
2. สร้าง project "week10_tutorial"
3. สร้าง app "bookings"
4. เพิ่ม code นี้ไปใน `models.py`

```python
from django.db import models

class Staff(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    position = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class RoomType(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name


class Room(models.Model):
    number = models.CharField(max_length=10, unique=True)
    name = models.CharField(max_length=100)
    capacity = models.IntegerField()
    description = models.TextField(blank=True)
    room_types = models.ManyToManyField(RoomType, related_name='rooms', blank=True)

    def __str__(self):
        return f'Room {self.number}: {self.name}'


class Booking(models.Model):
    room = models.ForeignKey(Room, on_delete=models.PROTECT)
    staff = models.ForeignKey(Staff, on_delete=models.PROTECT)
    email = models.EmailField(null=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    purpose = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return f'Booking for {self.room} from {self.start_time} to {self.end_time}'
```

5. แก้ไข `settings.py` และทำการ makemigrations + migrate
6. import `bookings.sql`

## Let's start

ก่อนอื่นเรามาเพิ่ม path ใน `urls.py` และ เขียน view สำหรับทำการ book ห้อง

```python
# week10_tutorial/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("bookings/", include("bookings.urls")),
]
```

```python
# bookings/urls.py
from django.urls import path

from bookings import views

urlpatterns = [
    path("", views.BookingList.as_view(), name="booking-list"),
    path("create/", views.BookingCreate.as_view(), name="booking-create"),
    path("<int:booking_id>", views.BookingDelete.as_view(), name="booking-delete"),
]
```

และเพิ่ม code ใน `views.py`

```python
from datetime import datetime, timedelta
from django.shortcuts import render, redirect
from django.views import View
from django.utils import timezone
from django.db.models import Q

from bookings.models import Room, Staff, Booking

class BookingList(View):

    def get(self, request):
        query = request.GET

        bookings = Booking.objects.filter(start_time__gt=timezone.localtime()).order_by("start_time")

        if query.get("search"):
            bookings = bookings.filter(
                Q(room__name__icontains=query.get("search")) | 
                Q(staff__name__icontains=query.get("search"))
            )

        return render(request, "booking-list.html", {
            "bookings": bookings
        })


class BookingCreate(View):

    def get(self, request):
        rooms = Room.objects.all()
        staffs = Staff.objects.all()
        
        return render(request, "booking.html", {
            "rooms": rooms,
            "staffs": staffs
        })

    def post(self, request):
        error = ""
        data = request.POST
        start_time_str = f'{data["start_date"]} {data["start_time"]}'
        end_time_str = f'{data["end_date"]} {data["end_time"]}'
        start_time = timezone.make_aware(datetime.strptime(start_time_str, "%Y-%m-%d %H:%M"))
        end_time = timezone.make_aware(datetime.strptime(end_time_str, "%Y-%m-%d %H:%M"))
        
        duration = end_time - start_time
        bookings = Booking.objects.filter(start_time__lte=end_time, end_time__gte=start_time, room_id=data["room"])
        
        if end_time < start_time:
            error = "End time cannot be before start time"
        
        elif bookings.count() > 0:
            error = "This room has already been booked for the selected time"

        if not error:
            Booking.objects.create(
                staff_id=data["staff"],
                room_id=data["room"],
                start_time=start_time,
                end_time=end_time,
                purpose=data["purpose"]
            )
            return redirect('booking-list')
        else:
            rooms = Room.objects.all()
            staffs = Staff.objects.all()
            return render(request, "booking.html", {
            "rooms": rooms,
            "staffs": staffs,
            "error": error
        })

class BookingDelete(View):

    def get(self, request, booking_id):
        booking = Booking.objects.get(pk=booking_id)
        booking.delete()

        return redirect("booking-list")
```

และ สร้าง folder `bookings/templates` และ สร้างไฟล์ `booking.html`

```html
<!-- booking.html -->
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Booking</title>
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css"
        >
</head>
<body>
    <section class="section">
        <h1 class="title" id="title">Add New Booking</h1>
    </section>
    <div class="container pl-5">
        {% if error %}
            <div class="notification is-danger">{{error}}</div>
        {% endif %}
        <form action="{% url 'booking-create' %}" method="POST">
            {% csrf_token %}
            <div class="field">
                <label class="label">Room to book</label>
                <div class="control">
                    <div class="select">
                    <select name="room">
                        {% for room in rooms %}
                            <option value="{{room.id}}">{{room.name}}</option>
                        {% endfor %}
                    </select>
                    </div>
                </div>
                </div>

            <div class="field">
            <label class="label">Booked for</label>
            <div class="control">
                <div class="select">
                <select name="staff">
                    {% for staff in staffs %}
                        <option value="{{staff.id}}">{{staff.name}}</option>
                    {% endfor %}
                </select>
                </div>
            </div>
            </div>
            
            <div class="field">
                <label class="label">Purpose</label>
                <div class="control">
                    <textarea class="textarea" id="purpose" name="purpose" placeholder="Purpose"></textarea>
                </div>
            </div>
            <div class="field">
                <label class="label">Start time</label>
                <div class="control">
                    <div class="columns">
                        <div class="column">
                            <input type="date" id="start_date" name="start_date" class="input">
                        </div>
                        <div class="column">
                            <input type="time" id="start_time" name="start_time" class="input">
                        </div>
                        <div class="column"></div>
                      </div>
                </div>
            </div>
            <div class="field">
                <label class="label">End time</label>
                <div class="control">
                    <div class="columns">
                        <div class="column">
                            <input type="date" id="end_date" name="end_date" class="input">
                        </div>
                        <div class="column">
                            <input type="time" id="end_time" name="end_time" class="input">
                        </div>
                        <div class="column"></div>
                      </div>
                </div>
            </div>
            <div class="field is-grouped">
                <div class="control">
                    <input type="submit" class="button is-link">
                </div>
                <div class="control">
                    <a class="button is-danger" href="{% url 'booking-list' %}">Back</a>
                </div>
            </div>
        </form>
    </div>
</body>
</html>
```

และไฟล์ `booking-list.html`

```html
<!-- booking-list.html -->
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking List</title>
    <link
    rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css"
    >
</head>
<body>
    <section class="section">
        <h1 class="title" id="title">Booking List</h1>
    </section>
    <div class="container">
        <form action="{% url 'booking-list' %}">
            <div class="field">
                <label class="label">Name</label>
                <div class="control">
                    <div class="columns">
                        <div class="column">
                            <input class="input" type="text" name="search" placeholder="Search room name / staff name">
                        </div>
                        <div class="column">
                            <input class="button" type="submit" value="Search">
                            <a class="button is-success" href="{% url 'booking-create' %}">Add New Booking</a>
                        </div>
                    </div>
                </div>
              </div>
        </form>
        <br/>
        <table class="table" id="datatable">
            <thead>
                <tr>
                    <th>Room</th>
                    <th>Staff</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Purpose</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                {% for booking in bookings%}
                <tr>
                    <td>{{booking.room.name}}</td>
                    <td>{{booking.staff.name}}</td>
                    <td>{{booking.start_time|date}}</td>
                    <td>{{booking.start_time|time:"H:i"}} - {{booking.end_time|time:"H:i"}}</td>
                    <td>{{booking.purpose}}</td>
                    <td><a class="button is-warning" href="{% url 'booking-delete' booking.id %}">Cancel Room</a></td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</body>
</html>
```

จากนั้นทดสอบดูว่าใช้งานได้ไหม โดยสั่ง `python manage.py runserver`

## Let's use ModelForm

เราจะทำการสร้าง ModelForm สำหรับ model `Booking` เริ่มด้วยการสร้างไฟล์ `bookings/forms.py` และเพิ่ม code ด้านล่าง

```python
from django.forms import ModelForm, SplitDateTimeField
from django.forms.widgets import Textarea, TextInput, SplitDateTimeWidget
from django.core.exceptions import ValidationError

from bookings.models import Booking

class BookingForm(ModelForm):
    start_time = SplitDateTimeField(widget=SplitDateTimeWidget(
                date_attrs={"class": "input", "type": "date"},
                time_attrs={"class": "input", "type": "time"}
            ))
    end_time = SplitDateTimeField(widget=SplitDateTimeWidget(
                date_attrs={"class": "input", "type": "date"},
                time_attrs={"class": "input", "type": "time"}
            ))

    class Meta:
        model = Booking
        fields = [
            "room", 
            "staff", 
            "email", 
            "start_time", 
            "end_time", 
            "purpose"
        ]
        widgets = {
            "email": TextInput(attrs={"class": "input"}),
            "purpose": Textarea(attrs={"rows": 5, "class": "textarea"})
        }
    
    def clean(self):
        cleaned_data = super().clean()
        room = cleaned_data.get("room")
        start_time = cleaned_data.get("start_time")
        end_time = cleaned_data.get("end_time")

        if start_time and end_time and end_time < start_time:
            raise ValidationError(
                    "End time cannot be before start time"
                )
        bookings = Booking.objects.filter(
            start_time__lte=end_time, 
            end_time__gte=start_time, 
            room=room
        )
        if bookings.count() > 0:
            raise ValidationError(
                    "This room has already been booked for the selected time"
                )

        return cleaned_data
```

จากนั้นทำการเรียกใช้ใน `views.py`

```python
...

from bookings.models import Booking
from bookings.forms import BookingForm

...

class BookingCreate(View):

    def get(self, request):
        form = BookingForm()
        return render(request, "booking.html", {
            "form": form,
        })

    def post(self, request):
        form = BookingForm(request.POST)

        if form.is_valid():
            form.save()
            return redirect('booking-list')

        return render(request, "booking.html", {
            "form": form
        })
...
```

จะเห็นได้ว่า code ใน view นั้นสั้นลงไปเยอะมากๆ เราทำการย้าย validation logic และการ save() ไปไว้ใน form หมดแล้ว

แก้ไข `templates/booking.html` ดังนี้

```html
<!-- booking.html -->
{% load static %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Booking</title>
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css"
        >
</head>
<body>
    <section class="section">
        <h1 class="title" id="title">Add New Booking</h1>
    </section>
    <div class="container pl-5">
        {{ form.non_field_errors }}
        <form action="{% url 'booking-create' %}" method="POST">
            {% csrf_token %}
            <div class="field">
                {{ form.room.errors }}
                <label class="label" for="{{ form.room.id_for_label }}">Room to book</label>
                <div class="control">
                    <div class="select">
                        {{ form.room }}
                    </div>
                </div>
                </div>

            <div class="field">
                {{ form.staff.errors }}
                <label class="label" for="{{ form.staff.id_for_label }}">Booked for</label>
                <div class="control">
                    <div class="select">
                        {{form.staff}}
                    </div>
                </div>
            </div>
            <div class="field">
                {{ form.email.errors }}
                <label class="label" for="{{ form.email.id_for_label }}">Email</label>
                <div class="control">
                    {{form.email}}
                </div>
            </div>
            <div class="field">
                {{ form.purpose.errors }}
                <label class="label" for="{{ form.purpose.id_for_label }}">Purpose</label>
                <div class="control">
                    {{form.purpose}}
                </div>
            </div>
            <div class="field">
                {{ form.start_time.errors }}
                <label class="label" for="{{ form.start_time.id_for_label }}">Start time</label>
                <div class="control">
                    <div class="columns">
                        <div class="column">
                            {{ form.start_time }}
                        </div>
                        <div class="column"></div>
                      </div>
                </div>
            </div>
            <div class="field">
                {{ form.end_time.errors }}
                <label class="label" for="{{ form.end_time.id_for_label }}">End time</label>
                <div class="control">
                    <div class="columns">
                        <div class="column">
                            {{ form.end_time }}
                        </div>
                        <div class="column"></div>
                        <div class="column"></div>
                      </div>
                </div>
            </div>
            <div class="field is-grouped">
                <div class="control">
                    <input type="submit" class="button is-link">
                </div>
                <div class="control">
                    <a class="button is-danger" href="{% url 'booking-list' %}">Back</a>
                </div>
            </div>
        </form>
    </div>
</body>
</html>
```

ทดลองทำการ booking ดูได้เลยครับ!
# Creating forms from models

## ModelForm

โดยปกติ form ที่เราต้องการมักจะมี field เหมือนๆ กับใน Django model ยกตัวอย่างเช่น

```python
# models.py
from django.db import models

class Article(models.Model):
    headline = models.CharField(max_length=30)
    content = models.TextField()
    pub_date = models.DateTimeField()

# ----------------------
# forms.py
from django.forms import ModelForm
from myapp.models import Article
class ArticleForm(ModelForm):
    class Meta:
        model = Article
        fields = ["pub_date", "headline", "content"]
```

### Field types

| **Model field**               | **Form field**                                                                                                      |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------|
| **AutoField**                 | Not represented in the form                                                                                         |
| **BigAutoField**              | Not represented in the form                                                                                         |
| **BigIntegerField**           | IntegerField with<br>min_value set to -9223372036854775808<br>and max_value set to 9223372036854775807.             |
| **BinaryField**               | CharField, if<br>editable is set to<br>True on the model field, otherwise not<br>represented in the form.           |
| **BooleanField**              | BooleanField, or<br>NullBooleanField if<br>null=True.                                                               |
| **CharField**                 | CharField with<br>max_length set to the model field’s<br>max_length and<br>empty_value<br>set to None if null=True. |
| **DateField**                 | DateField                                                                                                           |
| **DateTimeField**             | DateTimeField                                                                                                       |
| **DecimalField**              | DecimalField                                                                                                        |
| **DurationField**             | DurationField                                                                                                       |
| **EmailField**                | EmailField                                                                                                          |
| **FileField**                 | FileField                                                                                                           |
| **FilePathField**             | FilePathField                                                                                                       |
| **FloatField**                | FloatField                                                                                                          |
| **ForeignKey**                | ModelChoiceField<br>(see below)                                                                                     |
| **ImageField**                | ImageField                                                                                                          |
| **IntegerField**              | IntegerField                                                                                                        |
| **IPAddressField**            | IPAddressField                                                                                                      |
| **GenericIPAddressField**     | GenericIPAddressField                                                                                               |
| **JSONField**                 | JSONField                                                                                                           |
| **ManyToManyField**           | ModelMultipleChoiceField<br>(see below)                                                                             |
| **PositiveBigIntegerField**   | IntegerField                                                                                                        |
| **PositiveIntegerField**      | IntegerField                                                                                                        |
| **PositiveSmallIntegerField** | IntegerField                                                                                                        |
| **SlugField**                 | SlugField                                                                                                           |
| **SmallAutoField**            | Not represented in the form                                                                                         |
| **SmallIntegerField**         | IntegerField                                                                                                        |
| **TextField**                 | CharField with<br>widget=forms.Textarea                                                                             |
| **TimeField**                 | TimeField                                                                                                           |
| **URLField**                  | URLField                                                                                                            |
| **UUIDField**                 | UUIDField                                                                                                           |

**Important: สำหรับ ForeignKey and ManyToManyField ใน model จะเป็นกรณีพิเศษ**

- `ForeignKey` จะถูกแปลงเป็น `django.forms.ModelChoiceField` ซึ่งคือ `ChoiceField` ที่มีตัวเลือกเป็น queryset ของ model
- `ManyToManyField` จะถูกแปลงเป็น `django.forms.ModelMultipleChoiceField` ซึ่งคือ `MultipleChoiceField` ที่มีตัวเลือกเป็น queryset ของ model

นอกจากนั้นการกำหนด attribute เหล่านี้ใน model จะส่งผลถึง ModelForm ด้วย

- ถ้ากำหนด `blank=True` ใน model จะหมายถึง `required=False` ใน form
- `label` ของ form จะดึงมาจาก attribute `verbose` ใน field ของ model
- `help_text` ของ form จะดึงมาจาก attribute `help_text` ใน field ของ model
- ถ้าใน model มีการกำหนด attribute `choices` ตัว widget ของ field นั้นใน form จะเป็น `Select` พร้อมกับตัวเลือกจะถูกดึงมาจาก `choices` ที่กำหนดใน model

## Why using ModelForm

1. ทำให้การประกาศฟอร์มง่ายขึ้น เช่น

### Using ModelForm

```python
from django.db import models
from django.forms import ModelForm

TITLE_CHOICES = {
    "MR": "Mr.",
    "MRS": "Mrs.",
    "MS": "Ms.",
}


class Author(models.Model):
    name = models.CharField(max_length=100)
    title = models.CharField(max_length=3, choices=TITLE_CHOICES)
    birth_date = models.DateField(blank=True, null=True)

    def __str__(self):
        return self.name


class Book(models.Model):
    name = models.CharField(max_length=100)
    authors = models.ManyToManyField(Author)


class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ["name", "title", "birth_date"]


class BookForm(ModelForm):
    class Meta:
        model = Book
        fields = ["name", "authors"]
```

### Using normal Form

```python
from django import forms


class AuthorForm(forms.Form):
    name = forms.CharField(max_length=100)
    title = forms.CharField(
        max_length=3,
        widget=forms.Select(choices=TITLE_CHOICES),
    )
    birth_date = forms.DateField(required=False)


class BookForm(forms.Form):
    name = forms.CharField(max_length=100)
    authors = forms.ModelMultipleChoiceField(queryset=Author.objects.all())
```

2. สามารถใช้งาน save() method ได้ ซึ่งจะทำให้ code นั้นสั้นลงมากๆ ดังที่จะอธิบายต่อไป

## The `save()` method

เนื่องจากทุก model จะมี method `save()` ดังนั้นเราก็สามารถเรียก `save()` จาก instance ของ ModelForm ได้ ดังตัวอย่าง

```python
>>> from myapp.models import Article
>>> from myapp.forms import ArticleForm

# Create a form instance from POST data.
>>> f = ArticleForm(request.POST)

# Save a new Article object from the form's data.
>>> new_article = f.save()

# Create a form to edit an existing Article, but use
# POST data to populate the form.
>>> a = Article.objects.get(pk=1)
>>> f = ArticleForm(request.POST, instance=a)
>>> f.save()
```

## Overriding the default fields

เราสามารถ overwrite ค่า attribute ที่ถูกกำหนดใน field ของ model ได้เช่น อยากจะเป็น widget ของ CharField ไปใช้เป็น Textarea เป็นต้น

```python
class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ["name", "title", "birth_date"]
        widgets = {
            "name": Textarea(attrs={"cols": 80, "rows": 20}),
        }

# หรือ overwrite ค่า attriute อื่นๆ 
from django.utils.translation import gettext_lazy as _


class AuthorForm(ModelForm):
    class Meta:
        model = Author
        fields = ["name", "title", "birth_date"]
        labels = {
            "name": _("Writer"),
        }
        help_texts = {
            "name": _("Some useful help text."),
        }
        error_messages = {
            "name": {
                "max_length": _("This writer's name is too long."),
            },
        }

# หรือ
from django.forms import CharField, ModelForm
from myapp.models import Article


class ArticleForm(ModelForm):
    slug = CharField(validators=[validate_slug])

    class Meta:
        model = Article
        fields = ["pub_date", "headline", "content", "reporter", "slug"]
```
# Working with Forms (Part 2)

# The Forms API

## Bound and unbound forms

instance ของ form จะอยู่ในสถานะใดสถานะหนึ่ง bound หรือ unbound

- ถ้ามีการ bind ข้อมูลเข้าไปใน instance ของ form จะเรียกว่า bound form และเราจะสามารถ validate ข้อมูลใน form ได้โดยการเรียก `is_valid()`
- สำหรับ form ที่มีลักษณะ unbound คือเป็นฟอร์มเปล่าที่ไม่มีข้อมูล ไม่สามารถ validate ได้ และจะ render เป็นฟอร์มเปล่าใน template

การสร้าง unbound form ทำได้ดังนี้

```python
f = ContactForm() # unbound form
```

ส่วนการ bind ข้อมูลกับ form สามารถทำได้ดังนี้

```python
data = {
    "subject": "hello", 
    "message": "Hi there", 
    "sender": "foo@example.com", 
    "cc_myself": True,
}

f = ContactForm(data) # bound form
```

**สำคัญ: key ใน dict `data` จะต้องตรงกับชื่อ field ใน ContactForm**

## Using forms to validate data

หนึ่งในหน้าที่หลักของ form คือการ validate data ที่ถูก submit เข้ามา โดยเราสามารถทำการ validate ได้โดยการเรียก `is_valid()` กับ instance ของ form ที่ถูก bound แล้ว

```python
data = {
    "subject": "hello",
    "message": "Hi there",
    "sender": "foo@example.com",
    "cc_myself": True,
}
f = ContactForm(data)
f.is_valid() # True
```

โดย `is_valid()` จะ return ค่า True ในกรณีที่ข้อมูลถูก validate ผ่านโดยไม่มี error และจะ return ค่า False ในกรณีที่ validate ไม่ผ่าน

```python
data = {
    "subject": "",
    "message": "Hi there",
    "sender": "invalid email address",
    "cc_myself": True,
}
f = ContactForm(data)
f.is_valid() # False
```

และในกรณีที่ `is_valid()` = False form จะให้ errors ออกมาด้วย

```python
>>> f.errors
{'sender': ['Enter a valid email address.'], 'subject': ['This field is required.']}

>>> f.errors.as_json()
{"sender": [{"message": "Enter a valid email address.", "code": "invalid"}],
"subject": [{"message": "This field is required.", "code": "required"}]}
```

## Initial form values

เราสามารถใส่ค่าตั้งต้นของแต่ละ field ใน form ได้โดยใช้ argument initial

```python
f = ContactForm(initial={"subject": "Hi there!"})
```

ในกรณีที่ประกาศ initial ทั้งในระดับ form field และ ระดับ instance ระดับ instance จะถูกนำไปใช้

```python
from django import forms
class CommentForm(forms.Form):
    name = forms.CharField(initial="class")
    url = forms.URLField()
    comment = forms.CharField()

f = CommentForm(initial={"name": "instance"}, auto_id=False)
print(f)

<div>Name:<input type="text" name="name" value="instance" required></div>
<div>Url:<input type="url" name="url" required></div>
<div>Comment:<input type="text" name="comment" required></div>
```

## Accessing “clean” data

นอกจาก form จะทำการ validate ข้อมูลแล้ว ยังทำการ clean ข้อมูลให้ด้วย 

> "cleaning" - normalizing the data to a consistent format

ยกตัวอย่างเช่น `DateField` จะทำการ clean ข้อมูล input ที่เป็น string เช่น "2024-08-01" ให้เป็น `datetime.date` ของ Python 

โดยข้อมูลที่ถูก clean แล้วเมื่อเราเรียก `is_valid()` จะอยู่ในตัวแปร `form.cleaned_data`

```python
data = {
    "subject": "hello",
    "message": "Hi there",
    "sender": "foo@example.com",
    "cc_myself": True,
}
f = ContactForm(data)
f.is_valid() # True
print(f.cleaned_data)
{'cc_myself': True, 'message': 'Hi there', 'sender': 'foo@example.com', 'subject': 'hello'}
```

### How errors are displayed

ถ้าเราทำการ render bound form ใน template

```python
>>> data = {
...     "subject": "",
...     "message": "Hi there",
...     "sender": "invalid email address",
...     "cc_myself": True,
... }
>>> f = ContactForm(data)
>>> print(f)
```

```html
<div>Subject:
  <ul class="errorlist"><li>This field is required.</li></ul>
  <input type="text" name="subject" maxlength="100" required aria-invalid="true">
</div>
<div>Message:
  <textarea name="message" cols="40" rows="10" required>Hi there</textarea>
</div>
<div>Sender:
  <ul class="errorlist"><li>Enter a valid email address.</li></ul>
  <input type="email" name="sender" value="invalid email address" required aria-invalid="true">
</div>
<div>Cc myself:
  <input type="checkbox" name="cc_myself" checked>
</div>
```

# Form and field validation

เราสามารถ customize การทำ validation ของ form ได้หลากหลายวิธีดังนี้

## Using validators

เราสามารถใช้ built-in validator ที่ทาง Django มีให้ในการ validate ค่าใน form field เช่น

```python
slug = forms.CharField(validators=[validators.validate_slug])
```

List ของ built-in validators และ การเขียน custom validator เองสามารถดูได้ที่ [Doc](https://docs.djangoproject.com/en/5.1/ref/validators/)

## Cleaning a specific field attribute

สมมติเราต้องการ validate ค่าใน sender ว่าจะต้องเป็น "bundit@it.kmitl.ac.th"

```python
class ContactForm(forms.Form):
    subject = forms.CharField(max_length=100)
    message = forms.CharField()
    sender = forms.EmailField()
    cc_myself = forms.BooleanField(required=False)

    def clean_sender(self):
        data = self.cleaned_data["sender"]
        if data != "bundit@it.kmitl.ac.th":
            raise ValidationError("Sender must be Bundit!")

        # Always return a value to use as the new cleaned data, even if
        # this method didn't change it.
        return data
```

## Cleaning and validating fields that depend on each other

ในกรณีที่เราต้องการ validate ข้อมูลโดยดูข้อมูลใน field อื่นด้วย (จากหัวข้อก่อนหน้า `clean_sender()` จะเข้าถึงเพียงแค่ค่าใน field sender) เราจะใช้ method `clean()`

```python
class ContactForm(forms.Form):
    # Everything as before.
    ...

    def clean(self):
        cleaned_data = super().clean()
        cc_myself = cleaned_data.get("cc_myself")
        subject = cleaned_data.get("subject")

        if cc_myself and subject:
            # Only do something if both fields are valid so far.
            if "help" not in subject:
                raise ValidationError(
                    "Did not send for 'help' in the subject despite CC'ing yourself."
                )
        return cleaned_data
```

ในกรณีนี้การแสดง error จะไม่ได้อยู่ที่แต่ละ field จะอยู่ที่ด้านบนสุดของ form ซึ่งจะอยู่ในตัวแปร {{ form.non_field_errors }}

หรือในกรณีที่เราต้องการให้ error ไปแสดงที่ field ที่เกี่ยวข้องสามารถทำได้โดยใช้ `add_error()` ดังนี้

```python
class ContactForm(forms.Form):
    # Everything as before.
    ...

    def clean(self):
        cleaned_data = super().clean()
        cc_myself = cleaned_data.get("cc_myself")
        subject = cleaned_data.get("subject")

        if cc_myself and subject and "help" not in subject:
            msg = "Must put 'help' in subject when cc'ing yourself."
            self.add_error("cc_myself", msg)
            self.add_error("subject", msg)

        return cleaned_data
```

สำหรับการ render error ใน template นั้นสามาถทำได้โดยใช้

- `form.non_field_errors` - สำหรับ error ระดับทั้ง form ที่เกิดจาก method `clean()`
- `form.field.errors` - สำหรับ error ระดับ field ที่เกิดจาก method `clean_fieldname()`

```html
{{ form.non_field_errors }}
<div class="fieldWrapper">
    {{ form.subject.errors }}
    <label for="{{ form.subject.id_for_label }}">Email subject:</label>
    {{ form.subject }}
</div>
<div class="fieldWrapper">
    {{ form.message.errors }}
    <label for="{{ form.message.id_for_label }}">Your message:</label>
    {{ form.message }}
</div>
<div class="fieldWrapper">
    {{ form.sender.errors }}
    <label for="{{ form.sender.id_for_label }}">Your email address:</label>
    {{ form.sender }}
</div>
<div class="fieldWrapper">
    {{ form.cc_myself.errors }}
    <label for="{{ form.cc_myself.id_for_label }}">CC yourself?</label>
    {{ form.cc_myself }}
</div>
```

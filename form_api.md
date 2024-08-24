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

## Outputting forms as HTML

```python
data = {
    "subject": "hello",
    "message": "Hi there",
    "sender": "foo@example.com",
    "cc_myself": True,
}
f = ContactForm(data)
print(f)
```

เราสามารถ render form ใน template ได้หลายรูปแบบ

- `as_div()` (เป็นตัวเลือก default)

```html
<div>
    <label for="id_subject">Subject:</label>
    <input type="text" name="subject" maxlength="100" required id="id_subject">
</div>
<div>
    <label for="id_message">Message:</label>
    <input type="text" name="message" required id="id_message">
</div>
<div>
    <label for="id_sender">Sender:</label>
    <input type="email" name="sender" required id="id_sender">
</div>
<div>
    <label for="id_cc_myself">Cc myself:</label>
    <input type="checkbox" name="cc_myself" id="id_cc_myself">
</div>
```

- `as_p()`

```html
<p>
    <label for="id_subject">Subject:</label> 
    <input id="id_subject" type="text" name="subject" maxlength="100" required>
</p>
<p>
    <label for="id_message">Message:</label> 
    <input type="text" name="message" id="id_message" required>
</p>
<p>
    <label for="id_sender">Sender:</label> 
    <input type="email" name="sender" id="id_sender" required>
</p>
<p>
    <label for="id_cc_myself">Cc myself:</label> 
    <input type="checkbox" name="cc_myself" id="id_cc_myself">
</p>
```

- `as_ul()`

```html
<li>
    <label for="id_subject">Subject:</label> 
    <input id="id_subject" type="text" name="subject" maxlength="100" required>
</li>
<li>
    <label for="id_message">Message:</label> 
    <input type="text" name="message" id="id_message" required>
</li>
<li>
    <label for="id_sender">Sender:</label> 
    <input type="email" name="sender" id="id_sender" required>
</li>
<li>
    <label for="id_cc_myself">Cc myself:</label> 
    <input type="checkbox" name="cc_myself" id="id_cc_myself">
</li>
```

- `as_table()`

```html
<tr>
    <th>
        <label for="id_subject">Subject:</label>
    </th>
    <td>
        <input id="id_subject" type="text" name="subject" maxlength="100" required>
    </td>
</tr>
<tr>
    <th>
        <label for="id_message">Message:</label>
    </th>
    <td>
        <input type="text" name="message" id="id_message" required>
    </td>
</tr>
<tr>
    <th>
        <label for="id_sender">Sender:</label>
    </th>
    <td>
        <input type="email" name="sender" id="id_sender" required>
    </td>
</tr>
<tr>
    <th>
        <label for="id_cc_myself">Cc myself:</label>
    </th>
    <td>
        <input type="checkbox" name="cc_myself" id="id_cc_myself">
    </td>
</tr>
```

**Important: จะเห็นได้ว่าไม่มี tag `<form></form>` และปุ่ม submit `<input type="submit">`**

### How errors are displayed

ถ้าเราทำการ render bound form ใน template

```python
>>> data = {
...     "subject": "",
...     "message": "Hi there",
...     "sender": "invalid email address",
...     "cc_myself": True,
... }
>>> f = ContactForm(data, auto_id=False)
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

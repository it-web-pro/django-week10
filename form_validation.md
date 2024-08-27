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

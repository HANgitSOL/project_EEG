# Introduction to EEG data processing in Python

In this week, we will learn about **decoding** EEG signal in Python together.<br>
<br>
This introduction incorporates _identifying_ condition at each trials, decoding EEG signal using _cross-validation_ and _for-loop_.<br>
Finally, welcome to the decoding world!🎉<br>
<br>
### code files🧑‍💻
**E_Easy_W4.ipynb** : main code file in this week. This file is for decoding EEG signal in Python. There are very short explanations about that step as annotation.<br>
**E_easy_signal_check_WM.m** : code for signal check. This file is for extracting ERP to check signal changes according to stimuli sequence.<br>
**trialfunc.m** : code for signal check. This file is necessary for running **E_easy_signal_check_WM.m** file.
<br>
### slide file🧑‍🏫
There are specific examples about applications of functions and explanation about that function in _.pptx_.<br>
In the explanation about function, some elements are mentioned specifically, i.e. the type of variable, the meaning of variable, etc. .<br>
If you need more explanation about function, check the internet site mentioned in the **note** of that page.<br>

- - -

<br>

## preview of slide

![슬라이드4](https://user-images.githubusercontent.com/120706982/219850397-b0b28414-8040-4e56-8142-3993c9988489.JPG)
![슬라이드5](https://user-images.githubusercontent.com/120706982/219850402-ca9939c0-09b7-4c35-8284-a27e6bcaee2a.JPG)
![슬라이드6](https://user-images.githubusercontent.com/120706982/219850406-39e03514-aa76-4d25-987c-bb409000728d.JPG)
![슬라이드7](https://user-images.githubusercontent.com/120706982/219850409-09ca01d1-27f2-4148-af50-b0caa95cf746.JPG)
![슬라이드12](https://user-images.githubusercontent.com/120706982/219850420-8f50b1b4-7e00-427b-8766-3120a33298bd.JPG)
![슬라이드13](https://user-images.githubusercontent.com/120706982/219850422-7498cd0a-eba4-4ad6-adbe-a12c1786df4e.JPG)
![슬라이드14](https://user-images.githubusercontent.com/120706982/219850435-f9bb1573-66ab-4947-9086-c25c805caf09.JPG)
![슬라이드15](https://user-images.githubusercontent.com/120706982/219850443-7cd21aad-009d-4353-a8eb-2297198811b7.JPG)
![슬라이드16](https://user-images.githubusercontent.com/120706982/219850445-9acb62e9-5dee-4ba0-837f-0d28b5195dcf.JPG)
![슬라이드18](https://user-images.githubusercontent.com/120706982/219850450-fffbbad8-405a-452a-a32d-79721db51d18.JPG)
![슬라이드19](https://user-images.githubusercontent.com/120706982/219850452-31241a88-fd1f-4fd7-8e98-054bf76e6bcd.JPG)
![슬라이드20](https://user-images.githubusercontent.com/120706982/219850453-cbfefa5f-c2e5-476f-b4a3-554efdd2ac8b.JPG)
![슬라이드21](https://user-images.githubusercontent.com/120706982/219850455-96bde7de-43ea-4fcf-94cb-0f05b7acbcba.JPG)
![슬라이드22](https://user-images.githubusercontent.com/120706982/219850457-adff988e-7a72-456e-bb05-f7b61e621aca.JPG)
![슬라이드23](https://user-images.githubusercontent.com/120706982/219850462-63d3e4f3-f410-4fcd-95ff-71f47eef4359.JPG)
![슬라이드24](https://user-images.githubusercontent.com/120706982/219850465-11508a8a-372b-479a-8cef-09b514cd370b.JPG)
![슬라이드25](https://user-images.githubusercontent.com/120706982/219850470-ffd07ccd-08bd-41b2-a336-1a6257e263ce.JPG)
![슬라이드26](https://user-images.githubusercontent.com/120706982/219850472-c4068423-a3b3-41e0-b932-868bfd691c33.JPG)
![슬라이드27](https://user-images.githubusercontent.com/120706982/219850474-c3f2145e-9c5e-44d0-8d00-72cf038c8d18.JPG)
![슬라이드28](https://user-images.githubusercontent.com/120706982/219850477-8f797f35-8b9a-4de9-b7f4-59091426fab9.JPG)
![슬라이드29](https://user-images.githubusercontent.com/120706982/219850479-dc2c28b4-7a2a-4ed7-bcb4-39a3e6510cb7.JPG)
![슬라이드30](https://user-images.githubusercontent.com/120706982/219850481-24768c14-e6d7-456e-9f0e-f1454d30747b.JPG)
![슬라이드31](https://user-images.githubusercontent.com/120706982/219850487-972fd19c-d709-4d0a-afea-4456a067939f.JPG)
![슬라이드32](https://user-images.githubusercontent.com/120706982/219850489-b098c8c8-3dfe-43f5-9c62-8be7baed0133.JPG)
![슬라이드33](https://user-images.githubusercontent.com/120706982/219850491-9eeb1b08-8810-46d2-8466-6d24c2dba0df.JPG)
![슬라이드34](https://user-images.githubusercontent.com/120706982/219850496-0bc6eda3-0e28-4d6d-9d24-600edf3deffc.JPG)
![슬라이드35](https://user-images.githubusercontent.com/120706982/219850498-25d088d4-894b-4a56-9be9-52e7c475e37a.JPG)
![슬라이드36](https://user-images.githubusercontent.com/120706982/219850500-9bac0411-a658-4aed-9102-b5744a71890c.JPG)
![슬라이드37](https://user-images.githubusercontent.com/120706982/219850504-866fe4b7-ff6f-449f-aa3c-41388b0b82b9.JPG)
<br>
I did not succeed in reducing the size of a picture.. Sorry for your scrolling down..

# OCR-Switft
Scaning Kazakhstan citizen's ID cards and getting full `Data` by using your phone camera
### Data
- First Name / Middle Name / Last Name
- Date of birthday
- Document given by (types of GOV departments)
- IIN (Kazakhstan citizen Unique 12 digit id number)
 
### What i used and how to do it by your own ?
```
  1) Catching rect frame in image by using iOS built-in QR detection code.
  2) Using Tessaract Machine Learning framework for Image proccesing and 
     OCR (Optical Character recognition).
  // ----- NOTE: The ML model trainted only for EN/RU/KZ Languages ----
  3) Algorightms for text processing
  4) You are welcome 🎉
```

`Cocoa Pods required` - there is a [link](https://guides.cocoapods.org/using/getting-started.html)
```bash
$ git clone https://github.com/toleberdyyeva/OCR-Switt3-.git
$ pod install 
$ open LiveDetection.xcworkspace/ 
```
## That is it ! :D have a fun coding time

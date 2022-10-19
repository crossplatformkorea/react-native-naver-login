`$ react-native link @react-native-seoul/naver-login`


## Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import com.dooboolab.naverlogin.RNNaverLoginPackage;` to the imports at the top of the file
- Add `new RNNaverLoginPackage()` to the list returned by the `getPackages()` method

  ```java
  List<ReactPackage> packages = new PackageList(this).getPackages();
  packages.add(new RNNaverLoginPackage());
  ```

2. Append the following lines to `android/settings.gradle`:

   ```gradle
   include ':react-native-seoul-naver-login'
   project(':react-native-seoul-naver-login').projectDir = new File(rootProject.projectDir, 	'../node_modules/@react-native-seoul/naver-login/android')
   ```

3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:

   ```gradle
    implementation project(':react-native-seoul-naver-login')
   ```
# Minimal CMake app for Windows (Microsoft Store)

A simple CMake project to build, package, bundle and sign a minimal app for Windows, ready for uploading to the Microsoft Store as a Windows 10/11 PC app.

The app itself is based on [a minimal sample provided by Microsoft](https://learn.microsoft.com/en-us/cpp/windows/walkthrough-creating-windows-desktop-applications-cpp?view=msvc-170).

## How to build and install

I have provided:
- **MakeSelfSignedCertificate.ps1**: a script to generate a local self-signed certificate. You need a local certificate to be able to install the app on your local Windows PC just like it was installed via the Microsoft Store app.
- **cli_build.bat**: a build script that uses CMake 3.24+, Ninja and Visual Studio (2022 Community).

## Create a local self-signed certificate for code-signing

To prepare the app for the Microsoft Store, or to install it on your local machine, you'll need a private certificate key to code-sign the app.

For local installation, we're using a self-signed certificate.

1. Run PowerShell as Admin.
1. Navigate to the source folder (that contains this file).
1. Enter `.\MakeSelfSignedCertificate.ps1`.
1. You will be prompted for a password. Choose your own but make a note of it.
1. Check that the certificate files have been created in your source folder.
1. Check that the certificates have been installed by running the Windows certificate manager.
  - Go to Settings > Manage User Certificates; or Win + R, `certmgr.msc`.
  - Look in **Personal > Certificates** for `CMake.Experiment.Certificate`.
  - Look in **Trusted Root Certification > Certificates** for `CMake.Experiment.Authority`.
  - These don't auto-refresh. Use F5.

## Build and install

You can use your own build script if you wish and your own choice of compiler, CMake & Ninja. However the script provided will exactly replicate my approach.

To use the script, you need to have **Microsoft Visual Studio 2022 (Community edition)** installed, which itself provides CMake & Ninja.
If you have a different version or edition of Visual Studio, edit the path in line 5 of the script.

1. Open the Visual Studio command prompt. (This must match the version & edition in the script.)
1. Navigate to the source folder (that contains this file).
1. Enter `cli_build`.
1. You will be prompted for the `PFX_SIGNATURE_KEY`. Enter the filename of the private certificate key. (It will be `LocalCMakeExperimentKey.pfx` if you used the script above).
1. You will be prompted for the `PFX_PASSWORD`. Enter the password associated with the private certificate key.
1. The script will:
  - create a Release build of the app in the folder `build-Release`,
  - install it into subfolder `build-Release\install`,
  - create a 64-bit package in subfolder `build-Release\packages`,
  - bundle that into `build-Release\CMakeAppForMSStore.appxbundle`,
  - and code sign the bundle.
1. Double-click the bundle at `build-Release\CMakeAppForMSStore.appxbundle` to install it.
1. Either launch the app from the installer or close the installer and launch it in from the Start menu.

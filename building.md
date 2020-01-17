<!-- omit in toc -->
# Building Bill Stewart's Apache Tomcat Setup for Windows

## Prerequisites

* [7-Zip](https://www.7-zip.org/)
* [Inno Setup](https://www.jrsoftware.org/isinfo.php) version 6 or later

## Get the Downloads

Download the Apache Tomcat zip files for the appropriate version of Apache Tomcat. For example, the zip files for Apache Tomcat 9.0.30 are `apache-tomcat-9.0.30-windows-x64.zip` and `apache-tomcat-9.0.30-windows-x86.zip`. Copy these zip files into the build directory.

## Extract the Archives

Run the `Expand-TomcatArchive.ps1` script in the build directory. The script uses 7-Zip to extract the Apache Tomcat archive files and renames the 32-bit and 64-bit binaries appropriately for the Inno Setup script.

## Update `appinfo.ini`

Update the `Major`, `Minor`, and `Patch` lines in `appinfo.ini` file with the matching version of Apache Tomcat you want to build. For example, to build version `9.0.30`, the lines in `appinfo.ini` are:

    [ApacheTomcat]
    Name=Apache Tomcat
    Publisher=Apache Software Foundation
    Major=9
    Minor=0
    Patch=30

    [Setup]
    Author=Bill Stewart
    Version=1.0.0.3
    URL=https://github.com/Bill-Stewart/ApacheTomcatSetup

The `Version` line specifies the version number for the Setup program itself.

## Compile the Inno Setup Script

Use whatever method you prefer to compile the `ApacheTomcat.iss` script using Inno Setup. The output filename will be `apache-tomcat-`_version_`-setup.exe` (where _version_ is the Apache Tomcat version).

## Localization

To localize the Setup program for a specific language, you will need to do the following:

1. Copy the `Messages-en.isl` file to `Messages-`_lang_`.isl` (where _lang_ is the language code you want to use) and update the strings in the file.

2. Create language-specific versions of the `Readme-en.rtf` and `License-en.rtf` files, as appropriate.

3. Update the `[Languages]` section in the `ApacheTomcat.iss` file.

Please see the Inno Setup documentation on the `[Languages]` section for more information.
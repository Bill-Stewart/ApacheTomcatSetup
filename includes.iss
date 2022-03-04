; Bill Stewart's Apache Tomcat Setup - Inno Setup script include file

#define AppGUID "{41186DB8-7806-459C-BE2D-0A672DA928A1}"
#define DefaultInstance "Default"
#define AppURL "https://tomcat.apache.org/"
#define AppName ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "ApacheTomcat", "Name")
#define AppPublisher ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "ApacheTomcat", "Publisher")
#define AppMajorVersion ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "ApacheTomcat", "Major", "0")
#define AppMinorVersion ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "ApacheTomcat", "Minor", "0")
#define AppPatchVersion ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "ApacheTomcat", "Patch", "0")
#define AppFullVersion AppMajorVersion + "." + AppMinorVersion + "." + AppPatchVersion
#define MinJavaVersion ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "Java", "MinVersion", "0")
#define SetupAuthor ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "Setup", "Author")
#define SetupVersion AppFullVersion + ".0"
#define AppUpdatesURL ReadIni(AddBackslash(SourcePath) + "appinfo.ini", "Setup", "URL")
#define RootDir "apache-tomcat-" + AppFullVersion
#define SetupName RootDir + "-setup"
#define SetupCompany SetupAuthor + " (bstewart@iname.com)"
#define IconFilename "tomcat.ico"
#define WizardTopImageFilename "setup-261x261.bmp"
#define WizardLeftImageFilename "setup-537x1043.bmp"
#define ServiceDescription AppName + " application server"
#define RegistryRootPath "SOFTWARE\Apache Software Foundation\Tomcat"
#define DefaultServiceName "Tomcat"
#define DefaultServiceDisplayName AppName
#define DefaultJVMMS "256"
#define DefaultJVMMX "256"

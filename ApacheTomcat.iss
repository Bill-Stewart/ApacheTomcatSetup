; Bill Stewart's Apache Tomcat Setup - Inno Setup script
;
; This installer is written as a replacement for the Apache Tomcat installer
; provided by the Apache Software Foundation (ASF).
;
; Version history:
;
; 1.0.0.0 (2019-12-23)
; * Initial version
;
; 1.0.0.1 (2019-12-30)
; * Fixed: jvm.dll registry subkey name was wrong
; * Fixed: Time stamp format string for conf directory backup
; * Added: Search JRE_HOME in addition to JAVA_HOME
;
; 1.0.0.2 (2020-01-07)
; * Fixed: Set service name registry value only when installing service
; * Improved: Error handling of service install command
; * Changed: Use #include file and separate messages file for localization
;   and improved error message handling
; * Changed: jvm.dll always required (not just if installing service)
; * Changed: Install binaries based on jvm.dll image type rather than OS
; * Added: Search of 32-bit registry if 64-bit registry search fails
; * Added: Determine jvm.dll image type
;
; 1.0.0.3 (2020-01-17)
; * First public version
; * Changed: Adjusted Apache Tomcat logo in left wizard image
; * Changed: Message file tweaks
;
; 1.0.0.4 (2020-03-17)
; * Copy *.jar and *.xml to bin
;
; 1.0.0.5 (2020-06-15)
; * Lowercase standard keywords in PascalScript
;
; 1.0.0.6 (2020-11-25)
; * CloseApplications directive set to "force" mode
; * Delete lib\ecj-*.*.jar at install time to ensure only latest version gets
;   installed
; * Add comparetimestamp flag to *.jar files install
;
; 9.0.41.0 (2020-12-14)
; * Follow Tomcat version numbering (with trailing ".0") to make it easier to
;   check setup executable for version number of Tomcat it installs
; * Replace Windows Restart Manager with custom WMI for automatic
;   service/application stop and automatic service restart (Restart Manager
;   APIs problematic for some applications and do not wait long enough for
;   service/application stop)
; * MinVersion set to 6.1sp1 (security protection against potential DLL
;   preloading attacks)
; * Fix: Skip JVM page and info on ready page if service already installed
;
; 9.0.43.0 (2021-02-03)
; * Fix: "Internal error: Expression error" on reinstall or upgrade
; * Fix: "CreateProcess failed" error if "configure service" selected
; * Replace code search of jvm.dll with JavaInfo.dll functions
; * Add jvm.dll file version and platform to ready memo page
; * Add: Validate minimum Java version
; * Change/fix: jvm.dll path only required/used if installing service
; * Fix: create {app}\conf\Catalina\localhost directory at install
;
; 9.0.45.0 (2021-04-07)
; * Inno Setup preprocessor verify compiling on IS 6.x or newer
; * Change/fix: Move running application check to PrepareToInstall() event
;   function (more appropriate)
; * Updated code formatting (readability)
;
; 9.0.52.0 (2021-08-17)
; * Updated code formatting
;
; 9.0.55 (2021-11-15)
; * Updated JavaInfo.dll to 1.3.0
;
; 9.0.56 (2021-12-09)
; * Updated JavaInfo.dll to 1.3.1
;
; 9.0.59 (2022-03-04)
; * Fix: Don't hard-code default service user name 'NT AUTHORITY\Local Service'
;
; 9.0.71 (2023-01-13)
; * Improved: Prompt to overwrite files in conf that have different hash and
;   are older than the files being installed
; * Updated JavaInfo.dll to 1.4.0
;
; 9.0.72 (2023-02-23)
; * Build with Inno Setup 6.2.2.

#if Ver < EncodeVer(6,0,0,0)
  #error This script requires Inno Setup 6 or later
#endif

#define protected
#include AddBackslash(SourcePath) + "includes.iss"

[Setup]
AllowNoIcons=yes
AppId={code:GetAppId}
AppName={code:GetAppName}
AppPublisher={#AppPublisher}
AppReadmeFile={#AppURL}
AppVersion={#AppFullVersion}
AppUpdatesURL={#AppUpdatesURL}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
CloseApplications=no
Compression=lzma2/max
DefaultDirName={autopf}\{code:GetAppName}
DefaultGroupName={code:GetAppName}
DisableReadyMemo=no
DisableReadyPage=no
DisableWelcomePage=yes
MinVersion=6.1sp1
OutputBaseFilename={#SetupName}
OutputDir=.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline
RestartApplications=yes
SetupIconFile={#IconFilename}
SetupMutex={#SetupName}
SolidCompression=yes
UninstallDisplayIcon={app}\{#IconFilename}
UninstallFilesDir={app}\uninstall
UsePreviousLanguage=no
UsePreviousPrivileges=no
UsePreviousTasks=yes
VersionInfoCompany={#SetupCompany}
VersionInfoDescription={#SetupAuthor}'s {#AppName} Setup
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppFullVersion}
VersionInfoVersion={#SetupVersion}
WizardStyle=modern
WizardImageFile={#WizardLeftImageFilename}
WizardSizePercent=120,132
WizardSmallImageFile={#WizardTopImageFilename}

[Languages]
Name: en; MessagesFile: "compiler:Default.isl,Messages-en.isl"; LicenseFile: "License-en.rtf"; InfoBeforeFile: "Readme-en.rtf"

[Types]
Name: default; Description: "{cm:TypesDefaultDescription}"
Name: core;    Description: "{cm:TypesCoreDescription}"
Name: full;    Description: "{cm:TypesFullDescription}"
Name: custom;  Description: "{cm:TypesCustomDescription}"; Flags: iscustom

[Components]
Name: core;                Description: "{cm:ComponentsCoreDescription}";               Types: default core full custom; Flags: fixed
Name: webapps;             Description: "{cm:ComponentsWebAppsDescription}";            Types: default full custom
Name: webapps/docs;        Description: "{cm:ComponentsWebAppsDocsDescription}";        Types: default full custom
Name: webapps/manager;     Description: "{cm:ComponentsWebAppsManagerDescription}";     Types: default full custom
Name: webapps/hostmanager; Description: "{cm:ComponentsWebAppsHostManagerDescription}"; Types: full custom; Flags: dontinheritcheck
Name: webapps/examples;    Description: "{cm:ComponentsWebAppsExamplesDescription}";    Types: full custom; Flags: dontinheritcheck

[InstallDelete]
Type: files; Name: "{app}\lib\ecj-*.*.jar"; Components: core

[Files]
; Javainfo.dll
Source: "JavaInfo.dll"; Flags: dontcopy
; README
Source: "README.md"; DestDir: "{app}"; DestName: "README-Setup.md"
; Icon file
Source: "{#IconFilename}"; DestDir: "{app}"
; Core files
Source: "{#RootDir}\*"; DestDir: "{app}"; Excludes: "bin\*,conf\*,webapps\*"; Flags: createallsubdirs recursesubdirs comparetimestamp
; bin - Windows scripts
Source: "{#RootDir}\bin\*.bat"; DestDir: "{app}\bin"; Flags: comparetimestamp
; bin - jar files
Source: "{#RootDir}\bin\*.jar"; DestDir: "{app}\bin"; Flags: comparetimestamp
; bin - xml files
Source: "{#RootDir}\bin\*.xml"; DestDir: "{app}\bin"; Flags: comparetimestamp
; bin - Windows binaries - x64
Source: "{#RootDir}\bin\tcnative-1.dll.x64";                DestDir: "{app}\bin"; DestName: "tcnative-1.dll"; Flags: ignoreversion; Check: IsJVM64Bit()
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}.exe.x64";  DestDir: "{app}\bin"; DestName: "tomcat.exe";     Flags: ignoreversion; Check: IsJVM64Bit()
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}w.exe.x64"; DestDir: "{app}\bin"; DestName: "tomcatw.exe";    Flags: ignoreversion; Check: IsJVM64Bit()
; bin - Windows binaries - x86
Source: "{#RootDir}\bin\tcnative-1.dll.x86";                DestDir: "{app}\bin"; DestName: "tcnative-1.dll"; Flags: ignoreversion; Check: not IsJVM64Bit()
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}.exe.x86";  DestDir: "{app}\bin"; DestName: "tomcat.exe";     Flags: ignoreversion; Check: not IsJVM64Bit()
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}w.exe.x86"; DestDir: "{app}\bin"; DestName: "tomcatw.exe";    Flags: ignoreversion; Check: not IsJVM64Bit()
; conf - make backup if task selected
Source: "{app}\conf\*"; DestDir: "{app}\conf-backup-{code:GetDateString}"; Flags: external createallsubdirs recursesubdirs skipifsourcedoesntexist uninsneveruninstall; Tasks: backupconf
; conf
#define FindHandle
#define FindResult
#sub ProcessFoundFile
#define FilePath AddBackslash(RootDir) + "conf\" + FindGetFileName(FindHandle)
#define FileHash GetSHA1OfFile(FilePath)
#define FileTime GetFileDateTimeString(FilePath, 'yyyymmddhhnnss', '', '')
#define FileName ExtractFileName(FilePath)
Source: "{#FilePath}"; DestDir: "{app}\conf"; Check: ShouldCopyFile('{app}\conf\{#FileName}', '{#FileHash}', '{#FileTime}', true); Flags: uninsneveruninstall
#endsub
#for {FindHandle = FindResult = FindFirst(AddBackslash(RootDir) + "conf\*", 0); FindResult; FindResult = FindNext(FindHandle)} ProcessFoundFile
; webapps
Source: "{#RootDir}\webapps\ROOT\*";         DestDir: "{app}\webapps\ROOT";         Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/docs or webapps/manager or webapps/hostmanager or webapps/examples
Source: "{#RootDir}\webapps\docs\*";         DestDir: "{app}\webapps\docs";         Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/docs
Source: "{#RootDir}\webapps\manager\*";      DestDir: "{app}\webapps\manager";      Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/manager
Source: "{#RootDir}\webapps\host-manager\*"; DestDir: "{app}\webapps\host-manager"; Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/hostmanager
Source: "{#RootDir}\webapps\examples\*";     DestDir: "{app}\webapps\examples";     Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/examples

[Dirs]
Name: "{app}\conf\Catalina\localhost"
; Create webapps directory if none of webapps components selected
Name: "{app}\webapps"; Components: (not webapps/docs) and (not webapps/manager) and (not webapps/hostmanager) and (not webapps/examples)

[Icons]
; Home page icon
Name: "{group}\{#AppName} Home Page"; Filename: "{#AppURL}"; IconFilename: "{app}\{#IconFilename}"; Comment: "{cm:IconsHomePageComment}"
; Service icons
Name: "{group}\Configure {#AppName} Service '{code:GetServiceName}'";     Filename: "{app}\bin\tomcatw.exe"; Parameters: """//ES//{code:GetServiceName}"""; IconFilename: "{app}\{#IconFilename}"; Comment: "{cm:IconsServiceConfigureComment}"; Tasks: installservice
Name: "{group}\Monitor {#AppName} Service '{code:GetServiceName}'";       Filename: "{app}\bin\tomcatw.exe"; Parameters: """//MS//{code:GetServiceName}"""; IconFilename: "{app}\{#IconFilename}"; Comment: "{cm:IconsServiceMonitorComment}";   Tasks: installservice
Name: "{autostartup}\Monitor {#AppName} Service '{code:GetServiceName}'"; Filename: "{app}\bin\tomcatw.exe"; Parameters: """//MS//{code:GetServiceName}"""; IconFilename: "{app}\{#IconFilename}"; Comment: "{cm:IconsServiceMonitorComment}";   Tasks: installservice/startmonitoratlogon
; Icon for documentation, if webapps/docs selected
Name: "{group}\{#AppName} Documentation"; Filename: "{app}\webapps\docs\index.html"; IconFilename: "{app}\{#IconFilename}"; Comment: "{cm:IconsDocsComment}"; Components: webapps/docs

[Registry]
; Subkeys
Root: HKA; Subkey: "{#RegistryRootPath}";                                  Flags: uninsdeletekeyifempty
Root: HKA; Subkey: "{#RegistryRootPath}\Instances";                        Flags: uninsdeletekeyifempty
Root: HKA; Subkey: "{#RegistryRootPath}\Instances\{code:GetInstanceName}"; Flags: uninsdeletekeyifempty
; Values
Root: HKA; Subkey: "{#RegistryRootPath}\Instances\{code:GetInstanceName}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}";                 Flags: uninsdeletevalue
Root: HKA; Subkey: "{#RegistryRootPath}\Instances\{code:GetInstanceName}"; ValueType: string; ValueName: "Version";     ValueData: "{#AppFullVersion}";     Flags: uninsdeletevalue
Root: HKA; Subkey: "{#RegistryRootPath}\Instances\{code:GetInstanceName}"; ValueType: string; ValueName: "ServiceName"; ValueData: "{code:GetServiceName}"; Flags: uninsdeletevalue; Tasks: installservice

[Tasks]
; Service install: Must be administrator, and service must not exist
Name: installservice; GroupDescription: "{cm:TasksServiceGroupDescription}"; Description: "{cm:TasksServiceInstallDescription}"; Flags: checkedonce; Check: IsAdminInstallMode() and (not DoesInstanceHaveService())
; Service installation subtasks
Name: installservice/setpermissions;      GroupDescription: "{cm:TasksServiceGroupDescription}"; Description: "{cm:TasksServiceSetPermissionsDescription}";      Flags: checkedonce
Name: installservice/setautostart;        GroupDescription: "{cm:TasksServiceGroupDescription}"; Description: "{cm:TasksServiceSetAutoStartDescription}";        Flags: checkedonce
Name: installservice/startmonitoratlogon; GroupDescription: "{cm:TasksServiceGroupDescription}"; Description: "{cm:TasksServiceStartMonitorAtLogonDescription}"; Flags: checkedonce dontinheritcheck unchecked
; Allow backup of conf directory if it exists
Name: backupconf; GroupDescription: "{cm:TasksOtherGroupDescription}"; Description: "{cm:TasksOtherBackupConfDescription}"; Check: DirExists(ExpandConstant('{app}\conf'))

[Run]
; Grant service user read permission on installation directory
Filename: "{sys}\icacls.exe"; Parameters: """{app}"" /grant ""{code:GetServiceUserName}:(OI)(CI)RX"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
; Grant service user modify permission on conf\Catalina\localhost, logs, temp, and work
Filename: "{sys}\icacls.exe"; Parameters: """{app}\Catalina\localhost"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
Filename: "{sys}\icacls.exe"; Parameters: """{app}\logs"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
Filename: "{sys}\icacls.exe"; Parameters: """{app}\temp"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
Filename: "{sys}\icacls.exe"; Parameters: """{app}\work"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
; Configure service after installation (if selected)
Filename: "{app}\bin\tomcatw.exe"; Parameters: """//ES//{code:GetServiceName}"""; Description: "{cm:RunPostInstallServiceConfigureDescription} '{code:GetServiceName}'"; Flags: nowait postinstall runascurrentuser skipifsilent; Check: ServiceExists(ExpandConstant('{code:GetServiceName}'))

[UninstallRun]
Filename: "{app}\bin\tomcat.exe"; Parameters: """//DS//{code:GetServiceName}"" --LogPath ""{app}\logs"""; Flags: runhidden; Tasks: installservice; RunOnceId: removeservice

[Code]

{
  Summary of installer customizations in [Code] section:

  * Add custom wizard page for jvm.dll path
  * Add custom wizard page to customize service install
  * Add custom command line parameters (/jvmpath, etc.)
  * Custom command line parameters populate fields in custom wizard pages
  * Support multiple installations (/instance parameter)
  * Test whether service exists
  * Use JavaInfo.dll to get Java installation details
  * Validate service does not exist before attempting to install it
  * Validate minimum Java version
  * Skip service config page if service install task not selected
  * Add JVM details to 'Ready to Install' page
  * Service configuration at post-install stage if task selected
  * Use WMI to detect running services/executables
  * If user decides, stop service(s) and automatically restart
  * Stop running executables before installation
}

const
  SC_MANAGER_CONNECT   = 1;
  SERVICE_QUERY_STATUS = 4;

type
  TSCHandle = THandle;
  TServiceStatus = record
    dwServiceType:             DWORD;
    dwCurrentState:            DWORD;
    dwControlsAccepted:        DWORD;
    dwWin32ExitCode:           DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint:              DWORD;
    dwWaitHint:                DWORD;
  end;
  SYSTEMTIME = record
    wYear:         WORD;
    wMonth:        WORD;
    wDayOfWeek:    WORD;
    wDay:          WORD;
    wHour:         WORD;
    wMinute:       WORD;
    wSecond:       WORD;
    wMilliseconds: WORD;
  end;
  TService = record
    ProcessId:   DWORD;
    Name:        string;
    DisplayName: string;
  end;
  TServiceList = array of TService;
  TProcess = record
    ProcessId:      DWORD;
    Name:           string;
    ExecutablePath: string;
  end;
  TProcessList = array of TProcess;

var
  // Custom jvm.dll selection page
  JVMPage: TInputFileWizardPage;
  // Custom service configuration page
  ServicePage: TInputQueryWizardPage;
  // Command line parameters; these can be updated by custom wizard pages
  ArgInstance, ArgJVMPath, ArgServiceName, ArgServiceDisplayName, ArgServiceUserName, ArgJVMOptions,
  ArgJVMMS, ArgJVMMX: string;
  // Progress page
  AppProgressPage: TOutputProgressWizardPage;
  // ActiveX (OLE automation) objects
  WMIService, ShouldCopy: Variant;
  // List of running services for restarting
  RunningServices: TServiceList;

// Windows service functions
function OpenSCManager(lpMachineName: string; lpDatabaseName: string; dwDesiredAccess: DWORD): TSCHandle;
  external 'OpenSCManagerW@advapi32.dll stdcall';
function OpenService(hSCManager: TSCHandle; lpServiceName: string; dwDesiredAccess: DWORD): TSCHandle;
  external 'OpenServiceW@advapi32.dll stdcall';
function QueryServiceStatus(hService: TSCHandle; out lpServiceStatus: TServiceStatus): BOOL;
  external 'QueryServiceStatus@advapi32.dll stdcall';
function CloseServiceHandle(hSCObject: TSCHandle): BOOL;
  external 'CloseServiceHandle@advapi32.dll stdcall';

// Windows file and system time functions
function FileTimeToLocalFileTime(FileTime: TFileTime; var LocalFileTime: TFileTime): Boolean;
  external 'FileTimeToLocalFileTime@kernel32.dll stdcall';
function FileTimeToSystemTime(FileTime: TFileTime; var SystemTime: SYSTEMTIME): Boolean;
  external 'FileTimeToSystemTime@kernel32.dll stdcall';

// Use JavaInfo.dll to detect Java installation details
// Latest version available at https://github.com/Bill-Stewart/JavaInfo
function DLLIsBinary64Bit(FileName: string; var Is64Bit: DWORD): DWORD;
  external 'IsBinary64Bit@files:JavaInfo.dll stdcall setuponly';
function DLLIsJavaInstalled(): DWORD;
  external 'IsJavaInstalled@files:JavaInfo.dll stdcall setuponly';
function DLLGetJavaHome(FileName: string; NumChars: DWORD): DWORD;
  external 'GetJavaHome@files:JavaInfo.dll stdcall setuponly';

// Returns whether a parameter is on command line (not case-sensitive)
function ParamStrExists(const Param: string): Boolean;
var
  I: Integer;
begin
  result := false;
  for I := 1 to ParamCount do
  begin
    result := CompareText(Param, ParamStr(I)) = 0;
    if result then
      exit;
  end;
end;

// JavaInfo.dll function wrapper
function IsBinary64Bit(FileName: string): Boolean;
var
  Is64Bit: DWORD;
begin
  result := false;
  if DLLIsBinary64Bit(FileName, Is64Bit) = 0 then
    result := Is64Bit = 1;
end;

// JavaInfo.dll function wrapper
function IsJavaInstalled(): Boolean;
begin
  result := DLLIsJavaInstalled() = 1;
end;

// JavaInfo.dll function wrapper
function GetJavaHome(): string;
var
  NumChars: DWORD;
  OutStr: string;
begin
  result := '';
  NumChars := DLLGetJavaHome('', 0);
  SetLength(OutStr, NumChars);
  if DLLGetJavaHome(OutStr, NumChars) > 0 then
    result := OutStr;
end;

// Get file date/time as string in the format 'yyyymmddhhnnss'
function GetFileDateTimeString(FileName: string): string;
var
  FindRec: TFindRec;
  LocalFileTime: TFileTime;
  LocalTime: SYSTEMTIME;
begin
  result := '';
  try
    if FindFirst(FileName, FindRec) then
    begin
      if FileTimeToLocalFileTime(FindRec.LastWriteTime, LocalFileTime) then
      begin
        if FileTimeToSystemTime(LocalFileTime, LocalTime) Then
          result := Format('%4.4d%2.2d%2.2d%2.2d%2.2d%2.2d', [LocalTime.wYear,
            LocalTime.wMonth,LocalTime.wDay,LocalTime.wHour,LocalTime.wMinute,
            LocalTime.wSecond]);
      end;
    end;
  finally
    FindClose(FindRec);
  end;
end;

function IsJVM64Bit(): Boolean;
begin
  result := IsBinary64Bit(ArgJVMPath);
end;

function GetJVMVersionString(): string;
var
  Version: string;
begin
  result := '';
  if GetVersionNumbersString(ArgJVMPath, Version) then
    result := Version;
end;

// Returns true if major version of jvm.dll is >= MinVersion in appinfo.ini,
// or false otherwise
function IsJVMVersionOK(): Boolean;
var
  CurVersion, MinVersion: Int64;
  MinJavaVersion: Word;
begin
  result := false;
  if GetPackedVersion(ArgJVMPath, CurVersion) then
  begin
    MinJavaVersion := StrToIntDef(ExpandConstant('{#MinJavaVersion}'), 0);
    MinVersion := PackVersionComponents(MinJavaVersion, 0, 0, 0);
    result := ComparePackedVersion(CurVersion, MinVersion) >= 0;
  end;
end;

// Get whether service exists
// Acknowledgment: TLama (https://stackoverflow.com/questions/32463808/)
function ServiceExists(ServiceName: string): Boolean;
var
  Manager, Service: TSCHandle;
  Status: TServiceStatus;
begin
  result := false;
  Manager := OpenSCManager('', '', SC_MANAGER_CONNECT);
  if Manager <> 0 then
    try
      Service := OpenService(Manager, ServiceName, SERVICE_QUERY_STATUS);
      if Service <> 0 then
        try
          result := QueryServiceStatus(Service, Status);
        finally
          CloseServiceHandle(Service);
        end; //try
    finally
      CloseServiceHandle(Manager);
    end //try
  else
    RaiseException('OpenSCManager failed: ' + SysErrorMessage(DLLGetLastError));
end;

// Use WMI to get localized 'NT AUTHORITY\LOCAL SERVICE' username
function GetLocalServiceUserName(): string;
var
  SWbemLocator, WMIService, SID: Variant;
begin
  try
    SWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    WMIService := SWbemLocator.ConnectServer('', 'root\CIMV2');
    SID := WMIService.Get('Win32_SID.SID=''S-1-5-19''');
    result := SID.ReferencedDomainName + '\' + SID.AccountName;
  except
    result := 'NT Authority\LocalService';
  end;
end;

// Get string representation of jvm.dll image type
function GetJVMImageType(): string;
begin
  if IsJVM64Bit() then
    result := '64-bit'
  else
    result := '32-bit';
end;

// Get installation instance name (see 'Scripted Constants' section in docs)
function GetInstanceName(Param: string): string;
begin
  result := ArgInstance;
end;

// Get AppId (see 'Scripted Constants' section in docs)
function GetAppId(Param: string): string;
begin
  result := ExpandConstant('{{#AppGUID}-') + ArgInstance;
end;

// Get AppName (see 'Scripted Constants' section in docs)
function GetAppName(Param: string): string;
begin
  if CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 then
    result := ExpandConstant('{#AppName}')
  else
    result := ExpandConstant('{#AppName} - ') + ArgInstance;
end;

// Get string containing date/time (see 'Scripted Constants' section in docs)
function GetDateString(Param: string): string;
begin
  result := GetDateTimeString('yyyymmddhhnnss', '-', '-');
end;

// Get service name (see 'Scripted Constants' section in docs)
function GetServiceName(Param: string): string;
begin
  result := ArgServiceName;
end;

// Get service user name (see 'Scripted Constants' section in docs)
function GetServiceUserName(Param: string): string;
begin
  result := ArgServiceUserName;
end;

function GetFileHash(const FileName: string): string;
begin
  result := '';
  try
    result := GetSHA1OfFile(FileName);
  finally
  end;
end;

// Check function: Verify file copy if different and older
// Uses global 'Scripting.Dictionary' ActiveX object to cache results because
// check functions can get called more than once
function ShouldCopyFile(const FilePath, SourceFileHash, SourceFileTime: string; const OverwriteIfSame: Boolean): Boolean;
var
  TargetFilePath, TargetFileHash, TargetFileTime: string;
begin
  TargetFilePath := ExpandConstant(FilePath);
  // Copy if file doesn't exist
  if not FileExists(TargetFilePath) then
  begin
    result := true;
    exit;
  end;
  TargetFileHash := GetFileHash(TargetFilePath);
  if TargetFileHash = '' then
  begin
    result := true;
    exit;
  end;
  // Source and target have same hash: Overwrite if requested
  if CompareText(SourceFileHash, GetSHA1OfFile(TargetFilePath)) = 0 then
  begin
    result := OverwriteIfSame;
    exit;
  end;
  // At this point, we know files are different...
  TargetFileTime := GetFileDateTimeString(TargetFilePath);
  if TargetFileTime = '' then
  begin
    result := true;
    exit;
  end;
  // Source timestamp <= target: Do not overwrite
  if CompareText(SourceFileTime, TargetFileTime) <= 0 then
  begin
    result := false;
    exit;
  end;
  // At this point, we know source timestamp > target...
  // Overwrite if /forceoverwritefiles specified
  if ParamStrExists('/forceoverwritefiles') then
  begin
    result := true;
    exit;
  end;
  // Use cached response if available
  if ShouldCopy.Exists(TargetFilePath) then
  begin
    result := ShouldCopy.Item(TargetFilePath);
    exit;
  end;
  // Prompt to keep or overwrite
  result := SuppressibleTaskDialogMsgBox(CustomMessage('ShouldCopyFileInstructionMessage'),
    FmtMessage(CustomMessage('ShouldCopyFileTextMessage'), [TargetFilePath]),
    mbConfirmation,
    MB_YESNO, [CustomMessage('ShouldCopyFileYesMessage'),
    CustomMessage('ShouldCopyFileNoMessage')],
    0,
    idYes) = IDNO;
  // Cache response
  ShouldCopy.Add(TargetFilePath, result);
end;

// Does instance have installed service?
function DoesInstanceHaveService(): Boolean;
var
  ServiceName: string;
begin
  ServiceName := '';
  result := RegQueryStringValue(HKEY_LOCAL_MACHINE,
    ExpandConstant('{#RegistryRootPath}\Instances\') + ArgInstance,
    'ServiceName', ServiceName) and (Trim(ServiceName) <> '');
end;

// Returns filename of <javahome>\bin\server\jvm.dll if found
function FindJVM(): string;
var
  FileName: string;
begin
  result := '';
  if IsJavaInstalled() then
  begin
    FileName := GetJavaHome() + '\bin\server\jvm.dll';
    if FileExists(FileName) then
      result := FileName;
  end;
end;

// Removes whitespace from a string
function RemoveWhitespace(S: string): string;
var
  WS: TArrayOfString;
  I: Integer;
begin
  SetArrayLength(WS, 2);
  WS[0] := #9;
  WS[1] := ' ';
  for I := 0 to GetArrayLength(WS) - 1 do
    StringChangeEx(S, WS[I], '', true);
  result := S;
end;

function InitializeSetup(): Boolean;
var
  SWbemLocator: Variant;
begin
  result := true;
  // Instance name
  ArgInstance := Trim(ExpandConstant('{param:instance|{#DefaultInstance}}'));
  // JVM path (if unspecified, search)
  ArgJVMPath := Trim(ExpandConstant('{param:jvmpath}'));
  if ArgJVMPath = '' then
    ArgJVMPath := FindJVM();
  // Service name (if unspecified, default depends on instance name)
  ArgServiceName := Trim(ExpandConstant('{param:servicename}'));
  if ArgServiceName = '' then
  begin
    if CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 then
      ArgServiceName := ExpandConstant('{#DefaultServiceName}')
    else
      ArgServiceName := ExpandConstant('{#DefaultServiceName}-') + RemoveWhitespace(ArgInstance);
  end;
  // Service display name (if unspecified, default depends on instance name)
  ArgServiceDisplayName := Trim(ExpandConstant('{param:servicedisplayname}'));
  if ArgServiceDisplayName = '' then
  begin
    if CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 then
      ArgServiceDisplayName := ExpandConstant('{#DefaultServiceDisplayName}')
    else
      ArgServiceDisplayName := ExpandConstant('{#DefaultServiceDisplayName} - ') + ArgInstance;
  end;
  // Service username
  ArgServiceUserName := Trim(ExpandConstant('{param:serviceusername}'));
  if ArgServiceUserName = '' then
  begin
    ArgServiceUserName := GetLocalServiceUserName();
  end;
  // JVM options
  ArgJVMOptions := Trim(ExpandConstant('{param:jvmoptions}'));
  // Memory settings
  ArgJVMMS := Trim(ExpandConstant('{param:jvmms|{#DefaultJVMMS}}'));
  ArgJVMMX := Trim(ExpandConstant('{param:jvmmx|{#DefaultJVMMX}}'));
  // Initialize WMI
  try
    SWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    WMIService := SWbemLocator.ConnectServer('', 'root\CIMV2');
  except
    WMIService := Null();
  end; //try
  SetArrayLength(RunningServices, 0);
  ShouldCopy := CreateOleObject('Scripting.Dictionary');
end;

procedure InitializeWizard();
begin
  // Add custom jvm.dll selection page
  JVMPage := CreateInputFilePage(wpSelectTasks, CustomMessage('JVMPageCaption'),
    CustomMessage('JVMPageDescription'), CustomMessage('JVMPageSubCaption'));
  JVMPage.Add(CustomMessage('JVMPagePathItemCaption'), 'DLL files|*.dll', '');
  JVMPage.Values[0] := ArgJVMPath;
  // Add custom service configuration page
  ServicePage := CreateInputQueryPage(JVMPage.ID, CustomMessage('ServicePageCaption'),
    CustomMessage('ServicePageDescription'), CustomMessage('ServicePageSubCaption'));
  ServicePage.Add(CustomMessage('ServicePageServiceNameItemCaption'), false);
  ServicePage.Values[0] := ArgServiceName;
  ServicePage.Add(CustomMessage('ServicePageServiceDisplayNameItemCaption'), false);
  ServicePage.Values[1] := ArgServiceDisplayName;
  ServicePage.Add(CustomMessage('ServicePageServiceUserNameItemCaption'), false);
  ServicePage.Values[2] := ArgServiceUserName;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMOptionsItemCaption'), false);
  ServicePage.Values[3] := ArgJVMOptions;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMMSItemCaption'), false);
  ServicePage.Values[4] := ArgJVMMS;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMMXItemCaption'), false);
  ServicePage.Values[5] := ArgJVMMX;
  // Add custom progress page
  AppProgressPage := CreateOutputProgressPage(SetupMessage(msgWizardInstalling),
    FmtMessage(CustomMessage('AppProgressPageInstallingCaption'), [ExpandConstant('{#SetupSetting("AppName")}')]));
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  result := false;
  if PageID = JVMPage.ID then
  begin
    // Skip JVM page if service already exists or we are not installing service
    result := ServiceExists(GetServiceName('')) or
      (not WizardIsTaskSelected('installservice'));
  end
  else if PageID = ServicePage.ID then
  begin
    // Skip service configuration page if not installing service
    result := not WizardIsTaskSelected('installservice');
  end;
end;

function ArrayContainsString(var Arr: TArrayOfString; const Item: string): Boolean;
var
  I: Integer;
begin
  result := false;
  for I := 0 to GetArrayLength(Arr) - 1 do
  begin
    result := CompareText(Arr[I], Item) = 0;
    if result then
      exit;
  end;
end;

function GetAppDir(): string;
begin
  result := ExpandConstant('{app}');
end;

// Gets list of running services; returns number running
function GetRunningServices(AppDir: string; var Services: TServiceList): Integer;
var
  WQLQuery: string;
  SWbemObjectSet, SWbemObject: Variant;
  I: Integer;
begin
  result := 0;
  AppDir := AddBackslash(AppDir);
  StringChangeEx(AppDir, '\', '\\', true);
  WQLQuery := Format('SELECT DisplayName,Name,PathName,ProcessId FROM Win32_Service'
    + ' WHERE (PathName LIKE ''"%s%%'') AND (State <> "Stopped")', [AppDir]);
  try
    SWbemObjectSet := WMIService.ExecQuery(WQLQuery);
    if (not VarIsNull(SWbemObjectSet)) and (SWbemObjectSet.Count > 0) then
    begin
      SetArrayLength(Services, SWbemObjectSet.Count);
      for I := 0 to SWbemObjectSet.Count - 1 do
      begin
        SWbemObject := SWbemObjectSet.ItemIndex(I);
        if not VarIsNull(SWbemObject) then
        begin
          Services[I].ProcessId := SWbemObject.ProcessId;
          Services[I].Name := SWbemObject.Name;
          Services[I].DisplayName := SWbemObject.DisplayName;
          result := result + 1;
        end
        else
        begin
          Services[I].ProcessId := 0;
          Services[I].Name := '';
          Services[I].DisplayName := '';
        end;
      end;
    end;
  except
    SetArrayLength(Services, 0);
  end; //try
end;

// Gets list of running processes; returns number running
function GetRunningProcesses(AppDir: string; var Processes: TProcessList): Integer;
var
  WQLQuery: string;
  SWbemObjectSet, SWbemObject: Variant;
  I: Integer;
begin
  result := 0;
  AppDir := AddBackslash(AppDir);
  StringChangeEx(AppDir, '\', '\\', true);
  WQLQuery := Format('SELECT ExecutablePath,Name,ProcessId FROM Win32_Process'
    + ' WHERE ExecutablePath LIKE "%s%%"', [AppDir]);
  try
    SWbemObjectSet := WMIService.ExecQuery(WQLQuery);
    if (not VarIsNull(SWbemObjectSet)) and (SWbemObjectSet.Count > 0) then
    begin
      SetArrayLength(Processes, SWbemObjectSet.Count);
      for I := 0 to SWbemObjectSet.Count - 1 do
      begin
        SWbemObject := SWbemObjectSet.ItemIndex(I);
        if not VarIsNull(SWbemObject) then
        begin
          Processes[I].ProcessId := SWbemObject.ProcessId;
          Processes[I].Name := SWbemObject.Name;
          Processes[I].ExecutablePath := SWbemObject.ExecutablePath;
          result := result + 1;
        end
        else
        begin
          Processes[I].ProcessId := 0;
          Processes[I].Name := '';
          Processes[I].ExecutablePath := '';
        end;
      end;
    end;
  except
    SetArrayLength(Processes, 0);
  end; //try
end;

// Builds a newline-delimited list of running services and processes for GUI
function GetRunningProcessList(AppDir: string): string;
var
  ServiceCount, ProcessCount, I, J, MaxOutput: Integer;
  Services: TServiceList;
  Processes: TProcessList;
  Output: TArrayOfString;
begin
  result := '';
  ServiceCount := GetRunningServices(AppDir, Services);
  ProcessCount := GetRunningProcesses(AppDir, Processes);
  if ServiceCount + ProcessCount = 0 then
    exit;
  SetArrayLength(Output, ServiceCount + ProcessCount);
  for I := 0 to ServiceCount - 1 do
    Output[I] := Services[I].DisplayName;
  J := I;
  for I := 0 to ProcessCount - 1 do
    if not ArrayContainsString(Output, Processes[I].Name) then
    begin
      Output[J] := Processes[I].Name;
      J := J + 1;
    end;
  MaxOutput := 20;
  if GetArrayLength(Output) >= MaxOutput then
  begin
    J := MaxOutput;
    Output[MaxOutput - 1] := '...';
  end
  else
    J := GetArrayLength(Output);
  for I := 0 to J - 1 do
    if Output[I] <> '' then
      if result = '' then
        result := Output[I]
      else
        result := result + #10 + Output[I];
end;

// Runs 'net stop <servicename>' for each running service; returns true if all
// services successfully stopped
function StopRunningServices(AppDir: string): Boolean;
var
  Count, I, ResultCode: Integer;
  Services: TServiceList;
  Command, Parameters: string;
begin
  result := false;
  Count := GetRunningServices(AppDir, Services);
  if Count > 0 then
  begin
    Command := ExpandConstant('{sys}\net.exe');
    for I := 0 to Count - 1 do
    begin
      Parameters := Format('stop "%s"', [Services[I].Name]);
      Log(FmtMessage(CustomMessage('RunCommandMessage'), [Command, Parameters]));
      Exec(Command, Parameters, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
    result := GetRunningServices(AppDir, Services) = 0;
  end;
end;

// Runs 'taskkill /PID <n> [...] /F' for each running process; returns true if
// all processes successfully stopped
function TerminateRunningProcesses(AppDir: string): Boolean;
var
  Count, I, ResultCode: Integer;
  Processes: TProcessList;
  Command, Parameters: string;
begin
  result := false;
  Count := GetRunningProcesses(AppDir, Processes);
  if Count > 0 then
  begin
    Command := ExpandConstant('{sys}\taskkill.exe');
    Parameters := ' ';
    for I := 0 to Count - 1 do
      Parameters := Parameters + Format('/PID %d ', [Processes[I].ProcessId]);
    Parameters := Parameters + '/F';
    Log(FmtMessage(CustomMessage('RunCommandMessage'), [Command, Parameters]));
    Exec(Command, Parameters, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    result := GetRunningProcesses(AppDir, Processes) = 0;
  end;
end;

// Runs 'net start <servicename>' for services that were stopped; returns true
// if all services were successfully started
function StartServices(var Services: TServiceList): Boolean;
var
  Count, I, NumStarted, ResultCode: Integer;
  Command, Parameters: string;
begin
  result := false;
  Count := GetArrayLength(Services);
  if Count > 0 then
  begin
    Command := ExpandConstant('{sys}\net.exe');
    NumStarted := 0;
    for I := 0 to Count - 1 do
    begin
      Parameters := Format('start "%s"', [Services[I].Name]);
      Log(FmtMessage(CustomMessage('RunCommandMessage'), [Command, Parameters]));
      if Exec(Command, Parameters, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0) then
        NumStarted := NumStarted + 1;
    end;
    result := NumStarted = Count;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  I, ID, Value: Integer;
  ControlValues: TArrayOfString;
  Controls: TArrayOfInteger;
begin
  result := true;
  if CurPageID = JVMPage.ID then
  begin
    // Ensure that filename is specified and exists
    result := Trim(JVMPage.Values[0]) <> '';
    if not result then
    begin
      Log(CustomMessage('ErrorJVMPathEmptyLogMessage'));
      if not WizardSilent() then
      begin
        MsgBox(CustomMessage('ErrorJVMPathEmptyGUIMessage'), mbError, MB_OK);
        JVMPage.Values[0] := FindJVM();
        WizardForm.ActiveControl := JVMPage.Edits[0];
        JVMPage.Edits[0].SelectAll();
      end;
      exit;
    end;
    result := FileExists(Trim(JVMPage.Values[0]));
    if not result then
    begin
      Log(FmtMessage(CustomMessage('ErrorJVMPathFileNotFoundLogMessage'), [Trim(JVMPage.Values[0])]));
      if not WizardSilent() then
      begin
        MsgBox(CustomMessage('ErrorJVMPathFileNotFoundGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := JVMPage.Edits[0];
        JVMPage.Edits[0].SelectAll();
      end;
      exit;
    end;
    // Validate minimum jvm.dll version
    result := IsJVMVersionOK();
    if not result then
    begin
      Log(FmtMessage(CustomMessage('ErrorJVMOldLogMessage'), [GetJVMVersionString(), ExpandConstant('{#MinJavaVersion}')]));
      if not WizardSilent() then
      begin
        MsgBox(FmtMessage(CustomMessage('ErrorJVMOldGUIMessage'), [GetJVMVersionString(), ExpandConstant('{#MinJavaVersion}')]), mbError, MB_OK);
        WizardForm.ActiveControl := JVMPage.Edits[0];
        JVMPage.Edits[0].SelectAll();
      end;
      exit;
    end;
    ArgJVMPath := Trim(JVMPage.Values[0]);
  end
  else if CurPageID = ServicePage.ID then
  begin
    // Specify default values for controls on page
    SetArrayLength(ControlValues, 6);
    ControlValues[0] := ArgServiceName;
    ControlValues[1] := ArgServiceDisplayName;
    ControlValues[2] := ArgServiceUserName;
    ControlValues[3] := ArgJVMOptions;
    ControlValues[4] := ArgJVMMS;
    ControlValues[5] := ArgJVMMX;
    // Specify which controls require values
    SetArrayLength(Controls, 5);
    Controls[0] := 0;
    Controls[1] := 1;
    Controls[2] := 2;
    Controls[3] := 4;
    Controls[4] := 5;
    // Validate controls that require values
    for I := 0 to GetArrayLength(Controls) - 1 do
    begin
      ID := Controls[I];
      result := Trim(ServicePage.Values[ID]) <> '';
      if not result then
      begin
        Log(FmtMessage(CustomMessage('ErrorServiceConfigValueMissingLogMessage'), [ServicePage.PromptLabels[ID].Caption]));
        if not WizardSilent() then
        begin
          MsgBox(CustomMessage('ErrorServiceConfigValueMissingGUIMessage'), mbError, MB_OK);
          ServicePage.Values[ID] := ControlValues[ID];
          WizardForm.ActiveControl := ServicePage.Edits[ID];
          ServicePage.Edits[ID].SelectAll();
        end;
        exit;
      end;
    end;
    // Validate service does not exist
    ID := Controls[0];
    result := not ServiceExists(Trim(ServicePage.Values[ID]));
    if not result then
    begin
      Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceAlreadyExistsLogMessage'), [Trim(ServicePage.Values[ID])]));
      if not WizardSilent() then
      begin
        MsgBox(CustomMessage('ErrorServiceConfigServiceAlreadyExistsGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := ServicePage.Edits[ID];
        ServicePage.Edits[ID].SelectAll();
      end;
      exit;
    end;
    // Validate service name does not contain whitespace
    ID := Controls[0];
    result := (Pos(' ', Trim(ServicePage.Values[ID])) = 0) and
      (Pos(#9, Trim(ServicePage.Values[ID])) = 0);
    if not result then
    begin
      Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceNameLogMessage'), [Trim(ServicePage.Values[ID])]));
      if not WizardSilent() then
      begin
        MsgBox(CustomMessage('ErrorServiceConfigServiceNameGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := ServicePage.Edits[ID];
        ServicePage.Edits[ID].SelectAll();
      end;
      exit;
    end;
    // Specify which controls require non-zero values
    SetArrayLength(Controls, 2);
    Controls[0] := 4;
    Controls[1] := 5;
    for I := 0 to GetArrayLength(Controls) - 1 do
    begin
      ID := Controls[I];
      Value := StrToIntDef(Trim(ServicePage.Values[ID]), 0);
      result := Value > 0;
      if not result then
      begin
        Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceMemoryLogMessage'), [Trim(ServicePage.Values[ID]), ServicePage.PromptLabels[ID].Caption]));
        if not WizardSilent() then
        begin
          MsgBox(CustomMessage('ErrorServiceConfigServiceMemoryGUIMessage'), mbError, MB_OK);
          ServicePage.Values[ID] := ControlValues[ID];
          WizardForm.ActiveControl := ServicePage.Edits[ID];
          ServicePage.Edits[ID].SelectAll();
        end;
        exit;
      end;
    end;
    ArgServiceName := Trim(ServicePage.Values[0]);
    ArgServiceDisplayName := Trim(ServicePage.Values[1]);
    ArgServiceUserName := Trim(ServicePage.Values[2]);
    ArgJVMOptions := Trim(ServicePage.Values[3]);
    ArgJVMMS := Trim(ServicePage.Values[4]);
    ArgJVMMX := Trim(ServicePage.Values[5]);
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  ProcList: string;
  OK: Boolean;
  Count: Integer;
  Processes: TProcessList;
begin
  NeedsRestart := false;
  result := '';
  ProcList := GetRunningProcessList(GetAppDir());
  OK := ProcList = '';
  if not OK then
  begin
    Log(CustomMessage('ApplicationsRunningLogMessage'));
    // Don't prompt if command line parameters present
    OK := ParamStrExists('/closeapplications') or
      ParamStrExists('/forcecloseapplications');
    if not OK then
      OK := SuppressibleTaskDialogMsgBox(CustomMessage('ApplicationsRunningInstructionMessage'),
        FmtMessage(CustomMessage('ApplicationsRunningTextMessage'), [ProcList]),
        mbCriticalError,
        MB_YESNO, [CustomMessage('CloseApplicationsMessage'),
        CustomMessage('DontCloseApplicationsMessage')],
        0,
        idNo) = idYes;
    if OK then
    begin
      AppProgressPage.SetText(CustomMessage('AppProgressPageStoppingMessage'), '');
      AppProgressPage.SetProgress(0, 0);
      AppProgressPage.Show();
      try
        AppProgressPage.SetProgress(1, 3);
        // Cache running service(s) in global variable for later restart
        Count := GetRunningServices(GetAppDir(), RunningServices);
        OK := (Count = 0) or (StopRunningServices(GetAppDir()));
        AppProgressPage.SetProgress(2, 3);
        if OK then
        begin
          Count := GetRunningProcesses(GetAppDir(), Processes);
          OK := (Count = 0) or (TerminateRunningProcesses(GetAppDir()));
        end;
        AppProgressPage.SetProgress(3, 3);
        if OK then
          Log(CustomMessage('ClosedApplicationsMessage'))
        else
        begin
          Log(SetupMessage(msgErrorCloseApplications));
          SuppressibleMsgBox(SetupMessage(msgErrorCloseApplications), mbCriticalError, MB_OK, idOk);
        end;
      finally
        AppProgressPage.Hide();
      end; //try
    end
    else
      result := CustomMessage('ApplicationsStillRunningMessage');
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo,
  MemoGroupInfo, MemoTasksInfo: string): string;
var
  S: string;
begin
  S := '';
  if MemoUserInfoInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoUserInfoInfo;
  end;
  if MemoDirInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoDirInfo;
  end;
  if MemoTypeInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoTypeInfo;
  end;
  if MemoComponentsInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoComponentsInfo;
  end;
  if MemoGroupInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoGroupInfo;
  end;
  // Show JVM info if installing service
  if (not ServiceExists(GetServiceName(''))) and (WizardIsTaskSelected('installservice')) then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + CustomMessage('ReadyMemoJVMInfo') + NewLine
      + Space + CustomMessage('ReadyMemoJVMPath') + ' ' + ArgJVMPath + NewLine
      + Space + CustomMessage('ReadyMemoJVMVersion') + ' ' + GetJVMVersionString() + NewLine
      + Space + CustomMessage('ReadyMemoJVMPlatform') + ' ' + GetJVMImageType();
  end;
  if MemoTasksInfo <> '' then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoTasksInfo;
  end;
  // If installing service, list service configuration information
  if WizardIsTaskSelected('installservice') then
  begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + CustomMessage('ReadyMemoServiceConfigInfo') + NewLine
      + Space + CustomMessage('ReadyMemoServiceNameInfo') + ' ' + ArgServiceName + NewLine
      + Space + CustomMessage('ReadyMemoServiceDisplayNameInfo') + ' ' + ArgServiceDisplayName + NewLine
      + Space + CustomMessage('ReadyMemoServiceUserNameInfo') + ' ' + ArgServiceUserName + NewLine;
    if ArgJVMOptions <> '' then
      S := S + Space + CustomMessage('ReadyMemoServiceJVMOptionsInfo') + ' ' + ArgJVMOptions + NewLine;
    S := S + Space + CustomMessage('ReadyMemoServiceJVMMSInfo') + ' ' + ArgJVMMS + 'MB' + NewLine
      + Space + CustomMessage('ReadyMemoServiceJVMMXInfo') + ' ' + ArgJVMMX + 'MB';
  end;
  result := S;
end;

procedure InstallService();
var
  Executable, StartupMode, Params, ErrorMessage: string;
  ResultCode: Integer;
begin
  Executable := ExpandConstant('{app}\bin\tomcat.exe');
  if WizardIsTaskSelected('installservice/setautostart') then
    StartupMode := 'auto'
  else
    StartupMode := 'manual';
  Params := '"//IS//' + ArgServiceName + '"'
    + ' --DisplayName "' + ArgServiceDisplayName + '"'
    + ' --Description "' + ExpandConstant('{#ServiceDescription}') + '"'
    + ' --Install "' + Executable + '"'
    + ' --LogPath "' + ExpandConstant('{app}\logs') + '"'
    + ' --LogPrefix commons-daemon'
    + ' --ServiceUser "' + ArgServiceUserName + '"'
    + ' --StdOutput auto'
    + ' --StdError auto'
    + ' --Classpath "' + ExpandConstant('{app}\bin\bootstrap.jar;'
    +                                   '{app}\bin\tomcat-juli.jar') + '"'
    + ' --Jvm "' + ArgJVMPath + '"'
    + ' --Startup ' + StartupMode
    + ' --StartMode jvm'
    + ' --StopMode jvm'
    + ' --StartPath "' + ExpandConstant('{app}') + '"'
    + ' --StopPath "' + ExpandConstant('{app}') + '"'
    + ' --StartClass org.apache.catalina.startup.Bootstrap'
    + ' --StopClass org.apache.catalina.startup.Bootstrap'
    + ' --StartParams start'
    + ' --StopParams stop'
    + ' --JvmOptions "' + ExpandConstant('-Dcatalina.home={app};'
    +     '-Dcatalina.base={app};'
    +     '-Djava.io.tmpdir={app}\temp;'
    +     '-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager;'
    +     '-Djava.util.logging.config.file={app}\conf\logging.properties');
  if ArgJVMOptions <> '' then
    Params := Params + ';' + ArgJVMOptions;
  Params := Params + '"'
    + ' --JvmOptions9 "--add-opens=java.base/java.lang=ALL-UNNAMED#'
    +     '--add-opens=java.base/java.io=ALL-UNNAMED#'
    +     '--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"'
    + ' --JvmMs ' + ArgJVMMS
    + ' --JvmMx ' + ArgJVMMX;
  Log(FmtMessage(CustomMessage('ServiceInstallCommandLogMessage'), [Executable, Params]));
  if (not Exec(Executable, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode)) or (ResultCode <> 0) then
  begin
    ErrorMessage := SysErrorMessage(ResultCode);
    Log(FmtMessage(CustomMessage('ErrorServiceInstallLogMessage'), [ArgServiceName, IntToStr(ResultCode), ErrorMessage]));
    if not WizardSilent() then
      MsgBox(FmtMessage(CustomMessage('ErrorServiceInstallGUIMessage'), [IntToStr(ResultCode), ErrorMessage]), mbCriticalError, MB_OK);
  end
  else
    Log(CustomMessage('ServiceInstallCommandSucceededLogMessage'));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if ArgJVMPath <> '' then
    begin
      Log(FmtMessage(CustomMessage('JVMPathLogMessage'), [ArgJVMPath]));
      Log(FmtMessage(CustomMessage('JVMVersionLogMessage'), [GetJVMVersionString()]));
      Log(FmtMessage(CustomMessage('JVMImageTypeLogMessage'), [GetJVMImageType()]));
    end;
  end
  else if CurStep = ssPostInstall then
  begin
    if WizardIsTaskSelected('installservice') then
      InstallService();
    if GetArrayLength(RunningServices) > 0 then
    begin
      AppProgressPage.SetText(CustomMessage('AppProgressPageStartingMessage'), '');
      AppProgressPage.SetProgress(0, 0);
      AppProgressPage.Show();
      try
        AppProgressPage.SetProgress(1, 2);
        if StartServices(RunningServices) then
          Log(CustomMessage('StartedServicesMessage'));
        AppProgressPage.SetProgress(2, 2);
      finally
        AppProgressPage.Hide();
      end; //try
    end;
  end;
end;

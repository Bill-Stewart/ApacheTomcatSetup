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
CloseApplications=force
CloseApplicationsFilter=*.exe,*.dll,*.jar
Compression=lzma2/max
DefaultDirName={autopf}\{code:GetAppName}
DefaultGroupName={code:GetAppName}
DisableReadyMemo=no
DisableReadyPage=no
DisableWelcomePage=no
MinVersion=6
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
Source: "{#RootDir}\bin\tcnative-1.dll.x64";                DestDir: "{app}\bin"; DestName: "tcnative-1.dll"; Flags: ignoreversion; Check: IsJVM64Bit
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}.exe.x64";  DestDir: "{app}\bin"; DestName: "tomcat.exe";     Flags: ignoreversion; Check: IsJVM64Bit
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}w.exe.x64"; DestDir: "{app}\bin"; DestName: "tomcatw.exe";    Flags: ignoreversion; Check: IsJVM64Bit
; bin - Windows binaries - x86
Source: "{#RootDir}\bin\tcnative-1.dll.x86";                DestDir: "{app}\bin"; DestName: "tcnative-1.dll"; Flags: ignoreversion; Check: not IsJVM64Bit
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}.exe.x86";  DestDir: "{app}\bin"; DestName: "tomcat.exe";     Flags: ignoreversion; Check: not IsJVM64Bit
Source: "{#RootDir}\bin\tomcat{#AppMajorVersion}w.exe.x86"; DestDir: "{app}\bin"; DestName: "tomcatw.exe";    Flags: ignoreversion; Check: not IsJVM64Bit
; conf - make backup if task selected
Source: "{app}\conf\*"; DestDir: "{app}\conf-backup-{code:GetDateString}"; Flags: external createallsubdirs recursesubdirs skipifsourcedoesntexist uninsneveruninstall; Tasks: backupconf
; conf
Source: "{#RootDir}\conf\*"; DestDir: "{app}\conf"; Flags: createallsubdirs recursesubdirs comparetimestamp uninsneveruninstall
; webapps
Source: "{#RootDir}\webapps\ROOT\*";         DestDir: "{app}\webapps\ROOT";         Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/docs or webapps/manager or webapps/hostmanager or webapps/examples
Source: "{#RootDir}\webapps\docs\*";         DestDir: "{app}\webapps\docs";         Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/docs
Source: "{#RootDir}\webapps\manager\*";      DestDir: "{app}\webapps\manager";      Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/manager
Source: "{#RootDir}\webapps\host-manager\*"; DestDir: "{app}\webapps\host-manager"; Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/hostmanager
Source: "{#RootDir}\webapps\examples\*";     DestDir: "{app}\webapps\examples";     Flags: createallsubdirs recursesubdirs comparetimestamp; Components: webapps/examples

[Dirs]
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
; Grant service user modify permission on logs, temp, and work
Filename: "{sys}\icacls.exe"; Parameters: """{app}\logs"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
Filename: "{sys}\icacls.exe"; Parameters: """{app}\temp"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
Filename: "{sys}\icacls.exe"; Parameters: """{app}\work"" /grant ""{code:GetServiceUserName}:(OI)(CI)M"" /T"; StatusMsg: "{cm:RunSetPermissionsStatusMsg}"; Flags: runhidden; Tasks: installservice/setpermissions
; Configure service after installation (if selected)
Filename: "{app}\bin\tomcatw.exe"; Parameters: """//ES//{code:GetServiceName}"""; Description: "{cm:RunPostInstallServiceConfigureDescription} '{code:GetServiceName}'"; Flags: nowait postinstall skipifsilent; Check: ServiceExists(ExpandConstant('{code:GetServiceName}'))

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
  * Search for jvm.dll using registry/JAVA_HOME/JRE_HOME
  * Get file image type
  * Validate service does not exist before attempting to install it
  * Skip service config page if service install task not selected
  * Add JVM install details to 'Ready to Install' page
  * Service installation at post-install stage if task selected
}

const
  SC_MANAGER_CONNECT   = 1;
  SERVICE_QUERY_STATUS = 4;

type
  TSCHandle = THandle;
  TServiceStatus =
    record
    dwServiceType:             DWORD;
    dwCurrentState:            DWORD;
    dwControlsAccepted:        DWORD;
    dwWin32ExitCode:           DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint:              DWORD;
    dwWaitHint:                DWORD;
    end;

var
  // Custom jvm.dll selection page
  JVMPage: TInputFileWizardPage;
  // Custom service configuration page
  ServicePage: TInputQueryWizardPage;
  // Command line parameters; these can be updated by custom wizard pages
  ArgInstance, ArgJVMPath, ArgServiceName, ArgServiceDisplayName,
  ArgServiceUserName, ArgJVMOptions, ArgJVMMS, ArgJVMMX: string;

function OpenSCManager(lpMachineName: string; lpDatabaseName: string; dwDesiredAccess: DWORD): TSCHandle;
  external 'OpenSCManagerW@advapi32.dll stdcall';
function OpenService(hSCManager: TSCHandle; lpServiceName: string; dwDesiredAccess: DWORD): TSCHandle;
  external 'OpenServiceW@advapi32.dll stdcall';
function QueryServiceStatus(hService: TSCHandle; out lpServiceStatus: TServiceStatus): BOOL;
  external 'QueryServiceStatus@advapi32.dll stdcall';
function CloseServiceHandle(hSCObject: TSCHandle): BOOL;
  external 'CloseServiceHandle@advapi32.dll stdcall';

// Get whether service exists
// Acknowledgment: TLama (https://stackoverflow.com/questions/32463808/)
function ServiceExists(ServiceName: string): boolean;
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

// Support for GetImageType()
function BufferToWord(const Buffer: string): word;
  begin
  result := ord(Buffer[1]);
  end;

// Support for GetImageType()
function BufferToLongWord(const Buffer: string): longword;
  begin
  result := (ord(Buffer[2]) shl 16) + ord(Buffer[1]);
  end;

// Support for GetImageType()
function ReadFromStream(Stream: TStream; Size: integer): longword;
  var
    Buffer: string;
  begin
  try
    SetLength(Buffer, Size div 2);
    Stream.ReadBuffer(Buffer, Size);
    case Size of
      2: result := BufferToWord(Buffer);
      4: result := BufferToLongWord(Buffer);
    end; //case
  except
    result := 0;
  end; //try
  end;

// Gets EXE/DLL image type; returns:
// * 0 for 32-bit image
// * 1 for 64-bit image
// * -1 for unknown type
// Acknowledgment: TLama (https://stackoverflow.com/questions/19932165/)
function GetImageType(const FileName: string): integer;
  var
    FileStream: TFileStream;
    PEOffset: longword;
    MagicNumber: word;
  begin
  result := -1;
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    FileStream.Position := $3C;
    PEOffset := ReadFromStream(FileStream, SizeOf(PEOffset));
    FileStream.Position := PEOffset + $18;
    MagicNumber := ReadFromStream(FileStream, SizeOf(MagicNumber));
    case MagicNumber of
      $010B: result := 0; // 32-bit image
      $020B: result := 1; // 64-bit image
    end; //case
  finally
    FileStream.Free();
  end; //try
  end;

// Is jvm.dll file 64-bit?
function IsJVM64Bit(): boolean;
  begin
  result := GetImageType(ArgJVMPath) = 1;
  end;

// Get string representation of jvm.dll image type
function GetJVMImageType(): string;
  var
    ImageType: integer;
  begin
  ImageType := GetImageType(ArgJVMPath);
  case ImageType of
    -1: result := 'unknown';
    0:  result := '32-bit';
    1:  result := '64-bit';
  end; //case
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

// Does instance have installed service?
function DoesInstanceHaveService(): boolean;
  var
    ServiceName: string;
  begin
  ServiceName := '';
  result := RegQueryStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('{#RegistryRootPath}\Instances\') + ArgInstance, 'ServiceName', ServiceName) and (Trim(ServiceName) <> '');
  end;

// Searches a subdirectory tree for a file by name
// Acknowledgment: Martin Prikryl (https://stackoverflow.com/questions/37133947/)
function FindFile(RootPath: string; FileName: string): string;
  var
    FindRec: TFindRec;
    FilePath: string;
  begin
  if FindFirst(RemoveBackslashUnlessRoot(RootPath) + '\*', FindRec) then
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
          begin
          FilePath := RemoveBackslashUnlessRoot(RootPath) + '\' + FindRec.Name;
          if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0 then
            begin
            result := FindFile(FilePath, FileName);
            if result <> '' then
              exit;
            end
          else if CompareText(FindRec.Name, FileName) = 0 then
            begin
            result := FilePath;
            exit;
            end
          else
            result := '';
          end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end; //try
  end;

// Compares two version number strings; returns:
// -1 if V1 < V2, 0 if V1 = V2, or 1 if V1 > V2
// Acknowledgment: Martin Prikryl (https://stackoverflow.com/questions/37825650/)
function CompareVersions(V1, V2: string): integer;
  var
    P, N1, N2: integer;
  begin
  result := 0;
  while (result = 0) and ((V1 <> '') or (V2 <> '')) do
    begin
    P := Pos('.', V1);
    if P > 0 then
      begin
      N1 := StrToIntDef(Copy(V1, 1, P - 1), 0);
      Delete(V1, 1, P);
      end
    else if V1 <> '' then
      begin
      N1 := StrToIntDef(V1, 0);
      V1 := '';
      end
    else
      N1 := 0;
    P := Pos('.', V2);
    if P > 0 then
      begin
      N2 := StrToIntDef(Copy(V2, 1, P - 1), 0);
      Delete(V2, 1, P);
      end
    else if V2 <> '' then
      begin
      N2 := StrToIntDef(V2, 0);
      V2 := '';
      end
    else
      N2 := 0;
    if N1 < N2 then
      result := -1
    else if N1 > N2 then
      result := 1;
    end;
  end;

// Tries to find jvm.dll
function FindJVM(): string;
  var
    StringList, SubkeyNames: TArrayOfString;
    I, RootKey, J: integer;
    SubkeyExists: boolean;
    SubkeyName, LatestVersion, EnvHome: string;
  begin
  result := '';
  // Search registry for 'RuntimeLib' value in these locations
  SetArrayLength(StringList, 2);
  StringList[0] := 'SOFTWARE\JavaSoft\Java Runtime Environment';
  StringList[1] := 'SOFTWARE\JavaSoft\JRE';
  for I := 0 to GetArrayLength(StringList) - 1 do
    begin
    SubkeyExists := false;
    SubkeyName := StringList[I];
    if IsWin64() then
      begin
      SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE_64, SubkeyName);
      if SubkeyExists then
        RootKey := HKEY_LOCAL_MACHINE_64
      else
        begin
        SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE_32, SubkeyName);
        if SubkeyExists then
          RootKey := HKEY_LOCAL_MACHINE_32;
        end;
      end
    else
      begin
      SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE, SubkeyName);
      if SubkeyExists then
        RootKey := HKEY_LOCAL_MACHINE;
      end;
    if SubkeyExists then
      begin
      LatestVersion := '0';
      if RegGetSubkeyNames(RootKey, SubkeyName, SubkeyNames) then
        begin
        for J := 0 to GetArrayLength(SubkeyNames) - 1 do
          begin
          if CompareVersions(SubkeyNames[J], LatestVersion) > 0 then
            LatestVersion := SubkeyNames[J];
          end;
        if RegQueryStringValue(RootKey, SubkeyName + '\' + LatestVersion, 'RuntimeLib', result) then
          break;
        end;
      end;
    end;
  if result = '' then
    begin
    // Registry search failed; try environment variables
    SetArrayLength(StringList, 2);
    StringList[0] := 'JAVA_HOME';
    StringList[1] := 'JRE_HOME';
    for I := 0 to GetArrayLength(StringList) - 1 do
      begin
      EnvHome := Trim(RemoveBackslashUnlessRoot(GetEnv(StringList[I])));
      if (EnvHome <> '') and DirExists(EnvHome) then
        result := FindFile(EnvHome, 'jvm.dll');
      if result <> '' then
        break;
      end;
    end;
  end;

// Removes whitespace from a string
function RemoveWhitespace(S: string): string;
  var
    WS: TArrayOfString;
    I: integer;
  begin
  SetArrayLength(WS, 2);
  WS[0] := #9;
  WS[1] := ' ';
  for I := 0 to GetArrayLength(WS) - 1 do
    StringChangeEx(S, WS[I], '', true);
  result := S;
  end;

function InitializeSetup(): boolean;
  begin
  result := true;
  // Instance name
  ArgInstance := Trim(ExpandConstant('{param:instance|{#DefaultInstance}}'));
  // JVM path (if unspecified, search)
  ArgJVMPath := Trim(ExpandConstant('{param:jvmpath}'));
  if ArgJVMPath = '' then
    ArgJVMPath := Trim(FindJVM());
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
  ArgServiceUserName := Trim(ExpandConstant('{param:serviceusername|{#DefaultServiceUserName}}'));
  // JVM options
  ArgJVMOptions := Trim(ExpandConstant('{param:jvmoptions}'));
  // Memory settings
  ArgJVMMS := Trim(ExpandConstant('{param:jvmms|{#DefaultJVMMS}}'));
  ArgJVMMX := Trim(ExpandConstant('{param:jvmmx|{#DefaultJVMMX}}'));
  end;

procedure InitializeWizard();
  begin
  // Add custom jvm.dll selection page
  JVMPage := CreateInputFilePage(wpSelectTasks, CustomMessage('JVMPageCaption'), CustomMessage('JVMPageDescription'), CustomMessage('JVMPageSubCaption'));
  JVMPage.Add(CustomMessage('JVMPagePathItemCaption'), 'DLL files|*.dll', '');
  JVMPage.Values[0] := ArgJVMPath;
  // Add custom service configuration page
  ServicePage := CreateInputQueryPage(JvmPage.ID, CustomMessage('ServicePageCaption'), CustomMessage('ServicePageDescription'), CustomMessage('ServicePageSubCaption'));
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
  end;

function ShouldSkipPage(PageID: integer): boolean;
  begin
  // Skip service configuration page if not installing service
  result := false;
  if PageID = ServicePage.ID then
    result := not WizardIsTaskSelected('installservice');
  end;

function NextButtonClick(CurPageID: integer): boolean;
  var
    I, ID, Value: integer;
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
    result := (Pos(' ', Trim(ServicePage.Values[ID])) = 0) and (Pos(#9, Trim(ServicePage.Values[ID])) = 0);
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

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: string): string;
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
  if MemoTasksInfo <> '' then
    begin
    if S <> '' then
      S := S + NewLine + NewLine;
    S := S + MemoTasksInfo;
    end;
  // List path of jvm.dll file
  if S <> '' then
    S := S + NewLine + NewLine;
  S := S + CustomMessage('ReadyMemoJVMPathInfo') + NewLine
    + Space + ArgJVMPath;
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
    ResultCode: integer;
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
    Params := Params
      + ';' + ArgJVMOptions;
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
    Log(FmtMessage(CustomMessage('JVMPathLogMessage'), [ArgJVMPath]));
    Log(FmtMessage(CustomMessage('JVMImageTypeLogMessage'), [GetJVMImageType()]));
    end
  else if CurStep = ssPostInstall then
    begin
    if WizardIsTaskSelected('installservice') then
      InstallService();
    end;
  end;

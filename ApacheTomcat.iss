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
CloseApplications=yes
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
Source: "{#RootDir}\bin\*.jar"; DestDir: "{app}\bin"
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

Const
  SC_MANAGER_CONNECT   = 1;
  SERVICE_QUERY_STATUS = 4;

Type
  TSCHandle = THandle;
  TServiceStatus =
    Record
    dwServiceType:             DWORD;
    dwCurrentState:            DWORD;
    dwControlsAccepted:        DWORD;
    dwWin32ExitCode:           DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint:              DWORD;
    dwWaitHint:                DWORD;
    End;

Var
  // Custom jvm.dll selection page
  JVMPage: TInputFileWizardPage;
  // Custom service configuration page
  ServicePage: TInputQueryWizardPage;
  // Command line parameters; these can be updated by custom wizard pages
  ArgInstance, ArgJVMPath, ArgServiceName, ArgServiceDisplayName,
  ArgServiceUserName, ArgJVMOptions, ArgJVMMS, ArgJVMMX: String;

Function OpenSCManager(lpMachineName: String; lpDatabaseName: String; dwDesiredAccess: DWORD): TSCHandle;
  External 'OpenSCManagerW@advapi32.dll stdcall';
Function OpenService(hSCManager: TSCHandle; lpServiceName: String; dwDesiredAccess: DWORD): TSCHandle;
  External 'OpenServiceW@advapi32.dll stdcall';
Function QueryServiceStatus(hService: TSCHandle; Out lpServiceStatus: TServiceStatus): BOOL;
  External 'QueryServiceStatus@advapi32.dll stdcall';
Function CloseServiceHandle(hSCObject: TSCHandle): BOOL;
  External 'CloseServiceHandle@advapi32.dll stdcall';

// Get whether service exists
// Acknowledgment: TLama (https://stackoverflow.com/questions/32463808/)
Function ServiceExists(ServiceName: String): Boolean;
  Var
    Manager, Service: TSCHandle;
    Status: TServiceStatus;
  Begin
  Result := False;
  Manager := OpenSCManager('', '', SC_MANAGER_CONNECT);
  If Manager <> 0 Then
    Try
      Service := OpenService(Manager, ServiceName, SERVICE_QUERY_STATUS);
      If Service <> 0 Then
        Try
          Result := QueryServiceStatus(Service, Status);
        Finally
          CloseServiceHandle(Service);
        End; //Try
    Finally
      CloseServiceHandle(Manager);
    End //Try
  Else
    RaiseException('OpenSCManager failed: ' + SysErrorMessage(DLLGetLastError));
  End;

// Support for GetImageType()
Function BufferToWord(Const Buffer: String): Word;
  begin
  Result := Ord(Buffer[1]);
  end;

// Support for GetImageType()
Function BufferToLongWord(Const Buffer: String): LongWord;
  Begin
  Result := (Ord(Buffer[2]) Shl 16) + Ord(Buffer[1]);
  End;

// Support for GetImageType()
Function ReadFromStream(Stream: TStream; Size: Integer): LongWord;
  Var
    Buffer: String;
  Begin
  Try
    SetLength(Buffer, Size Div 2);
    Stream.ReadBuffer(Buffer, Size);
    Case Size Of
      2: Result := BufferToWord(Buffer);
      4: Result := BufferToLongWord(Buffer);
    End; //Case
  Except
    Result := 0;
  End; //Try
  End;

// Gets EXE/DLL image type; returns:
// * 0 for 32-bit image
// * 1 for 64-bit image
// * -1 for unknown type
// Acknowledgment: TLama (https://stackoverflow.com/questions/19932165/)
Function GetImageType(Const FileName: String): Integer;
  Var
    FileStream: TFileStream;
    PEOffset: LongWord;
    MagicNumber: Word;
  Begin
  Result := -1;
  FileStream := TFileStream.Create(FileName, fmOpenRead Or fmShareDenyNone);
  Try
    FileStream.Position := $3C;
    PEOffset := ReadFromStream(FileStream, SizeOf(PEOffset));
    FileStream.Position := PEOffset + $18;
    MagicNumber := ReadFromStream(FileStream, SizeOf(MagicNumber));
    Case MagicNumber Of
      $010B: Result := 0; // 32-bit image
      $020B: Result := 1; // 64-bit image
    End; //Case
  Finally
    FileStream.Free();
  End; //Try
  End;

// Is jvm.dll file 64-bit?
Function IsJVM64Bit(): Boolean;
  Begin
  Result := GetImageType(ArgJVMPath) = 1;
  End;

// Get string representation of jvm.dll image type
Function GetJVMImageType(): String;
  Var
    ImageType: Integer;
  Begin
  ImageType := GetImageType(ArgJVMPath);
  Case ImageType Of
    -1: Result := 'unknown';
    0:  Result := '32-bit';
    1:  Result := '64-bit';
  End; //Case
  End;

// Get installation instance name (see 'Scripted Constants' section in docs)
Function GetInstanceName(Param: String): String;
  Begin
  Result := ArgInstance;
  End;

// Get AppId (see 'Scripted Constants' section in docs)
Function GetAppId(Param: String): String;
  Begin
  Result := ExpandConstant('{{#AppGUID}-') + ArgInstance;
  End;

// Get AppName (see 'Scripted Constants' section in docs)
Function GetAppName(Param: String): String;
  Begin
  If CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 Then
    Result := ExpandConstant('{#AppName}')
  Else
    Result := ExpandConstant('{#AppName} - ') + ArgInstance;
  End;

// Get string containing date/time (see 'Scripted Constants' section in docs)
Function GetDateString(Param: String): String;
  Begin
  Result := GetDateTimeString('yyyymmddhhnnss', '-', '-');
  End;

// Get service name (see 'Scripted Constants' section in docs)
Function GetServiceName(Param: String): String;
  Begin
  Result := ArgServiceName;
  End;

// Get service user name (see 'Scripted Constants' section in docs)
Function GetServiceUserName(Param: String): String;
  Begin
  Result := ArgServiceUserName;
  End;

// Does instance have installed service?
Function DoesInstanceHaveService(): Boolean;
  Var
    ServiceName: String;
  Begin
  ServiceName := '';
  Result := RegQueryStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('{#RegistryRootPath}\Instances\') + ArgInstance, 'ServiceName', ServiceName) And (Trim(ServiceName) <> '');
  End;

// Searches a subdirectory tree for a file by name
// Acknowledgment: Martin Prikryl (https://stackoverflow.com/questions/37133947/)
Function FindFile(RootPath: String; FileName: String): String;
  Var
    FindRec: TFindRec;
    FilePath: String;
  Begin
  If FindFirst(RemoveBackslashUnlessRoot(RootPath) + '\*', FindRec) Then
    Try
      Repeat
        If (FindRec.Name <> '.') And (FindRec.Name <> '..') Then
          Begin
          FilePath := RemoveBackslashUnlessRoot(RootPath) + '\' + FindRec.Name;
          If FindRec.Attributes And FILE_ATTRIBUTE_DIRECTORY <> 0 Then
            Begin
            Result := FindFile(FilePath, FileName);
            If Result <> '' Then
              Exit;
            End
          Else If CompareText(FindRec.Name, FileName) = 0 Then
            Begin
            Result := FilePath;
            Exit;
            End
          Else
            Result := '';
          End;
      Until Not FindNext(FindRec);
    Finally
      FindClose(FindRec);
    End; //Try
  End;

// Compares two version number strings; returns:
// -1 if V1 < V2, 0 if V1 = V2, or 1 if V1 > V2
// Acknowledgment: Martin Prikryl (https://stackoverflow.com/questions/37825650/)
Function CompareVersions(V1, V2: String): Integer;
  Var
    P, N1, N2: Integer;
  Begin
  Result := 0;
  While (Result = 0) And ((V1 <> '') Or (V2 <> '')) Do
    Begin
    P := Pos('.', V1);
    If P > 0 Then
      Begin
      N1 := StrToIntDef(Copy(V1, 1, P - 1), 0);
      Delete(V1, 1, P);
      End
    Else If V1 <> '' Then
      Begin
      N1 := StrToIntDef(V1, 0);
      V1 := '';
      End
    Else
      N1 := 0;
    P := Pos('.', V2);
    If P > 0 Then
      Begin
      N2 := StrToIntDef(Copy(V2, 1, P - 1), 0);
      Delete(V2, 1, P);
      End
    Else If V2 <> '' Then
      Begin
      N2 := StrToIntDef(V2, 0);
      V2 := '';
      End
    Else
      N2 := 0;
    If N1 < N2 Then
      Result := -1
    Else If N1 > N2 Then
      Result := 1;
    End;
  End;

// Tries to find jvm.dll
Function FindJVM(): String;
  Var
    StringList, SubkeyNames: TArrayOfString;
    I, RootKey, J: Integer;
    SubkeyExists: Boolean;
    SubkeyName, LatestVersion, EnvHome: String;
  Begin
  Result := '';
  // Search registry for 'RuntimeLib' value in these locations
  SetArrayLength(StringList, 2);
  StringList[0] := 'SOFTWARE\JavaSoft\Java Runtime Environment';
  StringList[1] := 'SOFTWARE\JavaSoft\JRE';
  For I := 0 To GetArrayLength(StringList) - 1 Do
    Begin
    SubkeyExists := False;
    SubkeyName := StringList[I];
    If IsWin64() Then
      Begin
      SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE_64, SubkeyName);
      If SubkeyExists Then
        RootKey := HKEY_LOCAL_MACHINE_64
      Else
        Begin
        SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE_32, SubkeyName);
        If SubkeyExists Then
          RootKey := HKEY_LOCAL_MACHINE_32;
        End;
      End
    Else
      Begin
      SubkeyExists := RegKeyExists(HKEY_LOCAL_MACHINE, SubkeyName);
      If SubkeyExists Then
        RootKey := HKEY_LOCAL_MACHINE;
      End;
    If SubkeyExists Then
      Begin
      LatestVersion := '0';
      If RegGetSubkeyNames(RootKey, SubkeyName, SubkeyNames) Then
        Begin
        For J := 0 To GetArrayLength(SubkeyNames) - 1 Do
          Begin
          If CompareVersions(SubkeyNames[J], LatestVersion) > 0 Then
            LatestVersion := SubkeyNames[J];
          End;
        If RegQueryStringValue(RootKey, SubkeyName + '\' + LatestVersion, 'RuntimeLib', Result) Then
          Break;
        End;
      End;
    End;
  If Result = '' Then
    Begin
    // Registry search failed; try environment variables
    SetArrayLength(StringList, 2);
    StringList[0] := 'JAVA_HOME';
    StringList[1] := 'JRE_HOME';
    For I := 0 To GetArrayLength(StringList) - 1 Do
      Begin
      EnvHome := Trim(RemoveBackslashUnlessRoot(GetEnv(StringList[I])));
      If (EnvHome <> '') And DirExists(EnvHome) Then
        Result := FindFile(EnvHome, 'jvm.dll');
      If Result <> '' Then
        Break;
      End;
    End;
  End;

// Removes whitespace from a string
Function RemoveWhitespace(S: String): String;
  Var
    WS: TArrayOfString;
    I: Integer;
  Begin
  SetArrayLength(WS, 2);
  WS[0] := #9;
  WS[1] := ' ';
  For I := 0 To GetArrayLength(WS) - 1 Do
    StringChangeEx(S, WS[I], '', True);
  Result := S;
  End;

Function InitializeSetup(): Boolean;
  Begin
  Result := True;
  // Instance name
  ArgInstance := Trim(ExpandConstant('{param:instance|{#DefaultInstance}}'));
  // JVM path (if unspecified, search)
  ArgJVMPath := Trim(ExpandConstant('{param:jvmpath}'));
  If ArgJVMPath = '' Then
    ArgJVMPath := Trim(FindJVM());
  // Service name (if unspecified, default depends on instance name)
  ArgServiceName := Trim(ExpandConstant('{param:servicename}'));
  If ArgServiceName = '' Then
    Begin
    If CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 Then
      ArgServiceName := ExpandConstant('{#DefaultServiceName}')
    Else
      ArgServiceName := ExpandConstant('{#DefaultServiceName}-') + RemoveWhitespace(ArgInstance);
    End;
  // Service display name (if unspecified, default depends on instance name)
  ArgServiceDisplayName := Trim(ExpandConstant('{param:servicedisplayname}'));
  If ArgServiceDisplayName = '' Then
    Begin
    If CompareText(ArgInstance, ExpandConstant('{#DefaultInstance}')) = 0 Then
      ArgServiceDisplayName := ExpandConstant('{#DefaultServiceDisplayName}')
    Else
      ArgServiceDisplayName := ExpandConstant('{#DefaultServiceDisplayName} - ') + ArgInstance;
    End;
  // Service username
  ArgServiceUserName := Trim(ExpandConstant('{param:serviceusername|{#DefaultServiceUserName}}'));
  // JVM options
  ArgJVMOptions := Trim(ExpandConstant('{param:jvmoptions}'));
  // Memory settings
  ArgJVMMS := Trim(ExpandConstant('{param:jvmms|{#DefaultJVMMS}}'));
  ArgJVMMX := Trim(ExpandConstant('{param:jvmmx|{#DefaultJVMMX}}'));
  End;

Procedure InitializeWizard();
  Begin
  // Add custom jvm.dll selection page
  JVMPage := CreateInputFilePage(wpSelectTasks, CustomMessage('JVMPageCaption'), CustomMessage('JVMPageDescription'), CustomMessage('JVMPageSubCaption'));
  JVMPage.Add(CustomMessage('JVMPagePathItemCaption'), 'DLL files|*.dll', '');
  JVMPage.Values[0] := ArgJVMPath;
  // Add custom service configuration page
  ServicePage := CreateInputQueryPage(JvmPage.ID, CustomMessage('ServicePageCaption'), CustomMessage('ServicePageDescription'), CustomMessage('ServicePageSubCaption'));
  ServicePage.Add(CustomMessage('ServicePageServiceNameItemCaption'), False);
  ServicePage.Values[0] := ArgServiceName;
  ServicePage.Add(CustomMessage('ServicePageServiceDisplayNameItemCaption'), False);
  ServicePage.Values[1] := ArgServiceDisplayName;
  ServicePage.Add(CustomMessage('ServicePageServiceUserNameItemCaption'), False);
  ServicePage.Values[2] := ArgServiceUserName;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMOptionsItemCaption'), False);
  ServicePage.Values[3] := ArgJVMOptions;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMMSItemCaption'), False);
  ServicePage.Values[4] := ArgJVMMS;
  ServicePage.Add(CustomMessage('ServicePageServiceJVMMXItemCaption'), False);
  ServicePage.Values[5] := ArgJVMMX;
  End;

Function ShouldSkipPage(PageID: Integer): Boolean;
  Begin
  // Skip service configuration page if not installing service
  Result := False;
  If PageID = ServicePage.ID Then
    Result := Not WizardIsTaskSelected('installservice');
  End;

Function NextButtonClick(CurPageID: Integer): Boolean;
  Var
    I, ID, Value: Integer;
    ControlValues: TArrayOfString;
    Controls: TArrayOfInteger;
  Begin
  Result := True;
  If CurPageID = JVMPage.ID Then
    Begin
    // Ensure that filename is specified and exists
    Result := Trim(JVMPage.Values[0]) <> '';
    If Not Result Then
      Begin
      Log(CustomMessage('ErrorJVMPathEmptyLogMessage'));
      If Not WizardSilent() Then
        Begin
        MsgBox(CustomMessage('ErrorJVMPathEmptyGUIMessage'), mbError, MB_OK);
        JVMPage.Values[0] := FindJVM();
        WizardForm.ActiveControl := JVMPage.Edits[0];
        JVMPage.Edits[0].SelectAll();
        End;
      Exit;
      End;
    Result := FileExists(Trim(JVMPage.Values[0]));
    If Not Result Then
      Begin
      Log(FmtMessage(CustomMessage('ErrorJVMPathFileNotFoundLogMessage'), [Trim(JVMPage.Values[0])]));
      If Not WizardSilent() Then
        Begin
        MsgBox(CustomMessage('ErrorJVMPathFileNotFoundGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := JVMPage.Edits[0];
        JVMPage.Edits[0].SelectAll();
        End;
      Exit;
      End;
    ArgJVMPath := Trim(JVMPage.Values[0]);
    End
  Else If CurPageID = ServicePage.ID Then
    Begin
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
    For I := 0 To GetArrayLength(Controls) - 1 Do
      Begin
      ID := Controls[I];
      Result := Trim(ServicePage.Values[ID]) <> '';
      If Not Result Then
        Begin
        Log(FmtMessage(CustomMessage('ErrorServiceConfigValueMissingLogMessage'), [ServicePage.PromptLabels[ID].Caption]));
        If Not WizardSilent() Then
          Begin
          MsgBox(CustomMessage('ErrorServiceConfigValueMissingGUIMessage'), mbError, MB_OK);
          ServicePage.Values[ID] := ControlValues[ID];
          WizardForm.ActiveControl := ServicePage.Edits[ID];
          ServicePage.Edits[ID].SelectAll();
          End;
        Exit;
        End;
      End;
    // Validate service does not exist
    ID := Controls[0];
    Result := Not ServiceExists(Trim(ServicePage.Values[ID]));
    If Not Result Then
      Begin
      Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceAlreadyExistsLogMessage'), [Trim(ServicePage.Values[ID])]));
      If Not WizardSilent() Then
        Begin
        MsgBox(CustomMessage('ErrorServiceConfigServiceAlreadyExistsGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := ServicePage.Edits[ID];
        ServicePage.Edits[ID].SelectAll();
        End;
      Exit;
      End;
    // Validate service name does not contain whitespace
    ID := Controls[0];
    Result := (Pos(' ', Trim(ServicePage.Values[ID])) = 0) And (Pos(#9, Trim(ServicePage.Values[ID])) = 0);
    If Not Result Then
      Begin
      Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceNameLogMessage'), [Trim(ServicePage.Values[ID])]));
      If Not WizardSilent() Then
        Begin
        MsgBox(CustomMessage('ErrorServiceConfigServiceNameGUIMessage'), mbError, MB_OK);
        WizardForm.ActiveControl := ServicePage.Edits[ID];
        ServicePage.Edits[ID].SelectAll();
        End;
      Exit;
      End;
    // Specify which controls require non-zero values
    SetArrayLength(Controls, 2);
    Controls[0] := 4;
    Controls[1] := 5;
    For I := 0 To GetArrayLength(Controls) - 1 Do
      Begin
      ID := Controls[I];
      Value := StrToIntDef(Trim(ServicePage.Values[ID]), 0);
      Result := Value > 0;
      If Not Result Then
        Begin
        Log(FmtMessage(CustomMessage('ErrorServiceConfigServiceMemoryLogMessage'), [Trim(ServicePage.Values[ID]), ServicePage.PromptLabels[ID].Caption]));
        If Not WizardSilent() Then
          Begin
          MsgBox(CustomMessage('ErrorServiceConfigServiceMemoryGUIMessage'), mbError, MB_OK);
          ServicePage.Values[ID] := ControlValues[ID];
          WizardForm.ActiveControl := ServicePage.Edits[ID];
          ServicePage.Edits[ID].SelectAll();
          End;
        Exit;
        End;
      End;
    ArgServiceName := Trim(ServicePage.Values[0]);
    ArgServiceDisplayName := Trim(ServicePage.Values[1]);
    ArgServiceUserName := Trim(ServicePage.Values[2]);
    ArgJVMOptions := Trim(ServicePage.Values[3]);
    ArgJVMMS := Trim(ServicePage.Values[4]);
    ArgJVMMX := Trim(ServicePage.Values[5]);
    End;
  End;

Function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
  Var
    S: String;
  Begin
  S := '';
  If MemoUserInfoInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoUserInfoInfo;
    End;
  If MemoDirInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoDirInfo;
    End;
  If MemoTypeInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoTypeInfo;
    End;
  If MemoComponentsInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoComponentsInfo;
    End;
  If MemoGroupInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoGroupInfo;
    End;
  If MemoTasksInfo <> '' Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + MemoTasksInfo;
    End;
  // List path of jvm.dll file
  If S <> '' Then
    S := S + NewLine + NewLine;
  S := S + CustomMessage('ReadyMemoJVMPathInfo') + NewLine
    + Space + ArgJVMPath;
  // If installing service, list service configuration information
  If WizardIsTaskSelected('installservice') Then
    Begin
    If S <> '' Then
      S := S + NewLine + NewLine;
    S := S + CustomMessage('ReadyMemoServiceConfigInfo') + NewLine
      + Space + CustomMessage('ReadyMemoServiceNameInfo') + ' ' + ArgServiceName + NewLine
      + Space + CustomMessage('ReadyMemoServiceDisplayNameInfo') + ' ' + ArgServiceDisplayName + NewLine
      + Space + CustomMessage('ReadyMemoServiceUserNameInfo') + ' ' + ArgServiceUserName + NewLine;
    If ArgJVMOptions <> '' Then
      S := S + Space + CustomMessage('ReadyMemoServiceJVMOptionsInfo') + ' ' + ArgJVMOptions + NewLine;
    S := S + Space + CustomMessage('ReadyMemoServiceJVMMSInfo') + ' ' + ArgJVMMS + 'MB' + NewLine
      + Space + CustomMessage('ReadyMemoServiceJVMMXInfo') + ' ' + ArgJVMMX + 'MB';
    End;
  Result := S;
  End;

Procedure InstallService();
  Var
    Executable, StartupMode, Params, ErrorMessage: String;
    ResultCode: Integer;
  Begin
  Executable := ExpandConstant('{app}\bin\tomcat.exe');
  If WizardIsTaskSelected('installservice/setautostart') Then
    StartupMode := 'auto'
  Else
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
  If ArgJVMOptions <> '' Then
    Params := Params
      + ';' + ArgJVMOptions;
  Params := Params + '"'
    + ' --JvmOptions9 "--add-opens=java.base/java.lang=ALL-UNNAMED#'
    +     '--add-opens=java.base/java.io=ALL-UNNAMED#'
    +     '--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"'
    + ' --JvmMs ' + ArgJVMMS
    + ' --JvmMx ' + ArgJVMMX;
  Log(FmtMessage(CustomMessage('ServiceInstallCommandLogMessage'), [Executable, Params]));
  If (Not Exec(Executable, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode)) Or (ResultCode <> 0) Then
    Begin
    ErrorMessage := SysErrorMessage(ResultCode);
    Log(FmtMessage(CustomMessage('ErrorServiceInstallLogMessage'), [ArgServiceName, IntToStr(ResultCode), ErrorMessage]));
    If Not WizardSilent() Then
      MsgBox(FmtMessage(CustomMessage('ErrorServiceInstallGUIMessage'), [IntToStr(ResultCode), ErrorMessage]), mbCriticalError, MB_OK);
    End
  Else
    Log(CustomMessage('ServiceInstallCommandSucceededLogMessage'));
  End;

Procedure CurStepChanged(CurStep: TSetupStep);
  Begin
  If CurStep = ssInstall Then
    Begin
    Log(FmtMessage(CustomMessage('JVMPathLogMessage'), [ArgJVMPath]));
    Log(FmtMessage(CustomMessage('JVMImageTypeLogMessage'), [GetJVMImageType()]));
    End
  Else If CurStep = ssPostInstall Then
    Begin
    If WizardIsTaskSelected('installservice') Then
      InstallService();
    End;
  End;

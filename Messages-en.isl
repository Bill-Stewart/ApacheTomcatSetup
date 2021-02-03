#preproc ispp

; Bill Stewart's Apache Tomcat Setup - Inno Setup messages file

#include AddBackslash(SourcePath) + "includes.iss"

[Messages]
SetupWindowTitle={#SetupAuthor}'s %1 Setup [{#AppFullVersion}]
WelcomeLabel1=Welcome to {#SetupAuthor}'s [name] Setup Wizard
FinishedHeadingLabel=Completing {#SetupAuthor}'s [name] Setup Wizard
FinishedLabel=Setup has finished installing [name] on your computer.

[CustomMessages]

; Types
TypesDefaultDescription=Default installation
TypesCoreDescription=Core only
TypesFullDescription=Full installation
TypesCustomDescription=Custom installation

; Components
ComponentsCoreDescription={#AppName} core
ComponentsWebAppsDescription=Web applications
ComponentsWebAppsDocsDescription=Documentation bundle
ComponentsWebAppsManagerDescription=Manager application
ComponentsWebAppsHostManagerDescription=Host Manager application
ComponentsWebAppsExamplesDescription=Example applications

; Icons
IconsHomePageComment=Opens the {#AppName} home page.
IconsServiceConfigureComment=Configures an {#AppName} Windows service.
IconsServiceMonitorComment=Monitors an {#AppName} Windows service.
IconsDocsComment=Opens the {#AppName} documentation home page.

; Tasks
TasksServiceGroupDescription=Windows service tasks:
TasksServiceInstallDescription=&Install Windows service
TasksServiceSetPermissionsDescription=&Set file system permissions for service user account
TasksServiceSetAutoStartDescription=&Automatically start service when computer starts
TasksServiceStartMonitorAtLogonDescription=&Create shortcut to start the service monitor at logon
TasksOtherGroupDescription=Other tasks:
TasksOtherBackupConfDescription=Bac&k up conf directory before installation

; Run
RunSetPermissionsStatusMsg=Setting file system permissions...
RunPostInstallServiceConfigureDescription=Configure {#AppName} Service

; ReadyMemo info
ReadyMemoJVMInfo=Java Virtual Machine:
ReadyMemoJVMPath=Path:
ReadyMemoJVMVersion=File version:
ReadyMemoJVMPlatform=Platform:
ReadyMemoServiceConfigInfo=Service configuration options:
ReadyMemoServiceNameInfo=Service name:
ReadyMemoServiceDisplayNameInfo=Service display name:
ReadyMemoServiceUserNameInfo=Service user name:
ReadyMemoServiceJVMOptionsInfo=Additional JVM options:
ReadyMemoServiceJVMMSInfo=Initial memory pool size:
ReadyMemoServiceJVMMXInfo=Maximum memory pool size:

; JVM page
JVMPageCaption=Select Java Virtual Machine
JVMPageDescription=Which Java Virtual Machine (JVM) do you want {#AppName} to use?
JVMPageSubCaption={#AppName} service installation requires a Java Virtual Machine (JVM). Specify the path to the jvm.dll file, then click Next.
JVMPagePathItemCaption=&Path to jvm.dll file (required):

; Service configuration page
ServicePageCaption=Select Service Configuration Options
ServicePageDescription=How should the service be configured?
ServicePageSubCaption=Specify the service configuration options, then click Next.
ServicePageServiceNameItemCaption=Service n&ame (required):
ServicePageServiceDisplayNameItemCaption=Service &display name (required):
ServicePageServiceUserNameItemCaption=Start service using the following &user (required):
ServicePageServiceJVMOptionsItemCaption=Semicolon-delimited list of additional JVM &options (optional):
ServicePageServiceJVMMSItemCaption=Initial memory pool &size, in megabytes (required):
ServicePageServiceJVMMXItemCaption=Ma&ximum memory pool size, in megabytes (required):

; Service installation
ServiceInstallCommandLogMessage=INFO: Service installation command - "%1" %2
ServiceInstallCommandSucceededLogMessage=INFO: Service installation command executed successfully

; Installation
JVMPathLogMessage=INFO: JVM path - "%1"
JVMVersionLogMessage=INFO: jvm.dll file version - %1
JVMImageTypeLogMessage=INFO: jvm.dll image type - %1 (if unknown, assume 32-bit)

; Running application/service messages
ApplicationsRunningLogMessage=Applications are using files that need to be updated by Setup.
ApplicationsRunningInstructionMessage=Running Applications Detected
ApplicationsRunningTextMessage=The following applications and/or services are using files that need to be updated by Setup:%n%n%1%n%nSetup cannot continue unless you close the applications. If you continue, Setup will attempt to restart the services after the installation has completed.
CloseApplicationsMessage=&Close the applications and continue Setup
DontCloseApplicationsMessage=&Do not close the applications
ApplicationsStillRunningMessage=Applications are still using files that need to be updated by Setup.
RunCommandMessage=Run command: "%1" %2
ClosedApplicationsMessage=Stopped running service(s) and closed running application(s).
StartedServicesMessage=Service restart command(s) executed successfully.

; Application progress page
AppProgressPageInstallingCaption=Please wait while Setup installs %1 on your computer.
AppProgressPageStoppingMessage=Stopping applications...
AppProgressPageStartingMessage=Restarting stopped services...

; Error messages
ErrorJVMPathEmptyLogMessage=ERROR: Unable to find jvm.dll file
ErrorJVMPathEmptyGUIMessage={#AppName} service installation requires a Java Virtual Machine (JVM).%n%nYou must specify the path to the jvm.dll file in order to complete the installation.
ErrorJVMPathFileNotFoundLogMessage=ERROR: The system cannot find the file specified - "%1"
ErrorJVMPathFileNotFoundGUIMessage=The system cannot find the file specified.%n%nYou must specify the path to the jvm.dll file in order to complete the installation.
ErrorJVMOldLogMessage=jvm.dll version %1 detected; must be at least version %2
ErrorJVMOldGUIMessage=The selected jvm.dll file is version %1, but {#AppName} requires at least Java %2.%n%nYou must select a jvm.dll file that meets the minimum version requirement.
ErrorServiceConfigValueMissingLogMessage=ERROR: No value specified for the "%1" Windows service configuration option
ErrorServiceConfigValueMissingGUIMessage=Please specify a value.
ErrorServiceConfigServiceAlreadyExistsLogMessage=The specified service already exists - "%1"
ErrorServiceConfigServiceAlreadyExistsGUIMessage=The specified service already exists.%n%nPlease specify a different name.
ErrorServiceConfigServiceNameLogMessage=ERROR: Service name "%1" not valid because it contains whitespace
ErrorServiceConfigServiceNameGUIMessage=The specified service name is not valid because it contains whitespace.%n%nPlease specify a different name.
ErrorServiceConfigServiceMemoryLogMessage=ERROR: Invalid value "%1" specified for the "%2" Windows service configuration option
ErrorServiceConfigServiceMemoryGUIMessage=Please specify a value greater than 0.
ErrorServiceInstallLogMessage=ERROR: Service "%1" failed to install with error code %2 (%3)
ErrorServiceInstallGUIMessage=The service failed to install.%n%nError code: %1%n%n%2

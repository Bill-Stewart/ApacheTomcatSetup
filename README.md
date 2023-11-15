<!-- omit in toc -->
# Bill Stewart's Apache Tomcat Setup for Windows

This [Apache Tomcat](https://tomcat.apache.org/) installer (referred to herein as Setup) is publicly available thanks to permission from the [Apache Tomcat Project Management Committee (PMC)](https://projects.apache.org/committee.html?tomcat). If you build a custom version of this installer, you cannot redistribute it publicly without permission from the Apache Tomcat PMC. Please see the [Apache Tomcat Legal Page](https://tomcat.apache.org/legal.html) for more information.

-------------------------------------------------------------------------------

<!-- omit in toc -->
# Table of Contents

- [Background](#background)
- [Download](#download)
- [Upgrading from the ASF Installer](#upgrading-from-the-asf-installer)
- [Reinstalling or Upgrading](#reinstalling-or-upgrading)
- [Setup Command Line Parameters](#setup-command-line-parameters)
  - [Common Command Line Parameters](#common-command-line-parameters)
  - [Windows Service Installation Command Line Parameters](#windows-service-installation-command-line-parameters)
  - [Instance Name Defaults](#instance-name-defaults)
  - [Other Command Line Parameters](#other-command-line-parameters)
- [Administrative vs. Non-administrative Installation Mode](#administrative-vs-non-administrative-installation-mode)
- [Installing Separate Instances](#installing-separate-instances)
- [Setup Type and Components](#setup-type-and-components)
- [Setup Tasks](#setup-tasks)
  - [Setting File System Permissions](#setting-file-system-permissions)
  - [Backing Up the `conf` Directory](#backing-up-the-conf-directory)
- [Finding the jvm.dll File](#finding-the-jvmdll-file)
- [Uninstalling Apache Tomcat](#uninstalling-apache-tomcat)
- [Setup Limitations](#setup-limitations)
- [Sample Command Line Parameters](#sample-command-line-parameters)
- [Acknowledgments](#acknowledgments)

---

# Background

I wrote this [Inno Setup](https://www.jrsoftware.org/isinfo.php) installer because I needed more functionality than was provided by the Apache Software Foundation (ASF) 32-bit/64-bit Windows service installer, which was built using [NSIS](https://nsis.sourceforge.io/). Specifically:

* The ASF installer doesn't provide an easy way to upgrade a Tomcat installation. Using the ASF installer, an upgrade consists of uninstall, click `No` when it asks if you want to delete all the files (a dangerous question), then install the new version using the same options (hopefully you documented your settings). If you installed the service, you will need to reconfigure that as well. If you run the service using a specific account, you will need to specify it again and re-enter the credentials (because the uninstall deleted the service). Java runtime parameters (such as memory sizes, JVM options, etc.) must also be reconfigured.

* The [installer-specific documentation](https://tomcat.apache.org/tomcat-9.0-doc/setup.html#Windows) is quite brief, and it doesn't mention some very peculiar command line parsing rules (e.g., the `/D=` command line option must be UPPER CASE and must not be quoted on the command line, even if the target directory name contains whitespace). The configuration options for a silent installation must sit in a text-based configuration file, and some notable Windows service configuration options are missing (service user account, etc.).

* The ASF installer doesn't set file system permissions for the service user account to actually be able to run any web applications because it doesn't have a way to specify the service user account name. This is a peculiar state of affairs when installing the Windows service: The service gets installed, but unless you run the service using the local system or an administrative account (not recommended), web applications won't work because the service user account doesn't have permission to write to the `logs`, `temp`, and `work` directories.

This custom Apache Tomcat Setup installer rectifies these limitations.

# Download

You can download the latest version from the Github Releases page:

https://github.com/Bill-Stewart/ApacheTomcatSetup/releases/

# Upgrading from the ASF Installer

Setup does not upgrade Tomcat if it was installed by the Apache Software Foundation **32-bit/64-bit Windows Service Installer** package. To perform an upgrade if Tomcat was installed using the ASF installer, you must perform the following steps:

1. Make a backup of all customized files

2. If the ASF installer installed a Tomcat service:

   a. Document any customized service settings (e.g. memory settings, custom command-line options, etc.)

   b. Stop the service

3. Uninstall it using the standard Windows application management list

4. Install Tomcat using Setup

5. Restore customized files

6. If using the service: Add back any customized service settings

After successfully installing Tomcat using Setup, upgrades no longer require the above steps.

# Reinstalling or Upgrading

Please note the following when using Setup to reinstall or upgrade Apache Tomcat:

* If the Windows service is installed, Setup automatically stops the service, upgrades the binaries, and restarts the service. All service installation details are retained when reinstalling or upgrading.

* Obsolete files in the included web applications are not removed when upgrading. It is the Tomcat administrator's responsibility to manually manage the web application files in the `webapps` directory.

* If a file that Setup is installing is both different and has an older timestamp than a file in the `conf` directory, Setup will prompt whether you want to keep or overwrite the file. The `Keep the existing file` option (recommended) is the default if you use the `/suppressmsgboxes` parameter (see [Setup Command Line Parameters](#setup-command-line-parameters)).

  > NOTE: Setup provides this prompt as a safeguard to prevent accidental overwriting of customized configuration files. If you are certain you want to overwrite all files without prompting, specify the `/forceoverwritefiles` parameter (not recommended unless you are **absolutely sure** you want to overwrite all files).

* Setup will not overwrite files in the `conf` directory that have a newer timestamp than the same file(s) it installs. You can prevent overwriting of customized files in the `conf` directory by updating the timestamp of customized files (e.g., open and save or use a "touch" utility) **before** a reinstall or upgrade.

# Setup Command Line Parameters

## Common Command Line Parameters

| Parameter                       | Description
| ---------                       | -----------
`/currentuser`                    | Runs Setup in non-administrative installation mode (not recommended). See [Administrative vs. Non-administrative Installation Mode](#administrative-vs-non-administrative-installation-mode).
`/instancename="`_name_`"`        | Runs Setup to install a separate instance of Apache Tomcat. See [Installing Separate Instances](#installing-separate-instances).
`/dir="`_location_`"`             | Specifies the installation directory. The default location is _d_`:\Program Files\Apache Tomcat` (where _d_`:` is the Windows system partition).
`/type=`_type_                    | Specifies the installation type. See [Setup Type and Components](#setup-type-and-components).
`/components="`_componentlist_`"` | Specifies the components Setup should install. See [Setup Type and Components](#setup-type-and-components).
`/group="`_name_`"`               | Specifies the Start Menu group name. The default group name is `Apache Tomcat`.
`/noicons`                        | Prevents creation of a Start Menu group.
`/tasks="`_tasklist_`"`           | Specifies the tasks Setup should perform. See [Setup Tasks](#setup-tasks).
`/jvmpath="`_location_`"`         | Specifies the path and filename of the `jvm.dll` file. See [Finding the jvm.dll File](#finding-the-jvmdll-file).
`/silent`                         | Runs Setup silently (i.e., without user interaction). For a fully hands-free installation when upgrading, it is recommended to also specify the `/closeapplications` parameter (see below).
`/closeapplications`              | Setup should automatically stop running services and applications before installing and restart services after installation. (If you omit this parameter and one or more Tomcat services and/or applications are running, Setup will prompt interactively to close them before continuing.)
`/suppressmsgboxes`               | Suppresses message boxes and uses a default answer. This parameter is recommended for silent installations.
`/log="`_filename_`"`             | Logs Setup activity to the specified file. The default is not to create a log file.
`/forceoverwritefiles`            | Overwrites all files in the `conf` directory that are different and newer without prompting (not recommended).

## Windows Service Installation Command Line Parameters

The following command line parameters set the default values for the text boxes on the **Select Service Configuration Options** page and are applicable only when installing the Windows service for the first time:

| Parameter                             | Description
| ---------                             | -----------
`/servicename=`_name_                   | Specifies the Windows service name. This name cannot contain whitespace. The default is `Tomcat`.
`/servicedisplayname="`_displayname_`"` | Specifies the Windows service display name. The default is `Apache Tomcat`.
`/serviceusername="`_username_`"`       | Specifies the name of the user account that will run the Windows service. The default is `NT AUTHORITY\Local Service`. For a local account, specify `.\`_username_. For a domain account, specify _domainname_`\`_username_.
`/jvmoptions="`_options_`"`             | Specifies a semicolon-delimited list of additional JVM (Java Virtual Machine) options.
`/jvmms=`_size_                         | Specifies the initial memory pool size, in megabytes. The default size is `256`.
`/jvmmx=`_size_                         | Specifies the maximum memory pool size, in megabytes. The default size is `256`.

If the service user account requires a password, you must enter its password in the service configuration dialog after Setup completes.

> **IMPORTANT**: It is **not recommended** to run the service using an administrative account or the `LocalSystem` account.

## Instance Name Defaults

If you install a separate instance (see [Installing Separate Instances](#installing-separate-instances)), the default values of the `/dir`, `/group`, `/servicename`, and `/servicedisplayname` parameters will include the instance name. For example, if you specify `/instancename="XWiki"`, the following will be defaults:

* `/dir="`_d_`:\Program Files\Apache Tomcat - XWiki"`
* `/group="Apache Tomcat - XWiki"`
* `/servicename=Tomcat-XWiki`
* `/servicedisplayname="Apache Tomcat - XWiki"`

## Other Command Line Parameters

Setup is built using [Inno Setup](https://www.jrsoftware.org/isinfo.php), so it supports the command line parameters common to all Inno Setup installers. Run Setup with the `/?` parameter for more details.

# Administrative vs. Non-administrative Installation Mode

Setup supports both administrative and non-administrative installation modes:

* In administrative installation mode (the default), Setup installs Apache Tomcat for all users of the computer and allows installation of the Windows service.

* In non-administrative installation mode (not recommended), Setup installs Apache Tomcat in the current user's profile. To run Setup in non-administrative installation mode, you must specify the `/currentuser` parameter on Setup's command line. You cannot install the Windows service using non-administrative installation mode.

# Installing Separate Instances

An _instance_ is an independent installation of Apache Tomcat in a separate location. You can use the `/instancename` command line parameter to install multiple Apache Tomcat services on the same computer, or if you need to run separate specific versions of Apache Tomcat.

If you install multiple instances, each installation is considered as a separate application. Each instance will appear as a separate entry in the installed application list in Windows. Each instance must be upgraded, reinstalled, or uninstalled separately. (That is, a reinstall, upgrade, or uninstall of a specific instance affects only that instance.)

# Setup Type and Components

Setup's **Select Components** page allows selection of the setup type and components.

The setup _type_ corresponds to the drop-down list on the **Select Components** page. Changing the drop-down list selection changes the selected components. The types are as follows:

| Type               | Name      | Components Selected
| ----               | ----      | -------------------
Default installation | `default` | `core,webapps/docs,webapps/manager`
Core only            | `core`    | `core`
Full installation    | `full`    | Selects all components
Custom installation  | `custom`  | Selects a custom list of components

The `/type` command line parameter specifies a default setup type; e.g. `/type=core` specifies that **Core only** should be the default type.

The default is `/type=default`.

The _components_ correspond to the checkboxes that represent individual components. The components are as follows:

| Component              | Name                  | Notes
| ---------              | ----                  | -----
Apache Tomcat core       | `core`                | Always selected
Web applications         | `webapps`             | Can't be selected alone
Documentation bundle     | `webapps/docs`        |
Manager application      | `webapps/manager`     |
Host Manager application | `webapps/hostmanager` |
Examples                 | `webapps/examples`    |

The `core` component consists of the Apache Tomcat binaries and `jar` files.

The `/components` command line parameter is a comma-delimited list of components that should be selected by default. For example, `/components="core,webapps/docs"` selects the `core` and `webapps/docs` components by default. (This is equivalent to `/components="webapps/docs"` because the `core` component is always selected.)

The default is `/components="core,webapps/docs,webapps/manager"`.

# Setup Tasks

Setup's **Select Additional Tasks** page provides a list of additional tasks that Setup should perform:

Task                                                  | Name                                 | Notes
----                                                  | ----                                 | -----
Install Windows service                               | `installservice`                     |
Set file system permissions for service user account  | `installservice/setpermissions`      | See [Setting File System Permissions](#setting-file-system-permissions)
Automatically start service when computer starts      | `installservice/setautostart`        |
Create shortcut to start the service monitor at logon | `installservice/startmonitoratlogon` |
Back up conf directory before installation            | `backupconf`                         | See [Backing Up the `conf` Directory](#backing-up-the-conf-directory)

The `/tasks` parameter specifies which tasks are selected by default. Specifying an `installservice` subtask implies the `installservice` task (that is, `/tasks="installservice/setautostart"` is equivalent to `/tasks="installservice,installservice/setautostart"`).

The default is `/tasks="installservice/setpermissions,installservice/setautostart,backupconf"`.

## Setting File System Permissions

The `installservice/setpermissions` task grants file system permissions to the account used to run the service, as follows:

* Apache Tomcat installation directory and subdirectories: Read-only

* `conf\Catalina\localhost`, `logs`, `temp`, and `work` directories: Modify

Web applications can start successfully with these minimum permissions.

If the service user account is not found, the permission changes will fail silently. In this case, you will need to grant the permissions manually.

> **IMPORTANT**: You may need to change the permissions on one or more of the directories and/or files to properly secure the Apache Tomcat application. (For example, if you use SSL, you will most likely want to restrict access to the certificate's private key file.)

## Backing Up the `conf` Directory

The `backupconf` task makes a backup copy of the `conf` directory if it exists (i.e., when reinstalling or upgrading). The backup directory will be named `conf-backup-`_time_ (where _time_ is the date and time the backup was created).

# Finding the jvm.dll File

Apache Tomcat requires a Java Virtual Machine (JVM), so Setup needs to know the location of the `jvm.dll` file if you are installing the service. Setup attempts to find it automatically in the following ways:

1. It checks for the presence of the `JAVA_HOME`, `JDK_HOME`, and `JRE_HOME` environment variables (in that order). The value of the environment variable is the Java home directory.

2. If the environment variables noted above are not defined, Setup searches the directories named in the `Path` environment variable for `java.exe`. The Java home directory is the parent directory of the directory where `java.exe` is found. For example, if `C:\Program Files\Eclipse Adoptium\JRE11\bin` is in the path (and `java.exe` is in that directory), the Java home directory is `C:\Program Files\Eclipse Adoptium\JRE11`.

3. If `java.exe` is not found in the `Path`, Setup searches in the registry for the home directory of the latest Java version installed.

> NOTE: If you are running on a 64-bit version of Windows, Setup won't search the 32-bit portion of the registry if it finds any 64-bit versions of Java in the registry. This only applies to the registry search; if Setup finds a 32-bit installation of Java in the environment variables or `Path`, it will not search the registry.

If any of the above attempts to find the Java home directory succeed (in the above order), Setup looks for the `jvm.dll` file in the `\bin\server` and `\jre\bin\server` subdirectories of the Java home directory.

If you have Java installed but Setup fails to find it or the path to the `jvm.dll` file, you must specify the path to the `jvm.dll` file on the **Select Java Virtual Machine** page or by using the `/jvmpath` command line parameter.

Setup installs the 64-bit Apache Tomcat binaries if the `jvm.dll` file is 64-bit; otherwise, it installs the 32-bit Apache Tomcat binaries.

The file version of `jvm.dll` must be at least the minimum version required by the version of Tomcat you are installing. If the `jvm.dll` file version is older than the minimum version required by the version of Tomcat you are installing, Setup will not continue.

If Setup can't find the `jvm.dll` file, you can work around the problem by setting the `JAVA_HOME` environment variable to the Java home directory, and then running Setup again. In recent versions of Windows, you can add an environment variable by running the following command:

    rundll32 sysdm.cpl EditEnvironmentVariables

# Uninstalling Apache Tomcat

You can uninstall Apache Tomcat installed using Setup by using the standard Windows application management list. The uninstall process does not remove the `conf` directory or any files Setup did not install.

The uninstall program is located in the uninstall directory in the installation directory and is named `unins`_nnn_`.exe` (where _nnn_ is three digits, usually `000`). Some common uninstall command line parameters are the following:

| Parameter           | Description
| ---------           | -----------
`/silent`             | Runs the install silently (i.e., without user interaction).
`/log="`_filename_`"` | Logs uninstall activity to the specified file. The default is not to create a log file.

See the [Inno Setup](https://www.jrsoftware.org/isinfo.php) documentation for more uninstaller command line parameters.

# Setup Limitations

* Setup doesn't provide a way to configure server port (`server.xml`) or Manager web application (`tomcat-users.xml`) details (these items must be configured separately after installation).

* Setup does not provide the ability to uninstall an upgrade (i.e., downgrade). To downgrade, you must first uninstall the current version and then install the desired version. For this reason, it is recommended to keep the Setup programs of previous versions available just in case.

* Setup uses WMI (Windows Management Instrumentation) API calls to detect running services and applications. If you have stopped or disabled the WMI service (not recommended), Setup will not be able to detect running services and applications and will attempt to replace files that are in use. The only workaround in this case is to manually stop running Tomcat services and/or applications before reinstalling or upgrading.

# Sample Command Line Parameters

    /type=core
    /serviceusername="FABRIKAM\AppService"
    /jvmoptions="-Djavax.net.ssl.trustStoreType=WINDOWS-ROOT"
    /silent
    /closeapplications
    /suppressmsgboxes
    /log="C:\Users\KenDyer\Documents\ApacheTomcatSetup.log"

(All on one line)

These options perform a silent installation of Apache Tomcat. The service will run using the account `FABRIKAM\AppService` and will trust the Windows certificate store. Setup will log its activity to the specified log file.

# Acknowledgments

Special thanks to the following:

* Apache Software Foundation: For providing the [Apache Tomcat](https://tomcat.apache.org) software.

* The [Apache Tomcat Project Management Committee (PMC)](https://projects.apache.org/committee.html?tomcat): For granting permission to publicly distribute this Setup program with the copyrighted Apache Tomcat images.

* Jordan Russell and Martijn Laan: For making the excellent [Inno Setup](https://www.jrsoftware.org/isinfo.php) tool publicly available.

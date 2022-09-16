#Company: IT Ninjas Technology, LLC
#Tool_Name: Ninja Deploy v. 3.0 - Ninja RMM Deploy Tool
#Script_Name: Ninja Deploy - Google Drive
#Desc: NinjaRMM (NinjaOne) Silent Software Installer for Google Drive


#############################
##  APPLICATION VARIABLES  ##
#############################
$DeploymentSite = "https://YOUR_SITE_HERE.com/deploy";
$AppName = "Google_Drive";          $AppDir = "Google";          
$PackageHash = "";
$64bitPackage_URL = "https://dl.google.com/drive-file-stream/GoogleDrive.exe"
$64bitPackageName = "GoogleDrive.exe";
$32bitPackage_URL = "https://dl.google.com/drive-file-stream/GoogleDrive.exe"
$32bitPackageName = "GoogleDrive.exe";
$PSADTK_URI = "https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/3.8.4/PSAppDeployToolkit_v3.8.4.zip"; #RELEASE DATE: Jan 27, 2021
$PSADTK_FILE = "C:\ProgramData\NinjaRMMAgent\download\PSAppDeployToolkit\PSAppDeployToolkit_v3.8.4.zip";
$PSADTK_Dir = "C:\ProgramData\NinjaRMMAgent\download\PSAppDeployToolkit";

#############################
##   DEPLOYMENT VARIABLES  ##
#############################
$DeployTool = "Deploy-$AppName.ps1";       
$DeployTool_URL ="$DeploymentSite/$AppDir/$AppName/Deploy-$AppName.ps1";
$DeployDir = "C:\ProgramData\NinjaRMMAgent\download";
$LogsDir = "C:\ProgramData\NinjaRMMAgent\logs";     $TIMESTAMP = Get-Date -Format "MM/dd/yyyy HH:mm K";
$Logs = "C:\ProgramData\NinjaRMMAgent\logs\$AppName Deployment.log";


Write-Host "------------------------------------------------------------------------";


#PowerShell Deployment Tool Check
if(Get-Item -Path $PSADTK_FILE -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] PowerShell AppDeployment Toolkit Check: Ok" >> $Logs; Write-Host "[$TIMESTAMP] PowerShell AppDeployment Toolkit (PSADTK) Check: Ok"}
else {
     New-Item -Path "C:\ProgramData\NinjaRMMAgent\download\PSAppDeployToolkit" -ItemType "directory"; Write-Output "[$TIMESTAMP] PowerShell AppDeployment Toolkit (PSADTK) Check: Directory Created" >> $Logs; Write-Host "[$TIMESTAMP] PowerShell AppDeployment Toolkit (PSADTK) Check: Directory Created";

    (New-Object System.Net.WebClient).DownloadFile($PSADTK_URI,$PSADTK_FILE); Write-Output "[$TIMESTAMP] PowerShell AppDeployment Toolkit  (PSADTK) ZipFile Check: Downloaded File" >> $Logs; Write-Host "[$TIMESTAMP] PowerShell AppDeployment Toolkit  (PSADTK) ZipFile Check: Downloaded File";
    
    #Unblock PSADTK
    Unblock-File -Path $PSADTK_FILE; Write-Output "PowerShell AppDeployment Toolkit Unblock: Unblocked" >> $Logs; Write-Host "[$TIMESTAMP] PowerShell AppDeployment Toolkit Unblock: Unblocked";

    #Extract PSADTK
    Expand-Archive -Path $PSADTK_FILE -Destination $PSADTK_Dir -Force; Write-Output "[$TIMESTAMP] PowerShell AppDeployment Toolkit  (PSADTK) Extraction Check: Extracted Zip File" >> $Logs; Write-Host "[$TIMESTAMP] PowerShell AppDeployment Toolkit  (PSADTK) Extraction Check: Extracted Zip File";
}

#Application Directory Check
if (Get-Item -Path $DeployDir"\"$AppDir"\"$AppName -ErrorAction Ignore) {Write-Host $OkMsg ; Write-Output "[$TIMESTAMP] $AppName Directory Check: OK" >> $Logs; Write-Host "[$TIMESTAMP] $AppName Directory Check: OK";}
else {New-Item -Path $DeployDir"\"$AppDir"\"$AppName -ItemType "directory"; Write-Host $CreatedMsg; Write-Output "[$TIMESTAMP] $$AppName Directory Check: Directory Created" >> $Logs;}

#AppDeploymentToolkit
if (Get-Item -Path $DeployDir"\"$AppDir"\$AppName\AppDeployToolkit" -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] PSADTK Directory Check: OK" >> $Logs; Write-Host "[$TIMESTAMP] PSADTK Directory Check: OK";}
else {Copy-Item -Path $PSADTK_Dir"\Toolkit\AppDeployToolkit" -Destination $DeployDir"\"$AppDir"\"$AppName"\AppDeployToolkit" -Recurse;  Write-Output "[$TIMESTAMP] PSADTK Directory Check: Directory Created" >> $Logs; Write-Host  "[$TIMESTAMP] PSADTK Directory Check: Directory Created";}

# Files Directory
if (Get-Item -Path $DeployDir"\"$AppDir"\$AppName\Files" -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] PSADTK Files Directory Check: Ok">> $Logs; Write-Host  "[$TIMESTAMP] PSADTK Files Directory Check: Ok";}
else {Copy-Item -Path $PSADTK_Dir"\Toolkit\Files" -Destination $DeployDir"\"$AppDir"\$AppName\Files" -Recurse;  Write-Output "[$TIMESTAMP] PSADTK Files Directory Check: Directory Created">> $Logs;} 

#Download Correct Software version
if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit")
    { 
      if (Get-Item -Path $DeployDir"\"$AppDir"\$AppName\Files\"$64bitPackageName -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] $AppName 64bit File Check: Ok " >> $Logs;} 
      else {Invoke-WebRequest -Uri $64bitPackage_URL -Outfile $DeployDir"\"$AppDir"\$AppName\Files\"$64bitPackageName;  Write-Output "[$TIMESTAMP] $AppName 64bit File Check: Downloaded File " >> $Logs;} 
    }
else #Check if System is 32bit
    { 
        if(Get-Item -Path $DeployDir"\"$AppDir"\$AppName\Files\"$32bitPackageName -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] $AppName 32bit File Check: Ok ">> $Logs;} 
        else {Invoke-WebRequest -Uri $32bitPackage_URL -Outfile $DeployDir"\"$AppDir"\$AppName\Files\"$32bitPackageName; Write-Output "[$TIMESTAMP] $AppName 32bit File Check: Downloaded File " >> $Logs;} 
    }

#Check Deploy Script
if(Get-Item -Path $DeployDir"\"$AppDir"\$AppName\"$DeployTool -ErrorAction Ignore) {Write-Output "[$TIMESTAMP] $AppName Deployment Script Check: Ok " >>  $Logs;} 
else {Invoke-WebRequest -Uri $DeployTool_URL -Outfile $DeployDir"\"$AppDir"\$AppName\"$DeployTool; Write-Output "[$TIMESTAMP] $AppName Deployment Script Check: Downloaded File " >>  $Logs;}

Powershell.exe -ExecutionPolicy Bypass "C:\ProgramData\NinjaRMMAgent\download\$AppDir\$AppName\$DeployTool" -DeploymentType "Install" -DeployMode "Silent"
Write-Output "[$TIMESTAMP] $AppName Deployment Started" >>  $Logs;

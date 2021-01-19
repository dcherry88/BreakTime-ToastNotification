<#
    Simple script to do break reminders through the work day.

    Presents as Windows 10 Notification
    


#>
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
#Set your work hours here
$StartTime = '08:00'
$EndTime = '17:00'
#######################
$currentday = get-date -UFormat %A
$currentTime = Get-date -format "HH:mm"
if(($currentTime -gt $starttime) -and ($currentTime -lt $endtime) -and ($currentday -ne "Saturday") -and ($currentday -ne "Sunday")){
    # Register the AppID in the registry for use with the Action Center, if required
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    $App =  "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"

    # Creating registry entries if they don't exists
    if (-NOT(Test-Path -Path "$RegPath\$App")) {
        New-Item -Path "$RegPath\$App" -Force
        New-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter" -Value 1 -PropertyType "DWORD"
    }

    # Make sure the app used with the action center is enabled
    if ((Get-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter").ShowInActionCenter -ne "1")  {
        New-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter" -Value 1 -PropertyType "DWORD" -Force
    }



    [xml]$Toast = @"
<toast scenario="Reminder">
    <visual>
    <binding template="ToastGeneric">
        <text placement="attribution">Breaktime Reminder</text>
        <text></text>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" >It's time to take a break and stretch. Snooze for a few minutes to get a reminder then.</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
        <input id="snoozeTime" type="selection" title="Click Snooze to be reminded in:" defaultInput="5">
            <selection id="5" content="5 minutes"/>
            <selection id="15" content="15 minutes"/>
            <selection id="30" content="30 minutes"/>
        </input>
        <action activationType="system" arguments="dismiss" content="BREAK!" />
        <action activationType="system" arguments="snooze" hint-inputId="snoozeTime" content="Snooze"/>
    </actions>
</toast>
"@


    $Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

    # Load the notification into the required format
    $ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
    $ToastXml.LoadXml($Toast.OuterXml)
        
    # Display the toast notification

    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($App).Show($ToastXml)
}

#create manifest file

#Util functions

#ask the user for an input and then replace the options with values from the config
function get_user_input ([String] $message){
    $input = Read-Host -Prompt $message
    #$input = set_options -command $input
    return $input.trim()
}

     $manifest = "<?xml version='1.0'?>
<Scripts>
"
$scripts_location = get_user_input -message "Specify the scripts location"
$customer_code = get_user_input -message "Specify the customer code"
$qn_reported_version = get_user_input -message "QESTNET Version"
$pre_install_scripts = get_user_input -message "Should the scripts be run before the QN upgrade. By default the scripts are executed after the QN upgrade tool.?Y/N"
$scripts = get-childitem -Path $scripts_location -include *.sql -Recurse | Select-Object -ExpandProperty Name


foreach($script in $scripts){
    $uuid = [guid]::NewGuid().ToString()
    $manifest_attribute = "    <Script>
        <filename>$script</filename>
        <uuid>$uuid</uuid>
        <ReportedInQNVersion>$qn_reported_version</ReportedInQNVersion>
        <FixedInQNVersion></FixedInQNVersion>
        <IsPreInstallScript>$pre_install_scripts</IsPreInstallScript>
        <customers>$customer_code</customers>
        <version>1</version>
    </Script>
"
    $manifest = "$manifest$manifest_attribute"
}

$manifest = "$manifest
</Scripts>"

$manifest | Out-File "$scripts_location\manifest.xml"
get_user_input -message "Done, press enter to close"
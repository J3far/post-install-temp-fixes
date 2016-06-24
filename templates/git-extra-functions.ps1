#clear
clear-host

#globa variables

##################################### Import Configs ###################################
$myDir = Invoke-Expression "pwd"
$script:ConfigFile = New-Object XML
# Import email settings from config file
$script:ConfigFile.Load("manifest.xml")

##################################### Util functions ###################################
#get a value from a particular section on the config file based on the key
function get_scripts_for_customer([String]$customerCode){
    return ($script:ConfigFile.Scripts.Script|Where {$_.customers -like $customerCode}|select  @{L="filename";E={$_.filename}})
}
########################################################################################

get_scripts_for_customer -customerCode "All"

cd "/dev/qestnet.upgrade"
git branch

cd $myDir

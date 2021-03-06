#clear
clear-host

#globa variables

##################################### Import Configs ###################################
#valid commands
$commands = New-Object System.Collections.ArrayList
$commands.Add('cpip') >$null
$commands.Add('exit') >$null
$commands.Add('quit') >$null
$commands.Add('dir') >$null
$commands.Add('config') >$null
$commands.Add('clear') >$null

$script:myDir = Invoke-Expression "pwd"
$script:configFileName = "config.xml"
$script:ConfigFile = New-Object XML
$script:ConfigFile.Load($script:configFileName) # Import email settings from config file

$script:localRepository = $myDir
$script:localRepositoryName = ""
$script:remoteRepository = ""
$script:packageDestination = ""
$script:versionPrefix = "v"
$script:customerCode = ""
$script:targetQNVersion = ""
$script:interactiveMode = $true

##################################### Util functions ###################################
#get settings from the config file based on the tag name
function get_config_value([String] $name){
    return ($script:ConfigFile.Settings.$name)
}

function set_config_value([String] $name,[String] $value){
    $script:ConfigFile.Settings.$name = $value
}

#ask the user for an input and then replace the options with values from the config
function get_user_input ([String] $message){
    $input = Read-Host -Prompt $message
    #$input = set_options -command $input
    return $input.trim()
}

#get valid scripts details from the manifest file based on customer code
function get_scripts_descriptions([String]$manifest_location,[String]$customerCode,[decimal] $qnv){

        $toReturn = ""
        $manifest = New-Object XML
        $manifest.Load($manifest_location)

        $valid  = $manifest.Scripts.Script|Where-Object {$_.customers -ilike "*$customerCode*" -and $_.ReportedInQNVersion -le $qnv -and ($_.FixedInQNVersion -eq "" -or $_.FixedInQNVersion -gt $qnv)}
        
        foreach($script in $valid)
        {
            $txt = $script.OuterXml
            if([string]::IsNullOrEmpty($txt)){}else{
            $toReturn = 
"$toReturn
$txt
"}
        }
    return $toReturn
}

#get the valid scripts names based on the customer code
function get_post_install_scripts([String] $manifest_location,[String] $customerCode,[decimal] $qnv){
        $toReturn = ""
        $manifest = New-Object XML
        $manifest.Load($manifest_location)

        $valid  = $manifest.Scripts.Script|Where-Object {$_.customers -ilike "*$customerCode*" -and $_.ReportedInQNVersion -le $qnv -and ($_.FixedInQNVersion -eq "" -or $_.FixedInQNVersion -gt $qnv) -and $_.IsPreInstallScript -ilike "N*"}|Select-Object -ExpandProperty "filename"

        return $valid

}

#get the valid pre-install scripts names based on the customer code
function get_pre_install_scripts([String] $manifest_location,[String] $customerCode,[decimal] $qnv){
        $toReturn = ""
        $manifest = New-Object XML
        $manifest.Load($manifest_location)

        $valid  = $manifest.Scripts.Script|Where-Object {$_.customers -ilike "*$customerCode*" -and $_.ReportedInQNVersion -le $qnv -and ($_.FixedInQNVersion -eq "" -or $_.FixedInQNVersion -gt $qnv) -and $_.IsPreInstallScript -ilike "Y*"}|Select-Object -ExpandProperty "filename"

        return $valid

}

#
function get_branches_status(){

}

#create or update local repository
function create_or_update_local_repository([String] $pkgd){
    #remove local repository if exists
    $fileExists =  Test-Path $script:localRepository\$script:localRepositoryName
    if($fileExists -eq $false){
        #clone remote repository if does not exist
        $txt = git clone "$script:remoteRepository"
        #$txt = Remove-Item -path $script:localRepository\$script:localRepositoryName -Recurse -Force
     }

     #step into the repository
     cd $script:localRepositoryName

    #create the package dir if does not exist
    $fileExists = Test-Path $pkgd
    if($fileExists -eq $true){
        $txt = Remove-Item -path "$pkgd" -Recurse -Force
     }
     $txt = New-item -itemtype directory -path $pkgd
     $txt = New-item -itemtype directory -path "$pkgd\pre-install"
     $txt = New-item -itemtype directory -path "$pkgd\post-install"
     
     #just make sure local copy synced with remote copy
     $txt = git reset --hard
     $txt = git pull
}

function create_ignore_file(){
     #get the status of the branches since the last time a package is been created for current customer
     git checkout "branch-status"
     $fileExists = Test-Path "$script:localRepository\$script:localRepositoryName\ignore.xml"

#if ignore file does not exists then add it
     if($fileExists -eq $false){
"<?xml version='1.0'?>
<Ignore_Branches>
    <Customer code='template'>
		<branch> <name>v0.0</name> <last-visited>1473317322</last-visited></branch>
	</Customer>
</Ignore_Branches>" | Out-File "$script:localRepository\$script:localRepositoryName\ignore.xml"
        $txt = git add .
        $txt = git commit -a -m 'Ignore file created'
        $txt = git push origin "branch-status"
     }
}

#return the customer section which contains the branches to be ignored.
#if this customer does not have a section in the ignore file then it will be added first
function get_customer_node_in_ignore_file ([String] $cc){
     #load te ignore file
     $ignore_file = get-childitem "ignore.xml" | Select-Object -ExpandProperty FullName
     $to_ignore = New-Object XML
     $to_ignore.Load($ignore_file)

     #get the branches to ignore for this customer
     $customer = $to_ignore.Ignore_Branches.Customer | Where-Object {$_.code -ieq $cc}

     #if this customer is not added to the ignore file then do it now
     if([String]::IsNullOrWhiteSpace($customer.OuterXml)){
        $temp_node = $to_ignore.SelectSingleNode("//Customer[@code = 'template']")
        $new_customer_node = $temp_node.CloneNode($false)
        $new_customer_node.Code = $cc
        $to_ignore.Ignore_Branches.AppendChild($new_customer_node)
        $to_ignore.Save($ignore_file)

        #commit the changes to the ignore file
        $txt = git commit -a -m "New node for customer $cc is created."
     }

     $customer = $to_ignore.Ignore_Branches.Customer | Where-Object {$_.code -ieq $cc}

     return $customer

}
##############################################################################
#.SYNOPSIS
# Creates a post install package from the remote repository.
#
#.DESCRIPTION
# Creates a post install package from the remote repository.
#
#.PARAMETER cc
# Customer Code, options are: USCUSTOMERS, AUCUSTOMERS, ALL, or individual 
# customers like AUCOF.
#
#.PARAMETER qnv
# The target QESTNet version.
#
#.PARAMETER mqnt
# The minimum QEST Net version. By default the package will include all the post
# install scripts from all previous versions that apply to this version.
# You can specify a minimum version if you know that the package you are interested 
# in does not have any post install scripts perior to the minimum version. This will
# save some time in checking out the remote repository and scanning fiels.
# this is optional and the default is "none". 
#
#.PARAMETER pkgd
# package destination. Default is $script:outputDestination\$script:outputFoldername.
#.PARAMETER mqnt
#.EXAMPLE
# 
##############################################################################
function cpip ([String] $cc,[String] $qnv,[String] $mqnt = "none", [String] $pkgd = "$script:packageDestination"){    
     
     #sync local repository with the remote repository
     create_or_update_local_repository -pkgd $pkgd

     #create ignore file if it does not exists
     create_ignore_file
     
     #get the branches to ignore for this customer
     $customer_ignore_list = get_customer_node_in_ignore_file -cc $cc

     #get a list of the version branches
     $branches = git branch -r --list

     #$branches =  for branch in `git branch -r | grep -v HEAD`;do echo -e `git show --format="%ct %ci" $branch | head -n 1` \\t$branch; done | sort -r

     foreach($branch in $branches){
        #split the brancg name
        $branch = ($branch -split '/')[-1]
        if ($branch.StartsWith($script:versionPrefix)){
            
            #checkout current branch
            $txt = git checkout $branch

            #check to see if this branch is in teh ignore list
            $Utime_last_visited = $customer_ignore_list.branch | Where-Object {$_.name -ieq $branch}|Select-Object -ExpandProperty "last-visited"
            $Utime_last_updated = git show --format="%ct"
            $Utime_last_updated = ($Utime_last_updated -split '\n')[0]
            $Utime_last_updated = ($Utime_last_updated -split ' ')[0]

            Write-host $Utime_last_visited
            Write-host $Utime_last_updated
        }
     }
    
     return

     # manifest template
     $manifest_package = "<?xml version='1.0'?>
<Scripts>
"

     
     foreach($branch in $branches){
        #split the brancg name
        $branch = ($branch -split '/')[-1]



        if ($branch.StartsWith($script:versionPrefix)){
            #pull the branch
            $txt = git checkout $branch
            #$txt = git pull origin $branch
            
            #get all the xml manifest files
            $manifests = get-childitem -include manifest.xml -Recurse | Select-Object -ExpandProperty FullName
            $scripts = get-childitem -include *.sql -Recurse | Select-Object -ExpandProperty FullName

            #create_package_manifest -manifests $manifests -scripts $scripts -customerCode $cc
            
            #load each manifest and only include the 
            foreach ($manifest in $manifests){
                $scripts_location = Split-Path -Path $manifest

                $valid_scripts_descriptions = get_scripts_descriptions -manifest_location $manifest -customerCode $cc -qnv $qnv
                if([string]::IsNullOrEmpty($valid_scripts_descriptions)){}else {$manifest_package = "$manifest_package$valid_scripts_descriptions"}

                #get the post install scripts names
                $valid_scripts = get_post_install_scripts -manifest_location $manifest -customerCode $cc -qnv $qnv
                foreach($script in $valid_scripts){
                    Copy-Item "$scripts_location\$script" -Destination "$script:packageDestination\post-install"
                }

                #get the pre install scripts names
                $valid_scripts = get_pre_install_scripts -manifest_location $manifest -customerCode $cc -qnv $qnv
                foreach($script in $valid_scripts){
                    Copy-Item "$scripts_location\$script" -Destination "$script:packageDestination\pre-install"
                }

            }
        }
     }
     
    
    $manifest_package = "$manifest_package
</Scripts>"
   
    $manifest_package | Out-File "$script:packageDestination\manifest.xml"
    cd ../

}


function config (){
   set_config_value -name "remoteRepository" -value (get_user_input -message "Remote repository address")
   set_config_value -name "versionPrefix" -value (get_user_input -message "The version branches prefix. If the branches are named v1.28 then the prefix is v.")
   set_config_value -name "localRepository" -value (get_user_input -message "The local repository location. Can use ./ for current working dir.")
   set_config_value -name "packageDestination" -value (get_user_input -message "Specify the post install package destination. Can use ./ for current working dir.")
   $script:ConfigFile.Save("$script:myDir\$script:configFileName")
   load_config_values  
}

########################################################################################
#update the defalut values
function load_config_values(){
    if(get_config_value -name "localRepository") {
        $script:localRepository = get_config_value -name "localRepository"
        $script:localRepository = $script:localRepository.Replace("./","$script:myDir")
     }
    if(get_config_value -name "remoteRepository") {$script:remoteRepository = get_config_value -name "remoteRepository"}
    if(get_config_value -name "versionPrefix") {$script:versionPrefix = get_config_value -name "versionPrefix"}
    if(get_config_value -name "customerCode") {$script:customerCode = get_config_value -name "customerCode"}
    if(get_config_value -name "targetQNVersion") {$script:targetQNVersion = get_config_value -name "targetQNVersion"}
    if(get_config_value -name "minimumQNVersion") {$script:minimumQNVersion = get_config_value -name "minimumQNVersion"}
    if((get_config_value -name "interactiveMode")) {$script:interactiveMode = get_config_value -name "interactiveMode"}
    if((get_config_value -name "packageDestination")) {
        $script:packageDestination = get_config_value -name "packageDestination"
        $script:packageDestination = $script:packageDestination.Replace("./","$script:myDir\")
      }
      
    $script:localRepositoryName = ((get_config_value -name "remoteRepository") -split '/')[-1]
}
########################################################################################

load_config_values
if($script:interactiveMode -eq $false){
    cpip -cc $script:customerCode -qnv $script:targetQNVersion -mqnv $script:minimumQNVersion
}else{
    while("true" -eq "true")
    {
        $input = get_user_input -message ($script:myDir)
        $args = $input.split()
        $command = $args[0].ToLower()

        if($commands.Contains($command)) {Invoke-Expression $command}
        else {
        cpip -cc "auhan" -qnv "2.5"
        
        Write-host "Invalid command "$command}
     }
}
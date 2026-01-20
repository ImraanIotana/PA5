####################################################################################################
<#
.SYNOPSIS
    This data file contains CUSTOMER SPECIFIC settings for the Packaging Assistant.
.DESCRIPTION
    This data is self-contained and does not refer to functions, variables or classes, that are in other files.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

@{
    ##### CUSTOMER SPECIFIC SETTINGS ##### START

    ##### DSL/SOFTWARE LIBRARY #####
    DefaultDSLFolder                = '\\ksmod.nl\KSpackages\SoftwareLibrary'

    ##### DSL/SOFTWARE LIBRARY #####
    DeploymentScriptPath            = '\\ksmod.nl\KSpackages\SoftwareLibrary\_Administration\Other\PowerShell\UniversalDeploymentScript'

    ##### CUSTOMER DEPARTMENT SETTINGS #####
    CustomerDepartments             = @('Baseline','DHC','EW','GeoInt','ISRD','KSIT','MiddleWare','Optional','OS','Space')

    ##### SCCM DEFAULT SETTINGS #####
    SCCMDefaultSiteCode             = 'CNM'
    SCCMDefaultProviderMachineName  = 'V0164APS0511.ksmod.nl'

    ##### SCCM EXECUTABLE #####
    SCCMExecutable                  = 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe'

    ##### SCCM REPOSITORY #####
    SCCMRepository                  = '\\ksmod.nl\kspackages\Sources\01-Application Management'

    ##### SCCM TEST COLLECTION #####
    SCCMPackagingVDICollection      = 'Test - Packaging VDI'
    SCCMTestVDICollection           = 'Test - Packaging VDI'

    ##### DEM REPOSITORY #####
    DEMShortcutRepository           = '\\ksmod.nl\DEMconfig\0164c1\general\FlexRepository\Shortcut'
    DEMUserFilesRepository          = '\\ksmod.nl\DEMconfig\0164c1\general\FlexRepository\Settings\File'
    DEMUserRegistryRepository       = '\\ksmod.nl\DEMconfig\0164c1\general\FlexRepository\Settings\Reg'
    DEMLogFolder                    = '\\ksmod.nl\ks-home\Profile\'

    ##### APPLOCKER LDAP #####
    AppLockerLDAPTEST               = 'LDAP://v0164aps0500.ksmod.nl/CN={62242444-75F6-4AA2-89D0-034917004AA3},CN=Policies,CN=System,DC=ksmod,DC=nl'
    AppLockerLDAPPROD               = 'LDAP://v0164aps0500.ksmod.nl/CN={BA363FDE-6098-4CBA-9233-E1512BF88ABA},CN=Policies,CN=System,DC=ksmod,DC=nl'

    ##### APPLOCKER LDAP #####
    NetworkScreenshotsFolderFix     = '\\ksmod.nl\ks-home\Home\{0}\Pictures\Screenshots'


    ##### CUSTOMER SPECIFIC SETTINGS ##### END
}
####################################################################################################
<#
.SYNOPSIS
    This data file contains CUSTOMER SPECIFIC settings for the Packaging Assistant.
.DESCRIPTION
    This data is self-contained and does not refer to functions, variables or classes, that are in other files.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : January 2026
#>
####################################################################################################

@{
    ##### CUSTOMER SPECIFIC SETTINGS ##### START

    ##### DSL/SOFTWARE LIBRARY #####
    DefaultDSLFolder                = '\\domain.nl\Packages\SoftwareLibrary'

    ##### DEPLOYMENT SCRIPT PATH #####
    DeploymentScriptPath            = '\\domain.nl\Packages\SoftwareLibrary\UniversalDeploymentScript'
    SupportScriptsPath              = '\\domain.nl\Packages\SoftwareLibrary\_Administration\Other\PowerShell\UniversalDeploymentScript\Deploy-ApplicationSupport'

    ##### CUSTOMER DEPARTMENT SETTINGS #####
    CustomerDepartments             = @('Baseline','MiddleWare','Optional','Dept1','Dept2')

    ##### SCCM DEFAULT SETTINGS #####
    SCCMDefaultSiteCode             = 'ABC'
    SCCMDefaultProviderMachineName  = 'servername.domain.nl'

    ##### SCCM EXECUTABLE #####
    SCCMExecutable                  = 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\Microsoft.ConfigurationManagement.exe'

    ##### SCCM REPOSITORY #####
    SCCMRepository                  = '\\domain.nl\SCCMSources'

    ##### SCCM TEST COLLECTION #####
    SCCMPackagingVDICollection      = 'Packaging VDI'
    SCCMTestVDICollection           = 'Test VDI'

    ##### DEM REPOSITORY #####
    DEMShortcutRepository           = '\\domain.nl\DEMconfig\folder\general\FlexRepository\Shortcut'
    DEMUserFilesRepository          = '\\domain.nl\DEMconfig\folder\general\FlexRepository\Settings\File'
    DEMUserRegistryRepository       = '\\domain.nl\DEMconfig\folder\general\FlexRepository\Settings\Reg'
    DEMLogFolder                    = '\\domain.nl\folder\Profile\'

    ##### APPLOCKER LDAP #####
    AppLockerLDAPDEVELOPMENT        = 'LDAP://servername.domain.nl/CN={DEVELOPM-75F6-4AA2-89D0-034917004AA3},CN=Policies,CN=System,DC=domain,DC=nl'
    AppLockerLDAPTEST               = 'LDAP://servername.domain.nl/CN={TEST1234-ABCD-4AA2-89D0-034917004AA3},CN=Policies,CN=System,DC=domain,DC=nl'
    AppLockerLDAPACCEPTANCE         = 'LDAP://servername.domain.nl/CN={ACCEPTAN-1234-4AA2-89D0-034917004AA3},CN=Policies,CN=System,DC=domain,DC=nl'
    AppLockerLDAPPRODUCTION         = 'LDAP://servername.domain.nl/CN={PRODUCTI-6098-4CBA-9233-E1512BF88ABA},CN=Policies,CN=System,DC=domain,DC=nl'

    ##### SCREENSHOTS #####
    NetworkScreenshotsFolderFix     = '\\domain.nl\folder\Home\{0}\Pictures\Screenshots'


    ##### CUSTOMER SPECIFIC SETTINGS ##### END
}
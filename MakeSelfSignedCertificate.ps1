#
# This script will create and install two certificates:
#     1. `LocalCMakeExperiment_CA.cer`: A self-signed root authority certificate.
#     2. `LocalCMakeExperimentKey.cer`: The certificate to sign code in
#         a development environment (signed with `LocalCMakeExperiment_CA.cer`).
# 
# User interaction is needed to input the password.
# Powershell 4.0 or higher is required.
#

# Get the current working directory
$currentDir = $PWD.Path

# Request user input for DNS name and password
$passwordPlainText = Read-Host -Prompt 'Provide a password for the certificate' -AsSecureString
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordPlainText))

# Create a root Certificate Authority (CA) with a 2-year validity period
$rootCert = New-SelfSignedCertificate -KeyExportPolicy Exportable -CertStoreLocation cert:\CurrentUser\My -DnsName "CMake.Experiment.Authority" -NotAfter (Get-Date).AddYears(2) -TextExtension @("2.5.29.19={text}CA=1&pathlength=3", "2.5.29.37={text}1.3.6.1.5.5.7.3.3") -KeyusageProperty All -KeyUsage CertSign,CRLSign,DigitalSignature

# Export the root authority private key
[String] $rootCertPath = Join-Path -Path cert:\CurrentUser\My\ -ChildPath "$($rootcert.Thumbprint)"
$caPfxPath = Join-Path -Path $currentDir -ChildPath "LocalCMakeExperiment_CA.pfx"
$caCrtPath = Join-Path -Path $currentDir -ChildPath "LocalCMakeExperiment_CA.crt"
Export-PfxCertificate -Cert $rootCertPath -FilePath $caPfxPath -Password $passwordPlainText
Export-Certificate -Cert $rootCertPath -FilePath $caCrtPath

# Create a "LocalCMakeExperimentKey" certificate signed by our root authority
$cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName "CMake.Experiment.Certificate" -Signer $rootCert -Type CodeSigningCert

# Save the signed certificate with private key into a PFX file and just the public key into a CRT file
[String] $certPath = Join-Path -Path cert:\LocalMachine\My\ -ChildPath "$($cert.Thumbprint)"
$spcPfxPath = Join-Path -Path $currentDir -ChildPath "LocalCMakeExperimentKey.pfx"
$spcCrtPath = Join-Path -Path $currentDir -ChildPath "LocalCMakeExperimentKey.crt"
Export-PfxCertificate -Cert $certPath -FilePath $spcPfxPath -Password $passwordPlainText
Export-Certificate -Cert $certPath -FilePath $spcCrtPath

# Add LocalCMakeExperiment_CA certificate to the Trusted Root Certification Authorities
$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
$pfx.import($caPfxPath, $passwordPlainText, "Exportable,PersistKeySet")
$store = new-object System.Security.Cryptography.X509Certificates.X509Store(
    [System.Security.Cryptography.X509Certificates.StoreName]::Root,
    "localmachine"
)
$store.open("MaxAllowed")
$store.add($pfx)
$store.close()

# Import certificate
Import-PfxCertificate -FilePath $spcPfxPath cert:\CurrentUser\My -Password $passwordPlainText

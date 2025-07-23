param (
    [string]$Title,
    [string]$OutputFile
)

Add-Type -AssemblyName System.Windows.Forms

$f = New-Object System.Windows.Forms.FolderBrowserDialog
$f.Description = $Title

if ($f.ShowDialog() -eq 'OK') {
    Set-Content -Path $OutputFile -Value $f.SelectedPath -Encoding OEM
}
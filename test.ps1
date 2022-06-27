Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. .\TimePicker.ps1

$tp = New-Object TimePicker(25,5)

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size(250,250)

$form.Controls.Add($tp)

$form.ShowDialog() > $null

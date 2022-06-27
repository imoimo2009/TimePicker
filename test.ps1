Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. .\TimePicker.ps1

$tp = New-Object TimePicker(0,0)

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size($tp.Size.Width,$tp.Size.Height)

$form.Controls.Add($tp)

$form.ShowDialog() > $null

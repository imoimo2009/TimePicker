Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. .\TimePicker.ps1

function TimePicker_VisibleChanged([TimePicker]$own){
    if(-not $own.Visible){
        $tb.Text = $tp.Text
    }
}

function Button_Click(){
    $tp.Visible = $true
}

$tp = New-Object TimePicker(0,0,400,480)
$tp.Visible = $false
$tp.Add_VisibleChanged({TimePicker_VisibleChanged})

$tb = New-Object System.Windows.Forms.TextBox
$tb.Location = New-Object System.Drawing.Point(150,200)
$tb.Size = New-Object System.Drawing.Size(100,30)
$tb.Font = New-Object System.Drawing.Font("Meiryo UI",16)
$tb.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center

$bt = New-Object System.Windows.Forms.Button
$bt.Location = New-Object System.Drawing.Point(150,240)
$bt.Size = New-Object System.Drawing.Size(100,50)
$bt.Text = "Open`nTimePicker"
$bt.Add_Click({Button_Click})

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size($tp.Size.Width,$tp.Size.Height)

$form.Controls.Add($tp)
$form.Controls.Add($tb)
$form.Controls.Add($bt)

$form.ShowDialog() > $null

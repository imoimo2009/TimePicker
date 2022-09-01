Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. .\TimePicker.ps1

function Form_Shown(){
    $tb.Left = $form.ClientSize.Width / 2 - $tb.Width / 2
    $tb.Top = $form.ClientSize.Height / 2 - $tb.Height
    $bt.Left = $form.ClientSize.Width / 2 - $bt.Width / 2
    $bt.Top = $form.ClientSize.Height / 2 + 16
}

function TimePicker_VisibleChanged([TimePicker]$own){
    if(-not $own.Visible){
        $tb.Text = $tp.Text
    }
}

function Button_Click(){
    $tp.Text = $tb.Text
    # 分入力モードかつ午後表示モードで開く
    $tp.Open(([TimePicker]::ModeMinute + [TimePicker]::ModeAfternoon))
}

$tp = New-Object TimePicker(0,0,400,480)
$tp.Visible = $false
$tp.AutoNext = $true
$tp.Add_VisibleChanged({TimePicker_VisibleChanged})

$tb = New-Object System.Windows.Forms.TextBox
$tb.Size = New-Object System.Drawing.Size(100,30)
$tb.Font = New-Object System.Drawing.Font("Meiryo UI",16)
$tb.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center

$bt = New-Object System.Windows.Forms.Button
$bt.Size = New-Object System.Drawing.Size(100,50)
$bt.Text = "Open`nTimePicker"
$bt.Add_Click({Button_Click})

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size($tp.Size.Width,$tp.Size.Height)
$form.Add_Shown({Form_Shown})

$form.Controls.Add($tp)
$form.Controls.Add($tb)
$form.Controls.Add($bt)

$form.ShowDialog() > $null

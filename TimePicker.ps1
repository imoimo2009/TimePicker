﻿class TimePicker : System.Windows.Forms.PictureBox {
    [int] $Hour
    [int] $Minute
    [string] $Text
    hidden [int] $X
    hidden [int] $Y
    hidden [object] $Center
    hidden [object] $DigitalRect
    hidden [int] $BaseSize
    hidden [int] $ValueSize
    hidden [int] $ValueRadius
    hidden [int] $ValueSize2
    hidden [int] $ValueRadius2
    hidden [bool] $Click
    hidden [object] $Brushes
    hidden [object] $Pens
    hidden [System.Drawing.StringFormat] $Format
    hidden [System.Drawing.Font] $ClkFont
    hidden [System.Drawing.Font] $ClkFont2
    hidden [int] $Mode

    TimePicker() : base() {
        $this.Init()
     }
 
    TimePicker([int]$left,[int]$top) : base(){
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Location = New-Object System.Drawing.Point($left,$top)
        $this.Init()
        
    }

    Init(){
        # プロパティ初期化
        $this.Hour = 0
        $this.Minute = 0
        $this.X = 0
        $this.Y = 0
        $this.Center = @{X = 100 ; Y = 140}
        $this.DigitalRect = @{Left = 50 ; Top = 10 ; Width = 100 ; Height = 36}
        $this.BaseSize = 180
        $this.ValueSize = 25
        $this.ValueRadius = 73
        $this.ValueSize2 = 22
        $this.ValueRadius2 = 47
        $this.Text = ""
        $this.Brushes = @{
            BG      = New-Object System.Drawing.SolidBrush("#AAAAFF")
            BASE    = new-object System.Drawing.SolidBrush("#4444AA")
            CELL    = New-Object System.Drawing.SolidBrush("#6666CC")
            SCELL   = New-Object System.Drawing.SolidBrush("#FFFFFF")
            RCELL   = New-Object System.Drawing.SolidBrush("#AAAADD")
        }
        $this.Pens = @{
            SLINE   = New-Object System.Drawing.Pen("#FFFFFF")
            RLINE   = New-Object System.Drawing.Pen("#AAAADD")
        }
        $this.Pens.SLINE.Width = 2
        $this.Pens.RLINE.Width = 2
        $this.Format = New-Object System.Drawing.StringFormat
        $this.Format.Alignment = [System.Drawing.StringAlignment]::Center
        $this.Format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $this.ClkFont = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",12,[System.Drawing.FontStyle]::Bold
        )
        $this.ClkFont2 = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",9,[System.Drawing.FontStyle]::Regular
        )
        $this.Mode = 0
        # PictureBox初期化
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Size = New-Object System.Drawing.Size(200,240)
        $base.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $base.BackColor = [System.Drawing.Color]::Transparent
        $base.Font = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",24,[System.Drawing.FontStyle]::Bold
        )
        # イベントハンドラ登録
        $base.Add_Paint({$this.OwnerDraw($_)})
        $base.Add_MouseDown({$this.MouseDown()})
        $base.Add_MouseUp({$this.MouseUp()})
        $base.Add_MouseMove({$this.MouseMove($_)})
        $base.Add_MouseLeave({$this.MouseLeave()})
    }

    # オーナードロー(独自描画)処理
    OwnerDraw([System.Windows.Forms.PaintEventArgs] $e){
        $base = [System.Windows.Forms.PictureBox] $this
        $c = $this.Center
        $g = $e.Graphics
        $rect = $e.ClipRectangle
        $cell = @()
        # 背景
        $b = $this.Brushes.BG
        $g.FillRectangle($b,0,8,$rect.Width,$rect.Height - 16)
        $g.FillRectangle($b,8,0,$rect.Width - 16,$rect.Height)
        $g.fillPie($b,0,0,16,16,180,90)
        $g.fillPie($b,$rect.Width -16,0,16,16,270,90)
        $g.fillPie($b,0,$rect.Height - 16,16,16,90,90)
        $g.fillPie($b,$rect.Width - 16,$rect.Height - 16,16,16,0,90)
        # アナログ部
        $f = $this.BaseSize
        $g.fillPie($this.Brushes.BASE,$c.X - $f / 2,$c.Y - $f / 2,$f,$f,0,360)
        if($this.Mode -eq 0){
            # 時間入力モード
            for($i = 23 ; $i -ge 0 ; $i--){
                if($i -lt 12){
                    # 0-11時
                    $r = $this.ValueRadius
                    $vs = $this.ValueSize
                    $fnt = $this.ClkFont
                }else{
                    # 12-23時
                    $r = $this.ValueRadius2
                    $vs = $this.ValueSize2
                    $fnt = $this.ClkFont2
                }
                $rad = $this.Rad(($i % 12) * 30 - 90)
                $a = $this.GetArcPos($rad,$r,$c.X,$c.Y)
                $d = $this.GetDistance($this.X,$this.Y,$a.X,$a.Y)
                if($d -le $vs / 2){
                    $cell += @{
                        radian = $rad
                        radius = $r
                        size = $vs
                        font = $fnt
                        brush = $this.Brushes.SCELL
                        pen = $this.Pens.SLINE
                        value = "{0:00}" -f $i
                    }
                    if($this.Click){
                        $this.Hour = $i
                    }
                }elseif($i -eq $this.Hour){
                    $cell += @{
                        radian = $rad
                        radius = $r
                        size = $vs
                        font = $fnt
                        brush = $this.Brushes.RCELL
                        pen = $this.Pens.RLINE
                        value = "{0:00}" -f $i
                    }
                }
                $g.FillPie($this.Brushes.CELL,$a.X - $vs / 2,$a.Y - $vs / 2,$vs,$vs,0,360)
                $s = "{0:00}" -f $i
                $g.DrawString($s,$fnt,$this.Brushes.BASE,$a.X,$a.Y,$this.Format)
            }
            # デジタル切り替え用
            $bh = $this.Brushes.SCELL
            $bm = $this.Brushes.RCELL
        }else{
            # 分入力モード
            for($i = 0 ; $i -lt 60 ; $i++){
                $rad = $this.Rad($i * 6 - 90)
                if($i % 5 -eq 0){
                    $a = $this.GetArcPos($rad,$this.ValueRadius,$c.X,$c.Y)
                    $s = "{0:00}" -f $i
                    $g.DrawString($s,$this.ClkFont,$this.Brushes.BG,$a.X,$a.Y,$this.Format)
                }
            }
            $cell += @{
                radian = $this.Rad($this.Minute * 6 - 90)
                radius = $this.ValueRadius
                size = $this.ValueSize
                font = $this.ClkFont
                brush = $this.Brushes.RCELL
                pen = $this.Pens.RLINE
                value = "{0:00}" -f $this.Minute
            }
            $d = $this.GetDistance($this.X,$this.Y,$c.X,$c.Y)
            if($d -le $f / 2){
                $rad = [math]::Atan2($this.Y - $c.Y,$this.X - $c.X)
                $min = $this.Rad2Minute($rad)
                $cell += @{
                    radian = $rad
                    radius = $this.ValueRadius
                    size = $this.ValueSize
                    font = $this.ClkFont
                    brush = $this.Brushes.SCELL
                    pen = $this.Pens.SLINE
                    value = "{0:00}" -f $min
                }
                if($this.Click){
                    $this.Minute = $min
                }
            }
            # デジタル切り替え用
            $bh = $this.Brushes.RCELL
            $bm = $this.Brushes.SCELL
        }
        # 選択カーソル表示
        foreach($i in $cell){
            $a = $this.GetArcPos($i.radian,$i.radius,$c.X,$c.Y)
            $g.DrawLine($i.pen,$c.X,$c.Y,$a.X,$a.Y)
            $g.FillPie($i.brush,$c.X - 4,$c.Y - 4,8,8,0,360)
            $vs = $i.size
            $g.FillPie($i.brush,$a.X - $vs / 2,$a.Y - $vs / 2,$vs,$vs,0,360)
            $g.DrawString($i.value,$i.font,$this.Brushes.BASE,$a.X,$a.Y,$this.Format)
        }
        # デジタル部
        $d = $this.DigitalRect
        $g.FillRectangle($this.Brushes.BASE,$d.Left,$d.Top,$d.Width,$d.Height)
        $s = "{0:00}" -f $this.Hour
        $g.DrawString($s,$base.Font,$bh,$c.X - 22,28,$this.Format)
        $g.DrawString(":",$base.Font,$this.Brushes.RCELL,$c.X,26,$this.Format)
        $s = "{0:00}" -f $this.Minute
        $g.DrawString($s,$base.Font,$bm,$c.X + 22,28,$this.Format)
        $this.SetText()
    }

    # 角度をラジアンに変換
    [double] Rad([int]$deg){
        return [math]::PI / 180 * $deg
    }

    # 指定角度の円弧座標を返す
    [object] GetArcPos([double]$rad,[int]$r,[int]$x,[int]$y){
        $rx = [math]::Cos($rad) * $r + $x
        $ry = [math]::Sin($rad) * $r + $y
        return @{X = $rx ; Y = $ry}
    }

    # 2点間の距離を算出
    [double] GetDistance([int]$x1,[int]$y1,[int]$x2,[int]$y2){
        $xp = [math]::Pow([math]::Abs($x2 - $x1),2)
        $yp = [math]::Pow([math]::Abs($y2 - $y1),2)
        return [math]::Sqrt($xp + $yp)
    }

    # ラジアンから分数を返す
    [int] Rad2Minute([double]$rad){
        $m = [convert]::ToInt32($rad / ([math]::PI * 2) * 60 + 15)
        if($m -lt 0){
            $m += 60
        }
        return $m
    }

    # テキストプロパティを更新
    hidden SetText(){
        $hur = "{0:00}" -f $this.Hour
        $min = "{0:00}" -f $this.Minute
        $this.Text = "${hur}:${min}"
    }

    # ボタンが押されたとき
    MouseDown(){
        $this.Click = $true
        $c = $this.Center
        $d = $this.DigitalRect
        if($this.Y -lt $d.Top + $d.Height){
            if($this.X -lt $c.X){
                $this.Mode = 0
            }else{
                $this.Mode = 1
            }
        }
        $this.Invalidate()
    }
 
    # ボタンが離されたとき
    MouseUp(){
        $this.Click = $false
        #$this.Invalidate()
    }

    # マウスが移動したとき
    MouseMove([System.Windows.Forms.MouseEventArgs]$e){
        $this.X = $e.X
        $this.Y = $e.Y
        $this.Invalidate()
    }

    # マウスがコントロールの外に出たとき
    MouseLeave(){
        $this.Invalidate()
    }
}

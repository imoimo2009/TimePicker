class TimePicker : System.Windows.Forms.PictureBox {
    # プロパティ定義
    [int] $Hour                                     # 時間
    [int] $Minute                                   # 分
    [string] $Text                                  # 時刻文字列
    # 非表示プロパティ定義
    hidden [int] $X                                 # コントロール内のマウス座標X
    hidden [int] $Y                                 # コントロール内のマウス座標Y
    hidden [object] $Center                         # 時計盤の原点
    hidden [object] $DigitalRect                    # デジタル表示部の矩形エリア
    hidden [object] $CloseBtn                       # 閉じるボタンのパラメータ
    hidden [int] $BaseRadius                        # 時計盤の半径
    hidden [int] $ValueSize                         # 時間の円のサイズ(外側)
    hidden [int] $ValueRadius                       # 時間表示の原点からの距離(外側)
    hidden [int] $ValueSize2                        # 時間の円のサイズ(外側)
    hidden [int] $ValueRadius2                      # 時間表示の原点からの距離(外側)
    hidden [bool] $Click                            # クリックの状態
    hidden [object] $Brushes                        # ブラシ保存用
    hidden [object] $Pens                           # ペン保存用
    hidden [System.Drawing.Bitmap] $Bmp             # ビットマップオブジェクト
    hidden [System.Drawing.Graphics] $Gp            # ビットマップ描画用グラフィックオブジェクト
    hidden [System.Drawing.StringFormat] $Format    # 文字列配置
    hidden [System.Drawing.Font] $ClkFont           # 時計表示のフォント(外側)
    hidden [System.Drawing.Font] $ClkFont2          # 時計表示のフォント(内側)
    hidden [int] $Mode                              # 入力モード
    hidden [object]$Scale                           # 描画スケール

    # コンストラクタ
    TimePicker() : base() {
        $this.Init()
     }
 
    # コンストラクタ(位置指定)
    TimePicker([int]$left,[int]$top) : base(){
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Location = New-Object System.Drawing.Point($left,$top)
        $this.Init()
        
    }

    # コンストラクタ(位置・サイズ指定)
    TimePicker([int]$left,[int]$top,[int]$width,[int]$height) : base(){
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Location = New-Object System.Drawing.Point($left,$top)
        $this.Init($width,$height)
        
    }

    # クラス初期化処理
    hidden Init(){
        $this.Init(200,240)        
    }

    # クラス初期化処理(サイズ指定)
    hidden Init([int]$width,[int]$height){
        # プロパティ初期化
        $this.Hour = 0
        $this.Minute = 0
        $this.Text = "00:00"
        $this.X = 0
        $this.Y = 0
        $this.Center = @{X = 400 ; Y = 560}
        $this.DigitalRect = @{Left = 200 ; Top = 40 ; Width = 400 ; Height = 144}
        $this.CloseBtn = @{X = 763 ; Y = 37 ; R = 27 ; M = 15}
        $this.BaseRadius = 360
        $this.ValueSize = 50
        $this.ValueRadius = 292
        $this.ValueSize2 = 40
        $this.ValueRadius2 = 188
        $this.Brushes = @{
            BG      = New-Object System.Drawing.SolidBrush("#AAAAFF")
            BASE    = new-object System.Drawing.SolidBrush("#4444AA")
            CELL    = New-Object System.Drawing.SolidBrush("#6666CC")
            SCELL   = New-Object System.Drawing.SolidBrush("#FFFFFF")
            RCELL   = New-Object System.Drawing.SolidBrush("#AAAADD")
            CLOSE   = New-Object System.Drawing.SolidBrush("#FFAAAA")
            SCLOSE  = New-Object System.Drawing.SolidBrush("#FF0000")
        }
        $this.Pens = @{
            SLINE   = New-Object System.Drawing.Pen("#FFFFFF")
            RLINE   = New-Object System.Drawing.Pen("#AAAADD")
            CLOSE   = New-Object System.Drawing.Pen("#FF0000")
            SCLOSE  = New-Object System.Drawing.Pen("#FFDDDD")
        }
        $this.Pens.SLINE.Width = 8
        $this.Pens.RLINE.Width = 8
        $this.Pens.CLOSE.Width = 6
        $this.Pens.SCLOSE.Width = 6
        $this.Bmp = New-Object System.Drawing.Bitmap(800,960)
        $this.Gp = [System.Drawing.Graphics]::FromImage($this.Bmp)
        $this.Format = New-Object System.Drawing.StringFormat
        $this.Format.Alignment = [System.Drawing.StringAlignment]::Center
        $this.Format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $this.ClkFont = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",48,[System.Drawing.FontStyle]::Bold
        )
        $this.ClkFont2 = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",36,[System.Drawing.FontStyle]::Regular
        )
        $this.Scale = $this.GetScale($width,$height,800,960)
        $this.Mode = 0
        # PictureBox初期化
        $base = [System.Windows.Forms.PictureBox] $this
        $base.Size = New-Object System.Drawing.Size($width,$height)
        $base.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $base.BackColor = [System.Drawing.Color]::Transparent
        $base.Font = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",80,[System.Drawing.FontStyle]::Bold
        )
        $base.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
        # イベントハンドラ登録
        $base.Add_Paint({$this.OwnerDraw($_)})
        $base.Add_MouseDown({$this.MouseDown()})
        $base.Add_MouseUp({$this.MouseUp()})
        $base.Add_MouseMove({$this.MouseMove($_)})
        $base.Add_MouseLeave({$this.MouseLeave()})
    }

    # オーナードロー(独自描画)処理
    hidden OwnerDraw([System.Windows.Forms.PaintEventArgs] $e){
        $base = [System.Windows.Forms.PictureBox] $this
        $c = $this.Center
        $g = $this.Gp
        $rect = $this.Bmp.Size
        $cell = @()
        # 背景
        $b = $this.Brushes.BG
        $g.FillRectangle($b,0,32,$rect.Width,$rect.Height - 64)
        $g.FillRectangle($b,32,0,$rect.Width - 64,$rect.Height)
        $g.fillPie($b,0,0,64,64,180,90)
        $g.fillPie($b,$rect.Width - 64,0,64,64,270,90)
        $g.fillPie($b,0,$rect.Height -64,64,64,90,90)
        $g.fillPie($b,$rect.Width - 64,$rect.Height - 64,64,64,0,90)
        # 閉じるボタン
        $cb = $this.CloseBtn
        $dt = $this.GetDistance($this.X,$this.Y,$cb.X,$cb.Y)
        if($dt -le $cb.R){
            $b = $this.Brushes.SCLOSE
            $p = $this.Pens.SCLOSE
        }else{
            $b = $this.Brushes.CLOSE
            $p = $this.Pens.CLOSE
        }
        $g.FillPie($b,$cb.X - $cb.R,$cb.Y - $cb.R,$cb.R * 2,$cb.R * 2,0,360)
        $g.DrawLine($p,$cb.X - $cb.M,$cb.Y - $cb.M,$cb.X + $cb.M,$cb.Y + $cb.M)
        $g.DrawLine($p,$cb.X - $cb.M,$cb.Y + $cb.M,$cb.X + $cb.M,$cb.Y - $cb.M)
        # アナログ部
        $r = $this.BaseRadius
        $g.FillPie($this.Brushes.BASE,$c.X - $r,$c.Y - $r,$r * 2,$r * 2,0,360)
        if($this.Mode -eq 0){
            # 時間入力モード
            $param = @{}
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
                $dt = $this.GetDistance($this.X,$this.Y,$a.X,$a.Y)
                if($dt -le $vs){
                    $param = @{
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
                        $this.SetText()
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
                $g.FillPie($this.Brushes.CELL,$a.X - $vs,$a.Y - $vs,$vs * 2,$vs * 2,0,360)
                $s = "{0:00}" -f $i
                $g.DrawString($s,$fnt,$this.Brushes.BASE,$a.X,$a.Y,$this.Format)
            }
            if($param.Count -gt 0){
                $cell += $param
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
            $dt = $this.GetDistance($this.X,$this.Y,$c.X,$c.Y)
            if($dt -le $this.BaseRadius){
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
                    $this.SetText()
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
            $g.FillPie($i.brush,$c.X - 16,$c.Y - 16,32,32,0,360)
            $vs = $i.size
            $g.FillPie($i.brush,$a.X - $vs,$a.Y - $vs,$vs * 2,$vs * 2,0,360)
            $g.DrawString($i.value,$i.font,$this.Brushes.BASE,$a.X,$a.Y,$this.Format)
        }
        # デジタル部
        $d = $this.DigitalRect
        $g.FillRectangle($this.Brushes.BASE,$d.Left,$d.Top,$d.Width,$d.Height)
        $s = "{0:00}" -f $this.Hour
        $g.DrawString($s,$base.Font,$bh,$c.X - 88,112,$this.Format)
        $g.DrawString(":",$base.Font,$this.Brushes.RCELL,$c.X,104,$this.Format)
        $s = "{0:00}" -f $this.Minute
        $g.DrawString($s,$base.Font,$bm,$c.X + 88,112,$this.Format)
        $base.Image = $this.Bmp
    }

    # 角度をラジアンに変換
    hidden [double] Rad([int]$deg){
        return [math]::PI / 180 * $deg
    }

    # 指定角度の円弧座標を返す
    hidden [object] GetArcPos([double]$rad,[int]$r,[int]$x,[int]$y){
        $rx = [math]::Cos($rad) * $r + $x
        $ry = [math]::Sin($rad) * $r + $y
        return @{X = $rx ; Y = $ry}
    }

    # 2点間の距離を算出
    hidden [double] GetDistance([int]$x1,[int]$y1,[int]$x2,[int]$y2){
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

    # ビットマップのサイズに対するUIサイズの縮尺を返す
    hidden [object]GetScale([int]$w1,[int]$h1,[int]$w2,[int]$h2){
        return @{X = ($w2 / $w1) ; Y = ($h2 / $h1)}
    }

    # テキストプロパティを更新
    hidden SetText(){
        $hur = "{0:00}" -f $this.Hour
        $min = "{0:00}" -f $this.Minute
        $this.Text = "${hur}:${min}"
    }

    # マウスカーソルが矩形範囲内にあるかを判定
    hidden [bool]ChkInRect([object]$r){
        $cx = $this.X -ge $r.Left -and $this.X -lt $r.Left + $r.Width
        $cy = $this.Y -lt $r.Top + $r.Height -and $this.Y -ge $r.Top
        $cx = $this.X -ge $r.Left -and $this.X -lt $r.Left + $r.Width
        return ($cx -and $cy)
                
    }

    # ボタンが押されたとき
    hidden MouseDown(){
        $this.Click = $true
        if($this.ChkInRect($this.DigitalRect)){
            if($this.X -lt $this.Center.X){
                $this.Mode = 0
            }else{
                $this.Mode = 1
            }
        }elseif($this.GetDistance($this.X,$this.Y,$this.CloseBtn.X,$this.CloseBtn.Y) -le $this.CloseBtn.R){
            $this.Visible = $false
        }
        $this.Invalidate()
    }
 
    # ボタンが離されたとき
    hidden MouseUp(){
        $this.Click = $false
        #$this.Invalidate()
    }

    # マウスが移動したとき
    hidden MouseMove([System.Windows.Forms.MouseEventArgs]$e){
        $this.X = $e.X * $this.Scale.X
        $this.Y = $e.Y * $this.Scale.Y
        $this.Invalidate()
    }

    # マウスがコントロールの外に出たとき
    hidden MouseLeave(){
        $this.Invalidate()
    }
}

class TimePicker : System.Windows.Forms.PictureBox {
    # プロパティ定義
    [int] $Hour                                     # 時間
    [int] $Minute                                   # 分
    [bool] $AutoNext                                # 時刻入力時、自動的に分モードにする
    [bool] $Afternoon                               # 午後モード
    [string] $Caption                               # キャプション
    # 非表示プロパティ定義
    hidden [int] $X                                 # コントロール内のマウス座標X
    hidden [int] $Y                                 # コントロール内のマウス座標Y
    hidden [System.Drawing.Point] $Center           # 時計盤の原点
    hidden [System.Drawing.Rectangle] $DigitalRect  # デジタル表示部の矩形エリア
    hidden [System.Drawing.Rectangle] $CloseBtn     # 閉じるボタンのパラメータ
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
    hidden [System.Drawing.Font] $CaptionFont       # キャプションのフォント(外側)
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

    # コントロールを開く
    Open(){
        $this.Visible = $true
    }

    # コントロールを閉じる
    Close(){
        $this.Visible = $false
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
        $this.AutoNext = $false
        $this.Afternoon = $false
        $this.Caption = ""
        $this.X = 0
        $this.Y = 0
        $this.Center = New-Object System.Drawing.Point(400,580)
        $this.DigitalRect = New-Object System.Drawing.Rectangle(220,90,360,120)
        $this.CloseBtn = New-Object System.Drawing.Rectangle(720,0,79,79)
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
        $this.CaptionFont = New-Object System.Drawing.Font(
            "ＭＳ　ゴシック",48,[System.Drawing.FontStyle]::Bold
        )
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
        $base.Add_MouseDown({$this.MouseDown($_)})
        $base.Add_MouseUp({$this.MouseUp()})
        $base.Add_MouseMove({$this.MouseMove($_)})
        $base.Add_MouseLeave({$this.MouseLeave()})
        $base.Add_VisibleChanged({$this.VisibleChanged()})
        $base.Add_TextChanged({$this.TextChanged()})
    }

    # ボタンが押されたとき
    hidden MouseDown([System.Windows.Forms.MouseEventArgs]$e){
        switch($e.Button){
            ([System.Windows.Forms.MouseButtons]::Left){
                $this.Click = $true
                if($this.ChkInRect($this.DigitalRect)){
                    if($this.X -lt $this.Center.X){
                        $this.SetMode(0)
                    }else{
                        $this.SetMode(1)
                    }
                }
                $this.Invalidate()
                if($this.ChkInRect($this.CloseBtn)){
                    $this.Close()
                }
            }
            ([System.Windows.Forms.MouseButtons]::Right){
                $this.SetMode(1 - $this.Mode)
                $this.Invalidate()
            }
        }
    }
    
    # ボタンが離されたとき
    hidden MouseUp(){
        if($this.Click -and $this.AutoNext -and $this.ChkInCircle($this.Center,$this.BaseRadius)){
            switch($this.Mode){
                0{
                    $this.SetMode(1)
                    $this.Invalidate()
                }
                1{
                    $this.Close()
                }
            }
        }
        $this.Click = $false
    }

    # マウスが移動したとき
    hidden MouseMove([System.Windows.Forms.MouseEventArgs]$e){
        $this.X = $e.X * $this.Scale.X
        $this.Y = $e.Y * $this.Scale.Y
        $this.Invalidate()
    }

    # マウスがコントロールの外に出たとき
    hidden MouseLeave(){
        # 保持しているマウス情報を初期化
        $this.X = 0
        $this.Y = 0
        $this.Click = $false
        $this.Invalidate()
    }

    # Visibleプロパティが変更されたとき
    hidden VisibleChanged(){
        if($this.Visible){
            $this.SetMode(0)
            $this.Invalidate()
        }
    }
    
    # Textプロパティが変更されたとき
    hidden TextChanged(){
        $this.RestoreValues()
    }
    
    # オーナードロー(独自描画)処理
    hidden OwnerDraw([System.Windows.Forms.PaintEventArgs] $e){
        $base = [System.Windows.Forms.PictureBox] $this
        $c = $this.Center
        $g = $this.Gp
        $s = $this.Bmp
        $cursol = @()
        # 背景
        $g.FillRectangle($this.Brushes.BG,0,0,$s.Width,$s.Height)
        # キャプション
        if($this.Caption -ne ""){
            $g.FillRectangle($this.Brushes.CELL,0,0,$s.Width,79)
            $g.DrawString($this.Caption,$this.CaptionFont,$this.Brushes.SCELL,$c.X,44,$this.Format)
        }
        # 閉じるボタン
        $cb = $this.CloseBtn
        if($this.ChkInRect($cb)){
            $b = $this.Brushes.SCLOSE
            $p = $this.Pens.SCLOSE
        }else{
            $b = $this.Brushes.CLOSE
            $p = $this.Pens.CLOSE
        }
        $r = [Convert]::ToInt32([double]0.75 * $cb.Width)
        $g.FillRectangle($b,$cb)
        $g.DrawLine($p,$cb.Left + $r,$cb.Top + $r,$cb.Left + $cb.Width - $r,$cb.Top + $cb.Height - $r)
        $g.DrawLine($p,$cb.Left + $r,$cb.Top + $cb.Height - $r,$cb.Left + $cb.Width - $r,$cb.Top + $r)
        # アナログ部
        $r = $this.BaseRadius
        $g.FillPie($this.Brushes.BASE,$c.X - $r,$c.Y - $r,$r * 2,$r * 2,0,360)
        if($this.Mode -eq 0){
            $cursol = $this.UpdateHour()
            # デジタル切り替え用
            $bh = $this.Brushes.SCELL
            $bm = $this.Brushes.RCELL
        }else{
            $cursol = $this.UpdateMinute()
           # デジタル切り替え用
            $bh = $this.Brushes.RCELL
            $bm = $this.Brushes.SCELL
        }
        $this.UpdateCursol($cursol)
        # デジタル部
        $d = $this.DigitalRect
        $g.FillRectangle($this.Brushes.BASE,$d)
        $g.DrawString($this.ClkStr($this.Hour),$base.Font,$bh,$c.X - 84,$d.Top + $d.Height / 2 + 8,$this.Format)
        $g.DrawString(":",$base.Font,$this.Brushes.RCELL,$c.X,$d.Top + $d.Height / 2,$this.Format)
        $g.DrawString($this.ClkStr($this.Minute),$base.Font,$bm,$c.X + 84,$d.Top + $d.Height / 2 + 8,$this.Format)
        $base.Image = $this.Bmp
    }

    # 時間入力モード
    hidden [object]UpdateHour(){
        $g = $this.Gp
        $cursol = @()
        $param = @{}
        for($i = 23 ; $i -ge 0 ; $i--){
            if(($i -lt 12) -xor $this.Afternoon){
                # 外側
                $r = $this.ValueRadius
                $s = $this.ValueSize
                $fnt = $this.ClkFont
            }else{
                # 内側
                $r = $this.ValueRadius2
                $s = $this.ValueSize2
                $fnt = $this.ClkFont2
            }
            $rad = $this.Rad(($i % 12) * 30 - 90)
            $a = $this.GetArcPos($rad,$r)
            if($this.ChkInCircle($a,$s)){
                $param = @{
                    point = $a
                    size = $s
                    font = $fnt
                    brush = $this.Brushes.SCELL
                    pen = $this.Pens.SLINE
                    value = $this.ClkStr($i)
                }
                if($this.Click){
                    $this.Hour = $i
                    $this.SetText()
                }
            }elseif($i -eq $this.Hour){
                $cursol += @{
                    point = $a
                    size = $s
                    font = $fnt
                    brush = $this.Brushes.RCELL
                    pen = $this.Pens.RLINE
                    value = $this.ClkStr($i)
                }
            }
            $g.FillPie($this.Brushes.CELL,$a.X - $s,$a.Y - $s,$s * 2,$s * 2,0,360)
            $g.DrawString($this.ClkStr($i),$fnt,$this.Brushes.BASE,$a.X,$a.Y,$this.Format)
        }
        if($param.Count -gt 0){
            $cursol += $param
        }
        return $cursol
    }

    # 分入力モード
    hidden [object]UpdateMinute(){
        $g = $this.Gp
        $c = $this.Center
        $cursol = @()
        for($i = 0 ; $i -lt 60 ; $i++){
            $a = $this.GetArcPos($this.Rad($i * 6 - 90),$this.ValueRadius)
            if($i % 5 -eq 0){
                $g.DrawString($this.ClkStr($i),$this.ClkFont,$this.Brushes.BG,$a.X,$a.Y,$this.Format)
            }
            if($i -eq $this.Minute){
                $cursol += @{
                    point = $a
                    size = $this.ValueSize
                    font = $this.ClkFont
                    brush = $this.Brushes.RCELL
                    pen = $this.Pens.RLINE
                    value = $this.ClkStr($i)
                }
            }
        }
        if($this.ChkInCircle($c,$this.BaseRadius)){
            $rad = [math]::Atan2($this.Y - $c.Y,$this.X - $c.X)
            $min = $this.Rad2Minute($rad)
            $cursol += @{
                point = $this.GetArcPos($rad,$this.ValueRadius)
                size = $this.ValueSize
                font = $this.ClkFont
                brush = $this.Brushes.SCELL
                pen = $this.Pens.SLINE
                value = $this.ClkStr($min)
            }
            if($this.Click){
                $this.Minute = $min
                $this.SetText()
            }
        }
        return $cursol
    }

    # 選択カーソル表示
    hidden UpdateCursol([object]$cursol){
        $g = $this.Gp
        $c = $this.Center
        foreach($i in $cursol){
            $g.DrawLine($i.pen,$c.X,$c.Y,$i.point.X,$i.point.Y)
            $g.FillPie($i.brush,$c.X - 16,$c.Y - 16,32,32,0,360)
            $g.FillPie($i.brush,$i.point.X - $i.size,$i.point.Y - $i.size,$i.size * 2,$i.size * 2,0,360)
            $g.DrawString($i.value,$i.font,$this.Brushes.BASE,$i.point.X,$i.point.Y,$this.Format)
        }
    }

    # 角度をラジアンに変換
    hidden [double] Rad([int]$deg){
        return [math]::PI / 180 * $deg
    }

    # 指定角度の円弧座標を返す
    hidden [object] GetArcPos([double]$rad,[int]$r){
        $rx = [math]::Cos($rad) * $r + $this.Center.X
        $ry = [math]::Sin($rad) * $r + $this.Center.Y
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
        $str = "${hur}:${min}"
        if($str -ne $this.Text){
            $this.Text = $str
        }
    }

    # マウスカーソルが矩形範囲内にあるかを判定
    hidden [bool]ChkInRect([System.Drawing.Rectangle]$r){
        $cx = $this.X -ge $r.Left -and $this.X -lt $r.Left + $r.Width
        $cy = $this.Y -lt $r.Top + $r.Height -and $this.Y -ge $r.Top
        return ($cx -and $cy)
                
    }

    # 円領域内にマウスカーソルがあるかを判定
    hidden [bool]ChkInCircle([System.Drawing.Point]$p,[int]$r){
        return ($this.GetDistance($this.X,$this.Y,$p.X,$p.Y) -lt $r)
    }

    # モード切替
    hidden SetMode([int]$m){
        $this.Mode = $m
    }

    # 時計盤文字列を返す
    hidden [string]ClkStr([int]$c){
        return ("{0:00}" -f $c)
    }

    # 文字列から時間、分に値を代入する
    hidden RestoreValues(){
        $res = [regex]::Match($this.Text,"([0-9]+):([0-9]+)")
        $ignore = $true
        if($res.Success){
            $time = [DateTime]"00:00"
            if([DateTime]::TryParse($this.Text,[ref]$time)){
                $this.Hour = [convert]::ToInt32($res.Groups[1].Value)
                $this.Minute = [convert]::ToInt32($res.Groups[2].Value)
                $ignore = $false
                $this.SetText()
            }
        }
        if($ignore){
            $this.Text = "00:00"
        }
    }
}

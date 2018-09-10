# macOS版HSP

OpenHSPベースのmacOS版HSPです。OS X 10.12.1 / Xcode 8.1で動作検証しています。

## Win版HSPとの違い 

この文章はmacOS版HSP v1.0.6をもとに作成しています。

### macOS版HSPで変更されている点

- サウンドプログラミング用の命令セット
    – Mac版HSPはサウンドプログラミングを手軽にできる環境を作ることを目的に移植・開発されました。そのため、リアルタイム音合成をするための命令を標準で搭載していま す。
- smooth命令などの追加命令・関数
    – slider: スライダーを表示する。
    – box: 直線で3Dの箱を描画する。
    – smooth: アンチエリアシングをON/OFFする
    – rndf(): 0.0～任意の間の乱数を実数で返す。
    – randf() 任意～任意の間の乱数を実数で返す。
- d3moduleの一部を組み込んでいる
    – ３D座標でのカメラ位置を設定するsetcamと、拡張されたpsetやline命令を使って簡単な3D描画ができます。
- 拡張された命令
    – lineはパラメータを６つ指定すると3Dに座標変換して描画します。
    – colorの第４パラメータで色の透明度を設定できます。
    – gmodeの第１パラメータに8を設定すると、透過保護コピーモードになります。
- bgsrcの挙動
    – 枠がなくなるだけでなく、影もなくなります。また背景を透過します。ドラッグで動くウィンドウに設定されます。
- 透過付きのPNGファイルの読み込み
    – 透過情報ありのPNGファイルの読み込みに対応しています。
- エディター
    – コンパイラを内蔵しています。
    – ヘルプを内蔵しています。
    – AltHSPを内蔵しています。

### macOS版HSPの制限や既知の問題点 

- 未対応の命令がある
- ウィンドウは１つだけしか使えない
- オブジェクトの上限数は各64個
- バッファの上限数は24個
- バッファのサイズの上限は縦2500px 横2500px
- mmload等で使用できるバッファは16個
- inputのp1が文字列型である必要がある
- noteselのp1が文字列型である必要がある
- syscolorに互換性はない
- 拡張プラグインに対応していない
- パスに非ASCII文字が含まれているとコンパイル／実行できない
- Win版エディタにある機能の多くがない
    - 実行ファイル自動作成など
- Win版にあるようなサンプルやマニュアルがない

## 命令や関数などの対応状況 

macOS版HSPの命令・関数・システム変数の対応状況をそれぞれ示します。対応状況は以下のような記号で分類します。

- ○　対応している
- △　部分的に対応している（独自の仕様になっている）
- ×　対応していない

この文章はmacOS版HSP v1.0.6をもとに作成しました。

### 命令の対応状況 

No. 対応状況 命令 機能

#### COMオブジェクト操作関数

1. × comevdisp COMイベントの内容を確認

#### COMオブジェクト操作命令

1. × comevarg COMイベントのパラメーターを取得
2. × comevent COMイベントの取得開始
3. × delcom COMオブジェクト型変数の破棄
4. × newcom COMオブジェクト型変数の新規作成
5. × querycom COMオブジェクト型変数の作成
6. × sarrayconv Variant型との一括変換を行なう

#### HSPシステム制御命令

1. × assert デバッグウィンドウの表示の制御
2. × logmes デバッグウィンドウにデバッグメッセージを送信

#### オブジェクト制御命令

1. △ button ボタンの表示
2. △ chkbox チェックボックスの表示
3. △ clrobj オブジェクトをクリア
4. × combox コンボボックスの表示
5. △ input 入力ボックスの表示
6. × listbox リストボックスの表示
7. × mesbox メッセージボックスの表示
8. × objenable オブジェクトの無効化
9. × objimage button命令の画像ボタン化
10. × objmode オブジェクトにフォントを適用
11. × objprm オブジェクトの内容を変更
12. × objsel 指定オブジェクトにフォーカス移動
13. × objsize オブジェクトの表示サイズ指定
14. × objskip オブジェクトのフォーカス移動の挙動指定

#### ファイル操作命令

1. ○ bcopy ファイルのコピー
2. ○ bload バイナリデータのファイルを読み込み
3. ○ bsave バイナリデータをファイルとして出力・保存
4. ○ chdir カレントフォルダの移動変更
5. △ chdpm DPMファイル設定
6. ○ delete ファイルの削除
7. ○ dirlist 特定ファイル・フォルダの一覧リストを取得
8. ○ exist ファイルサイズの取得。ファイルの存在有無の確認
9. △ memﬁle メモリストリーム設定
10. ○ mkdir 新規フォルダの作成

#### プリプロセッサ命令

1. ○ #addition HSPスクリプトファイルを結合
2. × #aht AHTファイルヘッダを記述
3. × #ahtmes AHTメッセージの出力
4. × #cfunc 外部DLL呼び出し関数登録
5. × #cmd 拡張キーワードの登録
6. × #cmpopt コンパイル時の設定
7. × #comfunc 外部COM呼び出し命令登録
8. ○ #const マクロ名の定数定義
9. ○ #defcfunc 新規関数の定義を登録
10. ○ #deﬀunc 新規命令の定義を登録
11. ○ #deﬁne 新規マクロを登録する
12. ○ #else コンパイル制御を反転
13. ○ #endif コンパイル制御ブロック終了
14. ○ #enum マクロ名の定数を列挙
15. × #epack PACKFILE追加ファイル指定（暗号化）
16. × #func 外部DLL呼び出し命令登録
17. ○ #global モジュールの終了
18. ○ #if 数値からコンパイル制御
19. ○ #ifdef マクロ定義からコンパイル制御
20. ○ #ifndef マクロ定義からコンパイル制御
21. ○ #include HSPスクリプトファイルを結合
22. ○ #modcfunc 新規関数を割り当てる
23. ○ #modfunc 新規命令を割り当てる
24. ○ #modinit モジュール初期化処理の登録
25. ○ #modterm モジュール解放処理の登録
26. ○ #module モジュールの開始
27. × #pack PACKFILE追加ファイル指定（暗号化なし）
28. × #packopt 実行ファイル自動作成オプションの指定
29. × #regcmd 拡張プラグインの登録
30. × #runtime HSPランタイムファイルの指定
31. ○ #undef マクロ名の取り消し
32. × #usecom 外部COMインターフェースの指定
33. × #uselib 外部DLLの指定

#### プログラム制御マクロ

1. ○ _break マクロループを脱出する
2. ○ _continue マクロループをやり直す
3. ○ case 比較値指定
4. ○ default デフォルト比較指定
5. ○ do 条件付き繰り返し開始
6. ○ for 指定回数繰り返し開始
7. ○ next 指定回数繰り返し終了
8. ○ swbreak 比較実行脱出指定
9. ○ swend 比較ブロック終了
10. ○ switch 比較ブロック開始
11. ○ until 条件付き繰り返し終了
12. ○ wend 条件付き繰り返し終了
13. ○ while 条件付き繰り返し開始

#### プログラム制御命令

1. △ await 一定時間待つ(ACTIVE)
2. ○ break repeat～loopによるループから抜ける
3. ○ continue repeat～loopでループの最初に戻る
4. ○ else if命令の条件を満たしていない場合に処理を実行
5. ○ end プログラムの終了
6. ○ exec Windowsの外部ファイルを起動
7. ○ exgoto 条件を満たしていれば指定ラベルにジャンプ
8. ○ foreach 配列変数の要素数だけ繰り返すループ
9. ○ gosub 指定ラベルにサブルーチンジャンプ
10. ○ goto 指定ラベルにジャンプ
11. ○ if 条件を満たしていれば処理を実行
12. ○ loop ループの始まりに戻る
13. ○ on 数値による分岐
14. × onclick マウスクリック割り込み時のラベルジャンプ先指定
15. × oncmd ウィンドウメッセージ割り込み時のラベルジャンプ先指定
16. × onerror HSPエラー発生時のラベルジャンプ先指定
17. × onexit プログラム終了時のラベルジャンプ先指定
18. × onkey キー押し割り込み時のラベルジャンプ先指定
19. ○ repeat ループの始まりの場所を示す
20. ○ return サブルーチンジャンプから復帰
21. × run 指定したHSPのAXファイルに制御を移す
22. ○ stop プログラムの中断
23. ○ wait 一定時間待つ

#### マルチメディア制御命令

1. × mci サウンド・動画の再生が可能なMCIにコマンドを送る
2. △ mmload サウンドファイル・動画ファイルの読み込み
3. △ mmplay サウンド・動画の再生
4. △ mmstop サウンド・動画の再生停止

#### メモリ管理関数

1. ○ lpeek バッファから4バイト読み出し
2. ○ peek バッファから1バイト読み出し
3. ○ wpeek バッファから2バイト読み出し

#### メモリ管理命令

1. ○ alloc バッファを確保
2. × comres COMメソッドの結果を返す変数の指定
3. ○ ddim 実数値（小数点数値）型変数・配列変数の確保
4. ○ delmod モジュール型変数の要素削除
5. ○ dim 整数値型変数・配列変数の確保
6. ○ dimtype 指定した型の配列変数を確保
7. × ldim ラベル型配列変数の確保
8. ○ lpoke バッファに4バイト書き込み
9. ○ memcpy メモリブロックのコピー
10. ○ memexpand メモリブロックのバッファサイズを再確保
11. ○ memset メモリブロックのクリア（消去）
12. × newlab ラベル型変数の初期化
13. ○ newmod COMモジュール型変数の作成
14. ○ poke バッファに1バイト書き込み。バッファに文字列の書き込み
15. ○ sdim 文字列型変数・配列変数の確保
16. ○ wpoke バッファに2バイト書き込み

#### 画面制御命令

1. × axobj ActiveXコントロールの設置
2. △ bgscr 枠のないウィンドウを表示・初期化
3. × bmpsave ウィンドウ画面をBMPファイルで保存
4. ○ boxf 四角形の塗りつぶし描画
5. △ buﬀer 仮想のバッファ画面の用意・初期化
6. × celdiv 画像素材タイルのサイズ指定
7. △ celload 仮想画面に画像ファイルの読み込み
8. × celput 画像素材タイルのコピー描画
9. × chgdisp モニタ画面の解像度の変更
10. ○ circle 円形の描画
11. △ cls ウィンドウのクリア・初期化
12. ○ color RGB値のカラー指定
13. △ dialog ダイアログを開く
14. ○ font フォントの適用指定
15. △ gcopy ウィンドウ画面の切り出しコピー描画
16. △ gmode 画面コピーモードの設定
17. △ gradf グラデーションで四角形の描画
18. × grect 回転する四角形で塗りつぶし描画
19. × groll ウィンドウの描画基点の設定
20. × grotate 四角形の回転コピー
21. △ gsel 描画先の変更、ウィンドウの最前面表示・非表示
22. × gsquare 任意の四角形でコピー
23. × gzoom 変倍（拡大・縮小）して画面コピー
24. ○ hsvcolor HSV形式でカラー指定
25. ○ line 直線ラインの描画
26. ○ mes 文字列の描画表示
27. × palcolor 描画パレット設定
28. × palette パレット設定
29. ○ pget 1ドットの点のRGB値を取得
30. ○ picload 画像ファイルの読み込み表示
31. ○ pos 描画位置の指定、オブジェクトの表示位置指定
32. ○ print 文字列の描画表示
33. ○ pset 1ドットの点を描画
34. ○ redraw 描画の停止と反映
35. △ screen ウィンドウの表示・初期化
36. × sendmsg ウィンドウメッセージの送信
37. △ syscolor システムカラーの指定
38. × sysfont システムフォントの選択
39. ○ title タイトルバーの文字列指定
40. × width ウィンドウの表示サイズ・表示位置の指定
41. × winobj Win32コントロール・コモンコントロールの設置

#### 基本入出力関数

1. ○ abs 整数の絶対値を返す
2. ○ absf 実数の絶対値を返す
3. ○ atan アークタンジェント値を返す
4. × callfunc 外部関数の呼び出し
5. ○ cos コサイン値を返す
6. △ dirinfo 各種フォルダパスの取得
7. ○ double 実数値に変換
8. ○ expf 指数を返す
9. ○ getease イージング値を整数で取得
10. ○ geteasef イージング値を実数で取得
11. ○ gettime 現在の日付・曜日・時刻の取得
12. △ ginfo 各種ウィンドウ情報の取得
13. ○ int 文字列を整数値に変換
14. ○ length 配列変数の要素数を返す（1次元）
15. ○ length2 配列変数の要素数を返す（2次元）
16. ○ length3 配列変数の要素数を返す（3次元）
17. ○ length4 配列変数の要素数を返す（4次元）
18. × libptr 外部呼出しコマンドの情報アドレスを取得
19. ○ limit 一定範囲内の整数を返す
20. ○ limitf 一定範囲内の実数を返す
21. ○ logf 対数を返す
22. × objinfo オブジェクトのウィンドウハンドルを取得
23. ○ powf 累乗を求める
24. ○ rnd 乱数を発生
25. ○ sin サイン値を返す
26. ○ sqrt ルート値を返す
27. ○ str 数値を文字列に変換
28. ○ strlen 文字列の長さをバイト単位で取得
29. × sysinfo 各種システム情報の取得
30. ○ tan タンジェント値を返す
31. ○ varptr 変数データのポインタを返す
32. ○ vartype 変数の型を返す
33. × varuse 変数の使用状況を返す

#### 基本入出力制御命令

1. △ getkey キー入力・マウス入力のチェック
2. × mcall COMメソッドの呼び出し
3. × mouse マウスカーソルの表示位置指定。マウスカーソルの非表示
4. ○ randomize 乱数発生パターンの初期化
5. ○ setease イージング関数の計算式を設定
6. △ stick キー入力情報取得

#### 特殊代入命令

1. △ dup クローン変数を作成
2. ○ dupptr ポインタからクローン変数を作成
3. ○ mref 特殊なメモリを変数に割り当て

#### 数学定数

1. ○ M_PI 円周率

#### 文字列操作関数

1. × cnvatos ANSI文字列を通常文字列に変換
2. × cnvwtos Unicode文字列をASCII（シフトJIS）に変換
3. △ getpath ファイルパス文字列の分解
4. ○ instr 指定文字列を検索してインデックス位置を返す
5. △ noteinfo メモリノートパッドの情報取得
6. △ strf 指定文字列への書式変換
7. ○ strmid 文字列を指定位置から指定文字数で切り出し
8. ○ strtrim 文字列から指定文字を取り除く

#### 文字列操作命令

1. × cnvstow ASCII（シフトJIS）文字列をUnicodeに変換
2. ○ getstr 特定区切りでバッファから文字列の切り出し
3. ○ noteadd メモリノートパッドで指定行の追加・変更
4. ○ notedel メモリノートパッドで指定行の削除
5. ○ noteget メモリノートパッドで指定行の取得
6. ○ noteload メモリノートパッドでテキストファイルの読み込み
7. ○ notesave メモリノートパッドでテキストファイルの出力
8. ○ notesel メモリノートパッドで対象バッファの指定
9. ○ noteunsel メモリノートパッドで対象バッファの復帰
10. ○ split 特定区切りで文字列を切り出して各変数に代入
11. × strrep 文字列の置換

#### 標準定義マクロ

1. ○ __date__ 使用時点の日付
2. ○ __ﬁle__ 使用時点で解析されているファイル名
3. × __hsp30__ ver3.0以降使用時
4. ○ __hspver__ HSPバージョン番号
5. ○ __line__ 使用時点で解析されている行番号
6. ○ __time__ 使用時点の時刻
7. ○ _debug デバッグモード時
8. ○ and 論理積(演算子)
9. ○ deg2rad 度をラジアンに変換
10. ○ font_antialias アンチエイリアスでフォント設定
11. ○ font_bold 太文字でフォント設定
12. ○ font_italic イタリック体でフォント設定
13. ○ font_normal 通常のスタイルでフォント設定
14. ○ font_strikeout 打ち消し線付きでフォント設定
15. ○ font_underline 下線付きでフォント設定
16. ○ gmode_add 色加算合成コピーモード
17. ○ gmode_alpha 半透明合成コピーモード
18. ○ gmode_gdi 通常のコピーモード
19. ○ gmode_mem メモリ間コピーモード
20. ○ gmode_pixela ピクセルアルファブレンドコピーモード
21. ○ gmode_rgb0 透明色付きコピーモード
22. ○ gmode_rgb0alpha 透明色付き半透明合成コピーモード
23. ○ gmode_sub 色減算合成コピーモード
24. ○ not 否定(演算子)
25. ○ objinfo_bmscr オブジェクトが配置されているBMSCR構造体のポインタを取得
26. ○ objinfo_hwnd ウィンドウオブジェクトのハンドルを取得
27. ○ objinfo_mode モードおよびオプションデータを取得
28. ○ objmode_guifont デフォルトGUIフォントを設定
29. ○ objmode_normal HSP標準フォントを設定
30. ○ objmode_usefont font命令で選択されているフォントを設定
31. ○ or 論理和(演算子)
32. ○ rad2deg ラジアンを度に変換
33. ○ screen_ﬁxedsize サイズ固定ウィンドウを作成
34. ○ screen_frame 深い縁のあるウィンドウを作成
35. ○ screen_hide 非表示のウィンドウを作成
36. ○ screen_normal 通常のウィンドウを作成
37. ○ screen_palette パレットモードのウィンドウを作成
38. ○ screen_tool ツールウィンドウを作成
39. ○ xor 排他的論理和(演算子)

#### 拡張マルチメディア制御命令

1. × celputm 複数のセルをまとめて描画
2. × mmpan パンニングの設定
3. × mmstat メディアの状態取得
4. × mmvol 音量の設定
5. × setcls 画面クリア設定

#### 拡張入出力制御命令

1. ○ sortget ソート元のインデックスを取得
2. ○ sortnote メモリノート文字列をソート
3. ○ sortstr 配列変数を文字列でソート
4. ○ sortval 配列変数を数値でソート
5. × devcontrol デバイス制御を実行する
6. × devinfo デバイス情報文字列取得
7. × devinfoi デバイス情報値取得
8. × devprm デバイス制御用のパラメーター設定
9. × getreq システムリクエスト取得
10. × gﬁlter テクスチャ補間の設定
11. × mtinfo タッチ情報取得
12. × mtlist ポイントIDリスト取得
13. × setreq システムリクエスト設定

#### macOS版HSPの内蔵命令

1. ○ qins オーディオデータを１サンプル書き込む
2. ○ qpush オーディオデータを１スタック書き込む
3. ○ qstart オーディオシステムを開始
4. ○ qend オーディオシステムを終了
5. ○ qplay オーディオシステムを再生
6. ○ qstop オーディオシステムを停止
7. ○ qvol オーディオシステムのボリュームを設定
8. ○ slider スライダーを表示する
9. ○ box 直線で3Dの箱を描画する
10. ○ antialiasing アンチエイリアシングの設定
11. ○ smooth アンチエイリアシングの設定
12. ○ setcam 3D座標でのカメラ位置を設定
13. ○ onmidi MIDIイベントを設定する

#### macOS版HSPの内蔵関数

1. ○ qframe システムが一度に処理するサンプル数を取得
2. ○ qcount 未再生のオーディオスタック数を取得
3. ○ clock C言語のclock関数の戻り値を取得
4. ○ getmousex スクリーン座標でのマウスのX位置を取得
5. ○ getmousey スクリーン座標でのマウスのY位置を取得
6. ○ getmousedown マウスが押されていたら1を取得
7. ○ qrate システムのサンプリング周波数を取得
8. ○ qpi 円周率を実数で取得
9. ○ rndf 0.0～任意の間の乱数を実数で取得
10. ○ randf 任意～任意の間の乱数を実数で取得
11. ○ getfontfamilies システムが提供するフォント一覧を取得
12. ○ isretina HiDPIモードなら１を取得
13. ○ getretina HiDPIの倍率を取得

#### システム変数

1. × system 未定義
2. ○ hspstat HSPランタイムの情報を取得する
3. ○ hspver HSPのバージョン番号
4. ○ cnt repeat～loopループのカウンター
5. × err エラーコード
6. × stat 色々な命令のステータスなどを代入する汎用システム変数
7. ○ mousex マウスカーソルのX座標
8. ○ mousey マウスカーソルのY座標
9. × mousew マウスホイール値
10. ○ strsize getstr命令で読み出したByte数
11. ○ refstr 文字列を保存する汎用のシステム変数
12. ○ refdval 実数値を保存する汎用のシステム変数
13. ○ looplev repeat～loopのネストレベル
14. ○ sublev サブルーチン(モジュール)のネストレベル
15. × wparam 割り込み時に保存されるWindowsのシステム値(wParam)
16. × lparam 割り込み時に保存されるWindowsのシステム値(lParam)
17. × iparam 割り込み要因を示す値
18. ○ thismod 現在の有効なモジュール変数
19. × notemax メモリノートパッドの行数
20. ○ notesize メモリノートパッドの文字数
21. × hwnd 現在のウィンドウハンドル
22. × hdc 現在のデバイスコンテキスト
23. × hinstance 現在のインスタンスハンドル
24. ○ ginfo_mx スクリーン上のマウスカーソルX座標
25. ○ ginfo_my スクリーン上のマウスカーソルY座標
26. × ginfo_act アクティプなウィンドウID
27. ○ ginfo_sel 操作先ウィンドウID
28. × ginfo_wx1 ウィンドウの左上X座標
29. × ginfo_wy1 ウィンドウの左上Y座標
30. × ginfo_wx2 ウィンドウの右下X座標
31. × ginfo_wy2 ウィンドウの右下Y座標
32. × ginfo_vx ウィンドウのスクロールX座標
33. × ginfo_vy ウィンドウのスクロールY座標
34. × ginfo_sizex ウィンドウ全体のXサイズ
35. × ginfo_sizey ウィンドウ全体のYサイズ
36. × ginfo_winx 画面のクライアントXサイズ
37. × ginfo_winy 画面のクライアントYサイズ
38. × ginfo_sx 画面の初期化Xサイズ
39. × ginfo_sy 画面の初期化Yサイズ
40. × ginfo_mesx メッセージの出力Xサイズ
41. × ginfo_mesy メッセージの出力Yサイズ
42. × ginfo_r 現在設定されているカラーコード(R)
43. × ginfo_g 現在設定されているカラーコード(G)
44. × ginfo_b 現在設定されているカラーコード(B)
45. × ginfo_paluse デスクトップのカラーモード
46. × ginfo_dispx デスクトップ全体のXサイズ
47. × ginfo_dispy デスクトップ全体のYサイズ
48. ○ ginfo_cx カレントポジションのX座標
49. ○ ginfo_cy カレントポジションのY座標
50. × ginfo_intid メッセージ割り込み時のウィンドウID
51. × ginfo_newid 未使用ウィンドウID
52. ○ dir_cur カレントディレクトリ(フォルダ)
53. ○ dir_exe 実行ファイルがあるディレクトリ(フォルダ)
54. × dir_win Windowsディレクトリ(フォルダ)
55. × dir_sys Windowsシステムディレクトリ(フォルダ)
56. × dir_cmdline コマンドライン文字列
57. ○ dir_desktop デスクトップディレクトリ(フォルダ)
58. × dir_mydoc マイドキュメントディレクトリ(フォルダ)

## AltHSPの使い方

AltHSPとは、Javascriptを意識した独自の構文のコードをHSPで動作するコードに変換するコード変換器です。macOS版HSPに内蔵されたコード変換器を使用しすることができます。

### AltHSPの概略 

C#やJavaなどのクラスの構文に近い書き方でモジュール関連の操作を記述できます。例えば次の ようなHSPコードがあるとします。

```
#module a x,y,z
　　#modinit int p1,int p2,int p3
　　　　x=p1:y=p2:z=p3
　　　　return
#global
newmod v,a,1,2,3
```

AltHSPでは次のように書くことができます。

```
class a {
　　var x
　　var y
　　var z
　　init(int p1, int p2, int p3) {
　　　　x=p1
　　　　y=p2
　　　　z=p3
　　}
}
v = new a(1,2,3)
```

### AltHSPの構文 

基本的にHSPと同じ文法です。例えば次のようなHSPプログラムの場合は何も変換しません。

```
screen 0,640,480
mes "メッセージを表示します"
```

### 擬似クラス構文 

HSPはモジュールという機能を持っています。これをクラス構文のように書く機能を提供します。

#### 擬似クラスの作成

```
class クラス名 {
　　...
}
```

classという予約語の後に空白文字を入れて、任意の名前のクラスを作成します。{ ... } で囲まれた部分に、クラスの内容を記述していきます。

#### 擬似メンバ変数 

```
class クラス名 {
　　var 変数名
　　var 変数名
　　...
}
```

擬似メンバ変数とは、クラス内でのみ使用できる変数のことです。class文 の次の行に、１行ずつ書きます。初期化を同時にすることはできません。

#### 擬似コンストラクタ 

```
init(int 引数, str 引数) {
　　...
}
````

インスタンス生成時に呼ばれます。{ ... } の中に処理を記述します。

#### 擬似デストラクタ 

```
deinit {
　　...
}
```

インスタンス削除時に呼ばれます。引数を付けることはできません。

#### 擬似メソッド（命令／関数） 

命令と関数は別々の書き方をします。

命令の場合：

```
func 命令名 int 引数, str 引数 {
　　...
}
```

#### 関数の場合：

```
func 関数名(int 引数, str 引数) {
　　...
　　return 戻り値
}
```

戻り値には任意の文字列あるいは数値を指定できます。引数がない場合は次のように書きます。

命令の場合：

```
func 命令名 {
　　...
}
```

関数の場合：

```
func 関数名() {
　　...
　　return 戻り値
}
```

#### 擬似ローカル変数 

コンストラクタや命令／関数はローカル変数を持つことができます。ローカル変数は { の次の行から、１行ずつ書きます。

コンストラクタの例：

```
init(int 引数, str 引数) {
　　var 変数1
　　var 変数2
　　var 変数3
　　...
}
```

命令／関数の例：

```
func 関数(int 引数, str 引数) {
　　var 変数1　
　　var 変数2
　　var 変数3
　　...
}
```

ローカル変数を用いることで、他のローカル空間の変数との重複を避けることができます。

#### 擬似クラスのインスタンス化 

newを使った代入で、擬似クラスのインスタンスを作成するかのように記述できます。また、クラス名() のようにかっこを必要とします。

```
変数 = new クラス名(引数,引数)
```

引数は、コンストラクタ（init）で指定したものを渡せます。クラスを配列に格納したい場合は、addを使用します。

```
変数 = add クラス名(引数,引数)
変数 = add クラス名(引数,引数)
```

このようにして配列の末尾に追加できます。

配列に関しては、HSPの書き方と互換性がないのでご注意ください。配列は 変数名\[...\]の形で作成します。

#### 命令／関数呼び出し 

```
インスタンス名.命令 引数,引数
```

あるいは、

```
戻り値 = インスタンス名.関数(引数,引数)
```

の形で呼び出します。add を使い配列でインスタンス化した場合は・・・

```
インスタンス名[0].命令 引数,引数
インスタンス名[1].命令 引数,引数
```

というようにして呼び出します。

#### 擬似グローバル変数 

グローバル変数はクラス内を含め、どこからでもアクセスできます。

```
// ファイルの先頭などのグローバルな空間
var 変数名
var 変数名
var 変数名
...
```

宣言の位置に制限はありません。また、代入を同時に行うことはできません。

#### 擬似メンバ変数 

メンバ変数はクラス内からのみアクセスできます。

```
class クラス名 {
　　var 変数名
　　var 変数名
　　var 変数名
　　...
}
```

メンバ変数は class文 に続く行から書きます。代入を同時に行うことはできません。

#### 擬似ローカル変数 

命令や関数の内部でのみ使用できる変数です。

```
func 命令名 {
　　var 変数名
　　var 変数名
　　var 変数名
　　...
}
```

func文 の次の行から書きます。代入を同時に行うことはできません。

### 配列 

配列は次のように扱います。

```
変数名[0] = 100
変数名[1] = 200
...
```

文字列や実数型の配列は事前に必要となる分を確保する必要があります。

```
sdim 変数名,50
変数名[0] = "文字列"
変数名[1] = "文字列"
...
```

配列の書き方は上記の一択となります。HSP本来の書き方とは互換性がなくなるので、ご注意く ださい。

### 繰り返し処理 

#### forループ 

C言語などに近いforループを使うことができます。

```
for i=0; i<10; i++
...
loop
```

セミコロン(;)で3つに区切ったそれぞれに、左から次のように書きます。

- 変数の初期化
- ループの条件
- ループ毎に変数にする処理

これに伴いHSP標準マクロの for文が、使用できなくなるのでご注意ください。

#### eachループ 

配列の内容を１つずつ取り出すことができます。

```
each 配列変数, 要素
　　...
loop
```

要素には変数を指定します。配列変数に格納されている値を順に取り出します。

### 使用上の注意 

#### コメントや空行について 

変換器は//から始まるコメントを削除しますが、それ以外のコメントは削除しません。前後の空白や何もない行は削除されます。

#### 文字列について 

文字列に全角空白を除く空白文字と、日本語を混在させることはできません。例えば次のようなプログラムは意図通りの動作はしません。

```
変数A = " 文字列"
```

このような場合は、全角空白をお使いください。

```
変数A = "　文字列"
```

また日本語が混在する場合、次のような初期化の書き方はできません。

```
変数 = {"
文字列
文字列
"}
```

改行のためのエスケープ文字をお使いください。

```
変数 = “\n文字列\n文字列"
```

#### :記号について 

:記号を使った複数行を書く構文については、変換できないケースがあるかもしれません。

### AltHSPをウェブサイトに組み込む 

Javascript版のAltHSPを使ってAltHSPの機能をウェブサイトに組み込むことができます。

#### 導入 

jQueryを使用していますので、あらかじめ読み込んでおきます。

```
<script src="https://cdnjs.cloudﬂare.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
```

続いて dpAltHSP.js をオンラインからダウンロード（ https://github.com/dolphilia/althsp ）して読み込みます。

```
<script src="dp-althsp.js"></script>
```

#### 使い方 

convertAltHSP関数を使用します。

```
var result = convertAltHSP( 'mes "Hello World!"' );
```

引数には変換したい文字列を指定します。変換されたHSPコードが戻り値です。次の例では、テ キストエリア内のコードをコンバートします。結果は別のテキストエリアに出力します。

```
<textarea id="before">
　　class a {
　　　　var x
　　　　var y
　　　　var z
　　　　init(int p1, int p2, int p3) {
　　　　　　x=p1
　　　　　　y=p2
　　　　　　z=p3
　　　　}
　　}
　　v = new a(1,2,3)
</textarea>
<textarea id="after"></textarea>
<script>
　　var code = $('#before').val();
　　var result = convertAltHSP( code );
　　$('#after').html(result);
</script>
```

### AltHSPのライセンス 

AltHSPはMITライセンスです。Licensed under the MIT License.

### AltHSPの使用について 

どなたでもご自由に使用できます。生成されたコードの使用についての制限もありません。

## macOS版HSPのライセンス

macOS版HSPのコードのうち、[OpenHSP](http://www.onionsoft.net/hsp/openhsp/)から派生しているコードはOpenHSPライセンスに準拠しています。それ以外のコードはMITライセンスです。
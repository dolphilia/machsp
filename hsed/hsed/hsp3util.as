;
; HSP3.1 Utility macros and functions
;
#ifndef __hsp3util__
#define __hsp3util__

#module "hsp3util"

#define WS_VISIBLE 0x10000000
#define WS_CHILD 0x40000000

#define PBM_SETSTEP	1028
#define PBM_STEPIT	1029

#define SBM_SETPOS 224
#define SBM_GETPOS 225
#define SBM_SETRANGE 226
#define SBM_SETRANGEREDRAW 230

;--------------------------------------------------------------------------------

#deffunc bmppalette str _fname

	;	8bitBMPファイルのパレットを取り出す
	;	bmppalette "BMPファイル名"
	;
	exist _fname :if strsize<1078 :return
	dim a,270 : bload _fname,a,1078			;BMPヘッダー読み出し

	if peek(a,$1c)>8	:return			;8bitBMPでなかったらreturn
	if wpeek(a,0)!$4d42	:return			;"BM"チェック：強制終了は避ける
	cols=lpeek(a,$2e)	:if cols=0:cols=256	;色数：cols=0は 256色

	i=$36
	repeat cols
		palette cnt,peek(a,i+2),peek(a,i+1),peek(a,i),cnt=cols-1
		i+=4
	loop
	dim a,0
	return

#deffunc gettimestr var _p1

	;	"hh:mm:ss"の形式で時刻を得て変数に代入する
	;	gettimestr 変数名
	;
	_p1 = strf("%02d:%02d:%02d",gettime(4),gettime(5),gettime(6))
	return

#deffunc getdatestr var _p1

	;	"yyyy/mm/dd"の形式で日付を得て変数に代入する
	;	getdatestr 変数名
	;
	_p1 = strf("%02d/%02d/%02d",gettime(0),gettime(1),gettime(3))
	return

;--------------------------------------------------------------------------------

#deffunc text int _p1

	;	emes命令で表示される文字の待ち時間を設定する
	;	text 表示待ち時間(ms)
	;
	stwait=_p1
	return

#deffunc textmode int _p1, int _p2

	;	emes命令で表示される文字の修飾を設定する
	;	textmode モード, 調整パラメーター
	;		モード0 : 通常の表示
	;		モード1 : 影付き表示
	;		モード2 : 輪郭付き表示
	;		(モード1,2の場合は現在設定されている色が適用されます)
	;		(調整パラメーターを設定すると影や輪郭の距離を修正する
	;		ことができます)
	;
	stmode=_p1
	if stmode<=0 : return
	strval=ginfo_r
	stgval=ginfo_g
	stbval=ginfo_b
	stdiff=1+_p2
	return

#deffunc emes str _p1

	;	１文字づつゆっくりと文字列を表示する
	;	(mes命令と同様の動作)
	;	emes 表示テキスト
	;
	mesmax=strlen(_p1)
	if mesmax<=0 : return
	mestmp=_p1
	messg=""
	mescur=0
	a=0
	orgx=ginfo_cx
	if ( stmode ) {
		strval2=ginfo_r
		stgval2=ginfo_g
		stbval2=ginfo_b
	}

	if stwait<=0 {
		x=ginfo_cx:y=ginfo_cy
		messg=mestmp
		gosub *emes_aft
		return
	}

	repeat
		if mescur>=mesmax : break
		x=ginfo_cx:y=ginfo_cy
		a=peek(mestmp,mescur)
		mescur++
		if a<32 {
			if a=13 {
				if peek(mestmp,mescur)=10 : mescur++
				mes "":pos orgx
			}
			continue
		}
		poke messg,0,a
		poke messg,1,0
		if a>=128 {
			poke messg,1,peek(mestmp,mescur)
			poke messg,2,0
			mescur++
		}
		gosub *emes_aft
		pos x+ginfo_mesx,y
		await stwait
	loop

	mes "":pos orgx
	return

*emes_aft
	if stmode=0 {
		mes messg
		return
	}
	if stmode=1 {
		pos x+stdiff,y+stdiff
		color strval,stgval,stbval
		mes messg
		pos x,y
		color strval2,stgval2,stbval2
		mes messg
		return
	}
	if stmode=2 {
		color strval,stgval,stbval:
		pos x+stdiff,y:mes messg
		pos x-stdiff,y:mes messg
		pos x,y-stdiff:mes messg
		pos x,y+stdiff:mes messg
		pos x,y
		color strval2,stgval2,stbval2
		mes messg
		return
	}
	return


#deffunc gfade int _p1,int _p2,int _p3,int _p4,int _p5

	;
	;	画面のフェードを行なう
	;	(colorで設定された色にフェードする)
	;	gfade レベル, x,y,sx,sy
	;	レベル  = 0～256でレベルを指定する
	;	(x,y)   = フェードを行なう左上
	;	          (省略時は0,0)
	;	(sx,sy) = フェードを行なうサイズ
	;	          (省略時は画面全体)
	;
	x=_p4:if x=0 : x=ginfo_winx
	y=_p5:if y=0 : y=ginfo_winy
	gmode 3,x,y,_p1
	x=_p2+(x/2):y=_p3+(y/2)
	grect x,y,0
	return


#deffunc gfade2 int _src,int _p1,int _p2,int _p3,int _p4,int _p5

	;
	;	画面のフェードを行なう
	;	(設定された画面イメージにフェードする)
	;	gfade src,レベル, x,y,sx,sy
	;	src = フェード元のバッファID
	;	レベル  = 0～256でレベルを指定する
	;	(x,y)   = フェードを行なう左上
	;	          (省略時は0,0)
	;	(sx,sy) = フェードを行なうサイズ
	;	          (省略時は画面全体)
	;
	x=_p4:if x=0 : x=ginfo_winx
	y=_p5:if y=0 : y=ginfo_winy
	gmode 3,x,y,_p1
	pos _p2,_p3:gcopy _src,0,0
	return


;--------------------------------------------------------------------------------

#deffunc statictext str _p1, int _p2, int _p3

	;
	;	スタティックテキストを配置オブジェクトとして生成する
	;	statictext "テキスト",Xサイズ,Yサイズ
	;	(posで指定した位置に表示されます)
	;
	winobj "STATIC",_p1,0,WS_VISIBLE|WS_CHILD,_p2,_p3
	return stat

#deffunc statictext_set int _p1, str _p2

	;
	;	スタティックテキストの内容を書き換える
	;	statictext_set オブジェクトID,"テキスト"
	;
	sendmsg objinfo_hwnd(_p1),$c,0,_p2
	return stat

#deffunc scrollbar int _p1, int _p2

	;
	;	スクロールバーを配置オブジェクトとして生成する
	;	scrollbar Xサイズ,Yサイズ
	;	(posで指定した位置に表示されます)
	;
	winobj "SCROLLBAR","",0,WS_VISIBLE|WS_CHILD,_p1,_p2
	return stat


#deffunc progbar int _p1, int _p2

	;
	;	プログレスバーを配置オブジェクトとして生成する
	;	progbar Xサイズ,Yサイズ
	;	(posで指定した位置に表示されます)
	;
	winobj "msctls_progress32","",0,WS_VISIBLE|WS_CHILD,_p1,_p2
	return stat

#deffunc progbar_step int _p1

	;
	;	プログレスバーを1ステップ進める
	;	progbar_step オブジェクトID
	;
	sendmsg objinfo_hwnd(_p1),PBM_STEPIT,0,0
	return

#deffunc progbar_set int _p1, int _p2

	;
	;	プログレスバーのステップ増分を設定する
	;	progbar_step オブジェクトID, 増分
	;
	sendmsg objinfo_hwnd(_p1),PBM_SETSTEP,_p2,0
	return

;--------------------------------------------------------------------------------

#deffunc note2array array _p1, str _p2;, local mestmp

	;
	;	複数行の文字列を行ごとに配列変数に代入する
	;	note2array 変数,"文字列"
	;	("文字列"で指定した内容を配列変数に変換します)
	;	(配列は１次元配列になります)
	;
	;	notegetを利用したスクリプトからgetstrを利用した者に変更すると
	;	より高速になりますが、1行あたりの文字列の長さに制限がかかります。
	;	どちらが良いでしょうか？
	mestmp = _p2
	notesel mestmp
	_notemax = notemax
	if _notemax<=1 : _p1 = _p2 : return
	sdim _p1, 64, _notemax
	repeat _notemax
		noteget _p1(cnt), cnt
	loop
	noteunsel
	return

#deffunc array2note var _p1, array _p2

	;
	;	文字列型の配列変数を複数行文字列として取得する
	;	array2note 変数1,変数2
	;	(変数2で指定した１次元の配列変数を変数1(複数行文字列)に変換します)
	;	(扱える配列は１次元配列のみになります)
	;
	if length2(_p2) > 0 : dialog "array2note:error" : return

	index = 0 : len = 1
	foreach _p2
		len += strlen(_p2(cnt)) + 2
	loop
	sdim _p1, len
	foreach _p2
		poke _p1, index, _p2(cnt)
		index += strsize
		poke _p1, index, "\n"
		index += 2
	loop
	return

#deffunc arraysave str _p1, array _p2, local stmp

	;
	;	文字列型の配列変数をファイルにセーブする
	;	arraysave "ファイル名",変数
	;	(複数行文字列に変換してセーブします)
	;	(扱える配列は１次元配列のみになります)
	;
	array2note stmp, _p2
	notesel stmp
	notesave _p1
	noteunsel
	return

#deffunc arrayload str _p1, array _p2, local stmp

	;
	;	テキストファイルを文字列型の配列変数に読み込む
	;	arrayload "ファイル名",変数
	;	(複数行文字列の行を配列要素に変換してセーブします)
	;	(扱える配列は１次元配列のみになります)
	;
	notesel stmp
	noteload _p1
	noteunsel
	note2array _p2,stmp
	return


;--------------------------------------------------------------------------------

#global


#endif

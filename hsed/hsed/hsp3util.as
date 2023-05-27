;
;HSP3
.1
Utility
macros
and
functions
;
#
ifndef
__hsp3util__
#
define
__hsp3util__

#
module
"hsp3util"

#
define
WS_VISIBLE
0x10000000
#
define
WS_CHILD
0x40000000

#
define
PBM_SETSTEP
1028
#
define
PBM_STEPIT
1029

#
define
SBM_SETPOS
224
#
define
SBM_GETPOS
225
#
define
SBM_SETRANGE
226
#
define
SBM_SETRANGEREDRAW
230

;--------------------------------------------------------------------------------

#
deffunc
bmppalette
str
_fname

;8
bitBMP�t�@�C���̃p���b�g�����o��
	;bmppalette
"BMP�t�@�C����"
;
exist
_fname :if strsize < 1078 :
return
dim
a, 270
:
bload
_fname, a, 1078;
BMP�w�b�_�[�ǂݏo��

	if peek(a, $1c) > 8    :
return;
8
bitBMP�łȂ�������return
if wpeek(a, 0)!$4d42
:
return;
"BM"�`�F�b�N�F�����I���͔�����
	cols = lpeek(a, $2e)
:
if cols = 0:
cols = 256;�F���Fcols = 0�� 256�F

i = $36
repeat
cols
palette
cnt, peek(a, i + 2), peek(a, i + 1), peek(a, i), cnt = cols - 1
i += 4
loop
dim
a, 0
return

#
deffunc
gettimestr var _p1

;"hh:mm:ss"�̌`���Ŏ����𓾂ĕϐ��ɑ������
	;gettimestr �ϐ���
	;
_p1 = strf("%02d:%02d:%02d", gettime(4), gettime(5), gettime(6))
return

#
deffunc
getdatestr var _p1

;"yyyy/mm/dd"�̌`���œ��t�𓾂ĕϐ��ɑ������
	;getdatestr �ϐ���
	;
_p1 = strf("%02d/%02d/%02d", gettime(0), gettime(1), gettime(3))
return
    ;
--------------------------------------------------------------------------------

#
deffunc
text
int
_p1

;emes���߂ŕ\������镶���̑҂����Ԃ�ݒ肷��
	;text �\���҂�����(ms)
;
stwait = _p1
return

#
deffunc
textmode
int
_p1, int
_p2

;emes���߂ŕ\������镶���̏C����ݒ肷��
	;textmode ���[�h, �����p�����[�^�[
;		���[�h0 : �
ʏ�̕\��
	;		���[�h1 : �
e�t���\��
	;		���[�h2 : �֊s�t���\��
	;(���[�h1, 2�̏ꍇ�͌��ݐݒ肳��Ă���F���K�p����܂�)
;(�����p�����[�^�[��ݒ肷��Ɖe��֊s�̋������C������
	;		���Ƃ��ł��܂�)
;
stmode = _p1
if stmode <= 0 :
return
strval = ginfo_r
stgval = ginfo_g
stbval = ginfo_b
stdiff = 1 + _p2
return

#
deffunc
emes
str
_p1

;	�P�����Â������ƕ������\������
	;(mes���߂Ɠ��l�̓���)
;emes �\���e�L�X�g
;
mesmax = strlen(_p1)
if mesmax <= 0 :
return
mestmp = _p1
messg = ""
mescur = 0
a = 0
orgx = ginfo_cx
if (stmode) {
    strval2 = ginfo_r
    stgval2 = ginfo_g
    stbval2 = ginfo_b
}

if stwait <= 0 {
    x = ginfo_cx
:
    y = ginfo_cy
    messg = mestmp
    gosub * emes_aft
    return
}

repeat
if mescur >= mesmax :
break
x = ginfo_cx
:
y = ginfo_cy
a = peek(mestmp, mescur)
mescur++
if a < 32 {
    if a = 13 {
        if peek(mestmp, mescur) = 10 :
        mescur++
        mes
        ""
    :
        pos
        orgx
    }
    continue
}
poke
messg, 0, a
poke
messg, 1, 0
if a >= 128 {
    poke
    messg, 1, peek(mestmp, mescur)
    poke
    messg, 2, 0
    mescur++
}
gosub * emes_aft
pos
x + ginfo_mesx, y
await
stwait
loop

mes
""
:
pos
orgx
return

*
emes_aft
if stmode = 0 {
    mes
    messg
    return
}
if stmode = 1 {
    pos
    x + stdiff, y + stdiff
    color
    strval, stgval, stbval
    mes
    messg
    pos
    x, y
    color
    strval2, stgval2, stbval2
    mes
    messg
    return
}
if stmode = 2 {
    color
    strval, stgval, stbval
:
    pos
    x + stdiff, y
:
    mes
    messg
    pos
    x - stdiff, y
:
    mes
    messg
    pos
    x, y - stdiff
:
    mes
    messg
    pos
    x, y + stdiff
:
    mes
    messg
    pos
    x, y
    color
    strval2, stgval2, stbval2
    mes
    messg
    return
}
return


#
deffunc
gfade
int
_p1, int
_p2, int
_p3, int
_p4, int
_p5

;
;	��ʂ̃t�F�[�h���s�Ȃ�
	;(color�Őݒ肳�ꂽ�F�Ƀt�F�[�h����)
;gfade ���x��,
x, y, sx, sy
;	���x��  = 0�`256�Ń��x�����w�肷��
	;(x, y) = �t�F�[�h���s�Ȃ�����
	;(�ȗ�����0, 0
)
;(sx, sy) = �t�F�[�h���s�Ȃ��T�C�Y
;(�ȗ����͉�ʑS��)
;
x = _p4
:
if x = 0 :
x = ginfo_winx
y = _p5
:
if y = 0 :
y = ginfo_winy
gmode
3, x, y, _p1
x = _p2 + (x / 2)
:
y = _p3 + (y / 2)
grect
x, y, 0
return


#
deffunc
gfade2
int
_src, int
_p1, int
_p2, int
_p3, int
_p4, int
_p5

;
;	��ʂ̃t�F�[�h���s�Ȃ�
	;(�ݒ肳�ꂽ��ʃC���[�W�Ƀt�F�[�h����)
;gfade
src,���x��,
x, y, sx, sy
;src = �t�F�[�h���̃o�b�t�@ID;    ���x��  = 0�`256�Ń��x�����w�肷��
	;(x, y) = �t�F�[�h���s�Ȃ�����
	;(�ȗ�����0, 0
)
;(sx, sy) = �t�F�[�h���s�Ȃ��T�C�Y
;(�ȗ����͉�ʑS��)
;
x = _p4
:
if x = 0 :
x = ginfo_winx
y = _p5
:
if y = 0 :
y = ginfo_winy
gmode
3, x, y, _p1
pos
_p2, _p3
:
gcopy
_src, 0, 0
return
    ;
--------------------------------------------------------------------------------

#
deffunc
statictext
str
_p1, int
_p2, int
_p3

;
;	�X�^�e�B�b�N�e�L�X�g��z�u�I�u�W�F�N�g�Ƃ��Đ�������
	;statictext
"�e�L�X�g", X�T�C�Y, Y�T�C�Y
;(pos�Ŏw�肵���ʒu�ɕ\������܂�)
;
winobj
"STATIC", _p1, 0, WS_VISIBLE | WS_CHILD, _p2, _p3
return stat

#
deffunc
statictext_set
int
_p1, str
_p2

;
;	�X�^�e�B�b�N�e�L�X�g�̓��e������������
	;statictext_set �I�u�W�F�N�gID, "�e�L�X�g"
;
sendmsg
objinfo_hwnd(_p1), $c, 0, _p2
return stat

#
deffunc
scrollbar
int
_p1, int
_p2

;
;	�X�N���[���o�[��z�u�I�u�W�F�N�g�Ƃ��Đ�������
	;scrollbar
X�T�C�Y, Y�T�C�Y
;(pos�Ŏw�肵���ʒu�ɕ\������܂�)
;
winobj
"SCROLLBAR", "", 0, WS_VISIBLE | WS_CHILD, _p1, _p2
return stat


#
deffunc
progbar
int
_p1, int
_p2

;
;	�v���O���X�o�[��z�u�I�u�W�F�N�g�Ƃ��Đ�������
	;progbar
X�T�C�Y, Y�T�C�Y
;(pos�Ŏw�肵���ʒu�ɕ\������܂�)
;
winobj
"msctls_progress32", "", 0, WS_VISIBLE | WS_CHILD, _p1, _p2
return stat

#
deffunc
progbar_step
int
_p1

;
;	�v���O���X�o�[��1�X�e�b�v�i�߂�
	;progbar_step �I�u�W�F�N�gID
;
sendmsg
objinfo_hwnd(_p1), PBM_STEPIT, 0, 0
return

#
deffunc
progbar_set
int
_p1, int
_p2

;
;	�v���O���X�o�[�̃X�e�b�v������ݒ肷��
	;progbar_step �I�u�W�F�N�gID, ����
	;
sendmsg
objinfo_hwnd(_p1), PBM_SETSTEP, _p2, 0
return
    ;
--------------------------------------------------------------------------------

#
deffunc
note2array
array
_p1, str
_p2;
,
local
mestmp

;
;	�����s�̕�������s���Ƃɔz��ϐ��ɑ������
	;note2array �ϐ�,
"������"
;("������"�Ŏw�肵�����e��z��ϐ��ɕϊ����܂�)
;(�z��͂P�����z��ɂȂ�܂�)
;
;noteget�𗘗p�����X�N���v�g����getstr�𗘗p�����҂ɕύX�����
	;	��荂���ɂȂ�܂����A1�s������̕�����̒����ɐ�����������܂��B
;	�ǂ��炪�ǂ��ł��傤���H
mestmp = _p2
notesel
mestmp
_notemax = notemax
if _notemax <= 1 :
_p1 = _p2
:
return
sdim
_p1, 64, _notemax
repeat
_notemax
noteget
_p1(cnt), cnt
loop
noteunsel
return

#
deffunc
array2note var _p1, array
_p2

;
;	������^�̔z��ϐ��𕡐��s������Ƃ��Ď擾����
	;array2note �ϐ�1,�ϐ�2
;(�ϐ�2�Ŏw�肵���P�����̔z��ϐ���ϐ�1(�����s������)�ɕϊ����܂�)
;(������z��͂P�����z��݂̂ɂȂ�܂�)
;
if length2(_p2) > 0 :
dialog
"array2note:error"
:
return

index = 0
:
len = 1
foreach
_p2
len += strlen(_p2(cnt)) + 2
loop
sdim
_p1, len
foreach
_p2
poke
_p1, index, _p2(cnt)
index += strsize
poke
_p1, index, "\n"
index += 2
loop
return

#
deffunc
arraysave
str
_p1, array
_p2, local
stmp

;
;	������^�̔z��ϐ����t�@�C���ɃZ�[�u����
	;arraysave
"�t�@�C����",�ϐ�
	;(�����s������ɕϊ����ăZ�[�u���܂�)
;(������z��͂P�����z��݂̂ɂȂ�܂�)
;
array2note
stmp, _p2
notesel
stmp
notesave
_p1
noteunsel
return

#
deffunc
arrayload
str
_p1, array
_p2, local
stmp

;
;	�e�L�X�g�t�@�C���𕶎���^�̔z��ϐ��ɓǂݍ���
	;arrayload
"�t�@�C����",�ϐ�
	;(�����s������̍s��z��v�f�ɕϊ����ăZ�[�u���܂�)
;(������z��͂P�����z��݂̂ɂȂ�܂�)
;
notesel
stmp
noteload
_p1
noteunsel
note2array
_p2, stmp
return
    ;
--------------------------------------------------------------------------------

#
global


#
endif

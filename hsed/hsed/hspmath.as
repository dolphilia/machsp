#
ifndef
INC__MATH_AS
#
define
INC__MATH_AS

// �萔
#
define
M_E
2.7182818284590452354;
e
#
define
M_LOG2E
1.4426950408889634074;
log_2(e)
#
define
M_LOG10E
0.43429448190325182765;
log_10(e)
#
define
M_LN2
0.69314718055994530942;
log_e(2)
#
define
M_LN10
2.30258509299404568402;
log_e(10)
#
define
M_SQRTPI
1.77245385090551602792981; ���
#
define
M_SQRT2
1.41421356237309504880; ��2
#
define
M_SQRT3
1.73205080756887719000; ��3

// double�̌��x
#
const DBL_DIG
15;
10�i���ŗL���Ȍ���
#
define
DBL_EPSILON
0.00000000000000022204460492503131;
1.0�Ƃ��̎��ɑ傫���l�Ƃ̍�
#
const DBL_MANT_DIG
53; ��������bit��
#
define
DBL_MAX
double("1.7976931348623158e+308"); �ő�l
#
const DBL_MAX_10_EXP
308;
10�i���ł̎w�����̍ő�l
#
const DBL_MAX_EXP
1024;
2�i���ł̎w�����̍ő�l
#
define
DBL_MIN
double("2.2250738585072014e-308");
0�𒴂���ŏ��̒l
#
const DBL_MIN_10_EXP
-307;
10�i���ł̎w�����̍ŏ��l
#
const DBL_MIN_EXP
-1021;
2�i���ł̎w�����̍ŏ��l

// int�̌��x
#
const INT_DIGIT
32;
2�i���ŗL���Ȍ���
#
const INT_DIGIT10
9;
10�i���ŗL���Ȍ���
#
const INT_MAX
2147483647; �ő�l
#
const INT_MIN
-INT_MAX - 1; �ŏ��l

#
define
ctype
pow( % 1,
%
2
)
powf(( % 1), ( % 2
))
;x ^ y
#
define
ctype
log10( % 1
)
(logf( % 1) / logf(10)
)
;log_10(x)
#
define
ctype
log2( % 1
)
(logf( % 1) / logf(2)
)
;log_2(x)

#
define
ctype
asin( % 1
)
atan(( % 1), sqrt(1.0 - double( % 1) * ( % 1
)))
;sin(y) = x�ƂȂ�y
#
define
ctype
acos( % 1
)
atan(sqrt(1.0 - double( % 1) * ( % 1)
),
( % 1
))
;cos(y) = x�ƂȂ�y

#
define
ctype
sinh( % 1
)
((expf( % 1) - expf(-( % 1))
)/
2
)
;sinh(x)
#
define
ctype
cosh( % 1
)
((expf( % 1) + expf(-( % 1))
)/
2
)
;cosh(x)
#
define
ctype
tanh( % 1
)
(sinh( % 1) / cosh( % 1
))
;tanh(x)

#
define
ctype
asinh( % 1
)
logf(sqrt(double( % 1) * ( % 1) + 1.0
)
+( % 1
))
;sinh(y) = x�ƂȂ�y
#
define
ctype
acosh( % 1
)
logf(sqrt(double( % 1) * ( % 1) - 1.0
)
+( % 1
))
;cosh(y) = x�ƂȂ�y
#
define
ctype
atanh( % 1
)
(logf((1.0 + ( % 1)) / (1.0 - ( % 1))
)/
2.0
)
;tanh(y) = x�ƂȂ�y

#
define
ctype
isfinite( % 1
)
(( % 1) * 0 = 0
)
; �L���^������񐔂̔���
#
define
ctype
isnan( % 1
)
(( % 1)
!( % 1
))
; �񐔂̔���

#
define
ctype
round( % 1
)
double(strf("%%0.0f", % 1)
)
; �l�̌ܓ�
#
define
ctype
sgn( % 1
)
((( % 1) > 0) - (( % 1) < 0
))
; ����
#
define
ctype
intf( % 1
)
round((-0.5) * sgn( % 1) + ( % 1
))
;0�̕����֊ۂ�
#
define
ctype
floor( % 1
)
((intf( % 1) - (( % 1) < intf( % 1)
)))
; ���̕����֊ۂ�
#
define
ctype
ceil( % 1
)
(-floor(-( % 1))
)
; ���̕����֊ۂ�
#
define
ctype
fmod( % 1,
%
2
)
(( % 1)\( % 2
))
; ���W����

#
define
ctype
distance2( % 1,
%
2
)
sqrt((double( % 1) - % 2) * (double( % 1) - % 2
)
+(double( % 1(1)) - % 2(1)
)*
(double( % 1(1)) - % 2(1)
))
;2��������

#
endif;
!defined(INC__MATH_AS)

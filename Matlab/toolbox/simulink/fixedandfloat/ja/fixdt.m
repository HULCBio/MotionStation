% fixdt  - 固定小数点または浮動小数点データタイプを記述するオブジェクトの作
%          成
%
%
% このデータタイプオブジェクトは、固定小数点データタイプをｻﾎﾟｰﾄするSimulinkブ
% ロックに渡されます。
%
% 利用法1: Fixed-Point Data Type With Unspecified scaling ?X?P?[???"?O?I'
% 1/4?I?u???b?N?p?‰???[?^?E?a?A?A??'e?3?e?U?・?B
%
% FIXDT( Signed, WordLength )
%
% 利用法2: Fixed-Point Data Type With Binary point scaling
%
% FIXDT( Signed, WordLength, FractionLength )
%
% 利用法3: Slope and Bias scaling
%
% FIXDT( Signed, WordLength, TotalSlope, Bias ) ?U?1/2?I FIXDT( Signed,
% WordLength, SlopeAdjustmentFactor, FixedExponent, Bias )
%
% 利用法4: Data Type Name String
%
% FIXDT( DataTypeNameString ) ?U?1/2?I [DataType,IsScaledDouble] = FIXDT
% ( DataTypeNameString )
%
% データタイプ名文字列は、Simulinkモデルの信号ラインに表示されるものと同じ文
% 字列です。端子データタイプを表示するためのオプション設定は、Simulinkの書式メ
% ニューの下にあります。
%
% 標準データタイプを用いた例は、以下の通りです。
%
% FIXDT('double')
% FIXDT('single')
% FIXDT('uint8')
% FIXDT('uint16')
% FIXDT('uint32')
% FIXDT('int8')
% FIXDT('int16')
% FIXDT('int32')
% FIXDT('boolean')
%
% 固定小数点データタイプ名のキー：
%
% Simulinkデータタイプ名は、32文字よりも少ない有効なMATLAB識別子
% であることが必須です。
% 固定小数点データタイプは、つぎの規則を用いて符号化されます。
%
% Container
%
% 'ufix#'  unsigned with # bits  Ex.
% ufix3   is unsigned   3 bits 'sfix#'  signed   with # bits  Ex.
% sfix128 is signed   128 bits
% 'flts#'  scaled double data type override of sfix#
% 'fltu#'  scaled double data type override of ufix#
%
% Number encoding
%
% 'n'      minus sign,           Ex.
% 'n31' equals -31 'p'      decimal point         Ex.
% '1p5' equals 1.5 'e'      power of 10 exponent  Ex.
% '125e18' equals 125*(10^(18))
%
% Scaling Terms from the fixed-point scaling equation
%
% RealWorldValue = S * StoredInteger + B
% または
% RealWorldValue = F * 2^E * StoredInteger + B
%
% 'E'      FixedExponent           if S not given, default is 0
% 'F'      SlopeAdjustmentFactor   if S not given, default is 1
% 'S'      TotalSlope              if E not given, default is 1
% 'B'      Bias                    default 0
%
% Examples using integers with non-standard number of bits
%
% FIXDT('ufix1')       Unsigned  1 bit
% FIXDT('sfix77')      Signed   77 bits
%
% 小数点スケーリングを用いた例
%
% FIXDT('sfix32_En31')    Fraction length 31
%
% 勾配とバイアススケーリングを用いた例
%
% FIXDT('ufix16_S5')          TotalSlope 5
% FIXDT('sfix16_B7')          Bias 7
% FIXDT('ufix16_F1p5_En50')   SlopeAdjustmentFactor 1.
% 5  FixedExponent -50FIXDT('ufix16_S5_B7')       TotalSlope 5, Bias 7
% FIXDT('sfix8_Bn125e18')     Bias -125*10^18
%
% Scaled Doubles
%
% Scaled doubles?f?[?^?^?C?v?I?A?e?X?g?A?f?o?b?O?@"\?I?1/2?s?I?a?I?A?・?B
% Scaled doubles?I?A2?A?I?d???a-??1/2?3?e?e?A?"?E"-?¶?μ?U?・?B
% 最初に、整数または固定小数点データタイプが、Simulinkブロックのマスクに入りま
% す。つぎに、
% ?a-v?E?e?I?T?u?V?X?e???I?f?[?^?^?C?v?a?A?X?P?[???"?O?3?e?1/2double?E?I?
% Xされます。
% このことが発生するとき、'sfix16_En7'?I?a???E?f?[?^?^?C?v?I?A?X?P?[???"?
% O?3?e?1/2doubles?f?[?^?^?C?v'flts16_En7'?E?I?X?3?e?U?・?BFIXDT?I?A?‰?I?
% o-I?I?A?I???W?i???Iデータタイプ'sfix16_En7'?a"n?3?e?A?a?A? ?e?￠?I?X?P?[?
% ??"?O?3?e?1/2double?A? ?e'flts16_En7'?a"n?3?e?e?A?a"￣?¶?A?・?B
% オプションの2番目の出力引数は、入力がスケーリングされたdoubleデータタイプで
% ある場合にのみ真です。
%
% 参考 : SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.


% Copyright 1994-2003 The MathWorks, Inc.

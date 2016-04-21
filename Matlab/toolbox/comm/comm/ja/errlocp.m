% ERRLOCP   BCH と リードソロモン復号に関連した誤り位置多項式を計算します。
% SIGMA は、昇ベキの順で多項式の係数を示す行ベクトルです。SYNDROME は、
% 長さ 2*T の行ベクトルで、コードワードのシンドロームです。T はコードの
% 誤り訂正能力です。FIELD は、GF(2m) のすべての要素をリストする行列です。
%
% type_flag = 1 の場合、ERRLOCP は、Berlekamp アルゴリズムを使います。
% type_flag = 0 の場合、ERRLOCP は、簡略化した方法を使います。この簡略化
% した方法を使用できるのは、2値符号に対してのみです。  


%       Wes Wang 10/5/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.5.4.1 $
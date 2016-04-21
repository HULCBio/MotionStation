% BESSELY   第2種Bessel関数
% 
% Y = BESSELY(NU,Z) は、第2種Bessel関数 Y_nu(Z) です。次数 NU は、整数
% である必要はありませんが、実数でなければなりません。引数 Z は、複素数
% でも構いません。Z が正のとき、結果は実数になります。
%
% NU と Z が同じ大きさの配列の場合は、結果の配列も同じ大きさになります。
% いずれかの入力がスカラの場合は、もう一方の入力のサイズと同じ大きさに
% 拡張されます。1つの入力が行ベクトルで、他の入力が列ベクトルの場合、
% 結果は、関数値からなる2次元のテーブルになります。
%
% Y = BESSELY(NU,Z,1) は、exp(-abs(imag(z))) で Y_nu(z) をスケーリング
% します。
%
% [Y,IERR] = BESSELY(NU,Z) は、エラーフラグの配列も出力します。
%     ierr = 1   引数が間違っています。
%     ierr = 2   オーバフローでInfを出力します。
%     ierr = 3   引数を減らすことにより、精度が低下します。
%     ierr = 4   zまたはNUが大き過ぎることにより、精度が低下します。
%     ierr = 5   収束しません。NaNを出力します。
%
% 例題:
%
% bessely(3:9,(0:.2:10)')は、Abramowitz と Stegunの著"Handbook of 
% Mathematical Functions"の399ページに記されている表を作成します。
%
% このM-ファイルは、D. E. AmosによるFortranライブラリのMEXインタフェース
% を使用します。
%
% 参考：BESSELJ, BESSELI, BESSELK, BESSELH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:56 $

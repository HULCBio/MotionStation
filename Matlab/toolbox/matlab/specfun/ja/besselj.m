% BESSELJ   第1種Bessel関数
% 
% J = BESSELJ(NU,Z) は、第1種Bessel関数 J_nu(Z) です。次数 NU は整数で
% ある必要はありませんが、実数でなければなりません。引数 Z は、複素数で
% も構いません。Z が正のとき、結果は実数になります。
%
% NU と Z が同じ大きさの配列の場合は、結果の配列も同じ大きさになります。
% いずれかの入力がスカラの場合は、もう一方の入力のサイズと同じ大きさに
% 拡張されます。1つの入力が行ベクトルで、他の入力が列ベクトルの場合、
% 結果は、関数値からなる2次元のテーブルになります。
%
% J = BESSELJ(NU,Z,1) は、exp(-abs(imag(z))) で、J_nu(z) をスケーリング
% します。
%
% [J,IERR] = BESSELJ(NU,Z) は、エラーフラグの配列も出力します。
%     ierr = 1   引数が間違っています。
%     ierr = 2   オーバフローでInfを出力します。
%     ierr = 3   引数を減らすことにより、精度が低下します。
%     ierr = 4   zまたはNUが大き過ぎることにより、精度が低下します。
%     ierr = 5   収束しません。NaNを出力します。
%
% 例題:
%
% besselj(3:9,(0:.2:10)')は、Abramowitz と Stegunの著"Handbook of 
% Mathematical Functions"の398ページに記されている表を作成します。
%
% MEMBRANE は、BESSELJ を使って、The MathWorksのロゴのL型膜で使用される
% ある次数のBessel関数を作成します。
%
% このM-ファイルは、D. E. AmosによるFortranライブラリのMEXインタフェース
% を使用します。
%
% 参考：BESSELY, BESSELI, BESSELK, BESSELH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:54 $

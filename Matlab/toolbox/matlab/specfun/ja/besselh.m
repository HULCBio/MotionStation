% BESSELH   第3種のBessel関数(Hankel関数)
% 
% K = 1または2に対して、H = BESSELH(NU,K,Z) は、複素配列 Z の各要素に
% 対して、Hankel 関数 H1_nu(Z) または H2_nu(Z) を計算します。
%
% H = BESSELH(NU,Z) は、K = 1 を使います。
% H = BESSELH(NU,1,Z,1) は、exp(-i*z) で H1_nu(z) をスケーリングします。
% H = BESSELH(NU,2,Z,1) は、exp(+i*z) でH2_nu(z) をスケーリングします。
%
% NU と Z が同じ大きさの配列の場合は、結果の配列も同じ大きさになります。
% どちらかの入力がスカラの場合は、もう一方の入力のサイズと同じ大きさに
% 拡張されます。1つの入力が行ベクトルで、他の入力が列ベクトルの場合、
% 結果は、関数値からなる2次元のテーブルになります。
%
% [H,IERR] = BESSELH(NU,K,Z) は、エラーフラグの配列も出力します。
%     ierr = 1   引数が間違っています。
%     ierr = 2   オーバフローで Infを出力します。
%     ierr = 3   引数を減らすことにより、精度が低下します。
%     ierr = 4   zまたはNUが大き過ぎることにより、精度が低下します。
%     ierr = 5   収束しません。NaNを出力します。
%
% Hankel関数とBessel関数の関係は、つぎのようになります。
%
%     besselh(nu,1,z) = besselj(nu,z) + i*bessely(nu,z)
%     besselh(nu,2,z) = besselj(nu,z) - i*bessely(nu,z)
%
% 例題:
% この例は、Abramowitz と Stegun著"Handbook of Mathematical Functions"
% の359ページに記されている、Hankel関数H1_0(z)のモジュラスと位相のコン
% タープロットを作成します。
%
%     [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%     H = besselh(0,1,X+i*Y);
%     contour(X,Y,abs(H),0:0.2:3.2)、hold on
%     contour(X,Y,(180/pi)*angle(H),-180:10:180); hold off
%
% このM-ファイルは、D. E. AmosによるFortranライブラリのMEXインタフェース
% を使用します。
%
% 参考：BESSELJ, BESSELY, BESSELI, BESSELK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:52 $

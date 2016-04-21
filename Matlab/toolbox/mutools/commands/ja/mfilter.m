% function sys = mfilter(fc,ord,type,psbndr)
%
% 単入力、単出力アナログフィルタをSYSTEM行列として計算します。カットオフ
% 周波数(Hertz)をFC、フィルタの次数をORDとします。文字列変数TYPEは、つぎ
% のようにフィルタのタイプを指定します。
%
%  'butterw'     Butterworth
%  'cheby'       Chebyshev
%  'bessel'      Bessel
%  'rc'          resistor/capacitorフィルタ
%
% 各々のフィルタのdcゲイン(偶数次数のChebyshevを除く)は1とします。引数
% PSBNDR は、Chebyshevの通過帯域でリップルの変動の許容範囲を指定します
% (単位はdB)。カットオフ周波数では、大きさは-PSBNDR dBです。偶数次数の
% Chebyshevフィルタでは、DCゲインは、-PSBNDR dBです。
%
% Besselフィルタは、リカーシブな多項式を使って計算されます。これは、高次
% のフィルタ(8次以上)では、条件数が悪くなります。
%



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

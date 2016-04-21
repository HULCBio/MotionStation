% REFCURVE   基準のカーブ(多項式)を表示しているプロットに追加
%
% REFCURVE(P) は、カレントのfigureに、与えられた多項式係数を加えます。
% H = REFCURVE(P) は、lineオブジェクトのハンドル番号を H に出力します。
% REFCURVE を入力引数なしに実行すると、関数 Y = 0 をプロットします。
% 例題： 
%       y = p(1)*x^d + p(2)*x^(d-1) + ... + p(d)*x + p(d+1)
%       d 次の多項式を示します。
%       p(1) は、最高次数の項になることに注意してください。
%
% 参考 : POLYFIT, POLYVAL.


%   B.A. Jones 2-3-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:47 $

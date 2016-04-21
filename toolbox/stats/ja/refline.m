% REFLINE   プロットに基準線を付加
%
% REFLINE(SLOPE,INTERCEPT) は、カレントのfigureに設定した SLOPE と 
% INTERCEPT をもつラインを加えます。
%
% REFLINE(SLOPE) は、figureに、つぎの式で表わされるラインを加えます。
% 
%        y = SLOPE(2) + SLOPE(1)*x 
% 
% ここで、SLOPE は、2要素ベクトルです。
%
% H = REFLINE(SLOPE,INTERCEPT) は、lineオブジェクトのハンドル番号を H に
% 出力します。
%
% REFLINE を引数なしで実行すると、カレントのfigureの中の各lineオブジェクト
% 上に最小二乗ラインを重ね書きします(LineStyles '-','--','.-' は除きます)。
%
% 参考 : POLYFIT, POLYVAL.


%   B.A. Jones 2-2-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:50 $

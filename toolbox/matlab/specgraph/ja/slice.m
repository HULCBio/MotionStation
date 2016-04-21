% SLICE   ボリュームスライスプロット
% 
% SLICE(X,Y,Z,V,Sx,Sy,Sz) は、ベクトル Sx,Sy,Sz の点で、x,y,z方向にスライス
% を描画します。配列 X,Y,Z は、V に対する座標を定義し、単調で、(MESHGRID
% で出力されるような)3次元の格子形でなければなりません。各点でのカラーは、
% 体積 V の3次元補間によって決定されます。V は、M*N*P の配列です。 
%
% SLICE(X,Y,Z,V,XI,YI,ZI) は、配列 XI,YI,ZI で定義されたサーフェスに対して、
% 体積 V のスライスを描画します。
%
% SLICE(V,Sx,Sy,Sz) または SLICE(V,XI,YI,ZI) は、X = 1:N、Y = 1:M、Z = 1:P
% と仮定します。
%
% SLICE(...,'method') は、使用する補間方法を指定します。'method' は、
% 'linear'、'cubic'、'nearest' のいずれかです。'linear' はデフォルトです
% (INTERP3 を参照)。
%
% SLICE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = SLICE(...) は、SURFACEオブジェクトのハンドル番号からなるベクトルを
% 出力します。
%
% 例題: 
% 関数 x*exp(-x^2-y^2-z^2) を範囲 -2 < x < 2、-2 < y < 2、-2 < z < 2 で
% 可視化します。
%
%      [x,y,z] = meshgrid(-2:.2:2, -2:.25:2, -2:.16:2);
%      v = x .* exp(-x.^2 - y.^2 - z.^2);
%      slice(x,y,z,v,[-1.2 .8 2],2,[-2 -.2])
%
% 参考：MESHGRID, INTERP3.


%   J.N. Little 1-23-92
%   Revised 4-27-93, 2-10-94
%   Revised 6-17-94 by Clay M. Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 

% NUMGRID   2次元領域でのグリッド点のナンバリング
% 
% G = NUMGRID('R',n)は、'R'で決定されるサブ領域-1< = x< = 1および-1< = y
% < = 1内の、n行n列のグリッド上の点をナンバリングします。
% 
% SPY(NUMGRID('R',n))は、点をプロットします。
% 
% DELSQ(NUMGRID('R',n))は、5点離散ラプラシアンを出力します。
% 現在使用可能な領域は、つぎのものです。
% 
%    'S' - 正方形
%    'L' - 正方形全体の3/4のL型領域
%    'C' - 'L'に似ていますが、第4象限に4半円をもちます。
%    'D' - 単位円
%    'A' - 環状
%    'H' - ハート型
%    'B' - "Butterfly"の外側
%    'N' - 正方形の入れ子式のナンバリング
% 
% 他の領域を追加するためには、toolbox/matlab/demos/numgrid.mを修正してく
% ださい。
%
% 参考：DELSQ, DELSQSHOW, DELSQDEMO.


%   C. Moler, 7-16-91, 12-22-93.
%   Copyright 1984-2002 The MathWorks, Inc. 

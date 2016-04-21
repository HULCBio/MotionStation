% function out = frsp(sys,omega,T,balflg)
%
% SYSTEM行列の複素周波数応答は、周波数応答を含むVARYING行列を生成します。
%
% SYS     - SYSTEM行列
% OMEGA   - 応答を計算する周波数、他のVARYING行列が設定されているときは、
%           それらの独立変数が使われます。
% T       - 0(デフォルト)は、連続系システムを示し、T ~= 0の場合、サンプ
%           ル時間Tを使って離散化します。
% BALFLG  - 0(デフォルト)は、計算する前にA行列を平衡化し、非ゼロの場合は、
%           状態空間を変更しないで計算します。
% OUT     - VARYING周波数応答行列
%
% 参考: BALANCE, HESS, SAMHLD, TUSTIN, VPLOT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

% WEXTEND 　ベクトルまたは行列の拡張
%
% Y = WEXTEND(TYPE,MODE,X,L,LOC)、または、Y = WEXTEND(TYPE,MODE,X,L)
%
% 拡張モード :
%   'zpd' ゼロを挿入して拡張
%   'sp0' 次数 0 において平滑に拡張
%   'spd' (または 'sp1') 次数 1 において平滑に拡張
%   'sym' 対称拡張
%   'ppd' 周期的に拡張 
%    または 'per' 周期的に拡張
%
% TYPE = {1,'1','1d' または '1D'} で、
%   LOC = 'l' (または 'u') 左方向(または上方向)に拡張
%   LOC = 'r' (または 'd') 右方向(または下方向)に拡張
%   LOC = 'b' 両サイド上に拡張
%   デフォルトは、LOC = 'b' です。
%
% TYPE = {'r','row'} 
%   LOC = LOCCOL は、1次元の拡張方向です。
%   デフォルトは、LOC = 'b' です。
%
% TYPE = {'c','col'}
%   LOC = LOCCOL は、1次元の拡張方向です。
%   デフォルトは、LOC = 'b' です。
%
% TYPE = {2,'2','2d' または '2D'}
%   LOC = [LOCCOL,LOCROW]、ここで、 LOCCOL と LOCROW は、1次元の拡張方向、または、
% 'n' (none) です。デフォルトは、 LOC = 'bb' です。
% 



%   Copyright 1995-2002 The MathWorks, Inc.

% WENERGY   1次元ウェーブレット分解に対するエネルギ
%
% 1次元ウェーブレット分解 [C,L] に対して(WAVEDEC を参照)、
% [Ea,Ed] = WENERGY(C,L) は、approximation に対応するエネルギの
% パーセンテージ Ea と、detail に対応するエネルギのパーセンテージ Ed
% を出力します。
%
% 例題:
%     load noisbump
%     [C,L] = wavedec(noisbump,4,'sym4');
%     [Ea,Ed] = wenergy(C,L)



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:11:58 $

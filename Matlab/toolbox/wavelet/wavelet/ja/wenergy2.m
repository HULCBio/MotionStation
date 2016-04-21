% WENERGY2   2次元ウェーブレット分解に対するエネルギ
%
% 2次元ウェーブレット分解 [C,S] に対して(WAVEDEC2 を参照)、
% [Ea,Eh,Ev,Ed] = WENERGY2(C,S) は、approximation に対応するエネルギの
% パーセンテージ Ea と、水平、垂直、対角の detail に対応するエネルギの
% ベクトル Eh, Ev, Ed を出力します。
%
% [Ea,EDetail] = WENERGY2(C,S) は、ベクトル Eh、Ev および Ed の和である
% EDetail と、Ea を出力します。
%
% 例題:
%     load detail
%     [C,S] = wavedec2(X,2,'sym4');
%     [Ea,Eh,Ev,Ed] = wenergy2(C,S)
%     [Ea,EDetails] = wenergy2(C,S)


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:11:59 $

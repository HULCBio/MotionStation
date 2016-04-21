% POLY2STR   多項式を文字列として出力
% 
% S = POLY2STR(P,'s')、または、S = POLY2STR(P,'z') は、多項式の係数を
% 要素とするベクトル P に、変換変数's'、または、'z' を乗算して、文字列 S 
% に出力します。
%
% 例題： 
% POLY2STR([1 0 2],'s') は、つぎの文字列になります。
% 
%   's^2 + 2' 
%
% [S,LEN] = POLY2STR(P,'s') も、多項式の表示で出力します。
%
% 参考 : PRINTSYS.


%   Clay M. Thompson  7-24-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:18 $

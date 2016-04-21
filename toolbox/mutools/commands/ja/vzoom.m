%function vzoom('axis')
%
% VZOOMは、プロット内の2点をクリックすることによって、軸を固定します。
% STRは、つぎのような文字列変数です。
%	'ss'  標準のプロット(デフォルト)
%	'll'  両対数
%	'ls'  片対数(x軸が対数) 
%	'sl'  片対数(y軸が対数) 
%
% また、STRは'bode'以外の任意のVPLOTの入力で構いません。
% 
%  例題:
%            tf = frsp(nd2sys([ 1 .1],[.1 1]),logspace(-2,2,100));
%            vplot('nic',tf); vzoom('nic'); vplot('nic',tf);axis;
%
% 参考: GINPUT, VPLOT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

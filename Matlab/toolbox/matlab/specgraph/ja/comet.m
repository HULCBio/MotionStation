% COMET   コメットプロット
% 
% COMET(Y) は、ベクトル Y のアニメーション化されたコメットプロットを
% 表示します。
% COMET(X,Y) は、ベクトル X に対するベクトル Y のアニメーション化された
% コメットプロットを表示します。
% COMET(X,Y,p) は、長さ p*length(Y) のコメットを使用します。デフォルトは、
% p = 0.10 です。
% COMET(AX,...) は、GCAの代わりにAXにプロットします。
%
% 例題:
%       t = -pi:pi/200:pi;
%       comet(t,tan(sin(t))-sin(tan(t)))
%
% 参考：COMET3.


%   Charles R. Denham, MathWorks, 1989.
%   Revised 2-9-92, LS and DTP; 8-18-92, 11-30-92 CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 

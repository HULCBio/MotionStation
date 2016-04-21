% COMET3   3次元コメットプロット
% 
% COMET3(Z) は、ベクトル Z のアニメーション化された3次元コメットプロットを
% 表示します。
% 
% COMET3(X,Y,Z) は、点 [X(i),Y(i),Z(i)] を通る曲線のコメットプロットを
% 表示します。
% COMET3(X,Y,Z,p) は、長さ p*length(Z) のコメットを使用します。デフォルトは
% p = 0.1です。
%
% COMET3(AX,...) は、GCAの代わりにAXにプロットします。
%
% 例題:
%       t = -pi:pi/500:pi;
%       comet3(sin(5*t),cos(3*t),t)
%
% 参考：COMET.


%   Charles R. Denham, MathWorks, 1989.
%   Revised 2-9-92, LS and DTP; 8-18-92, 11-30-92 CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 

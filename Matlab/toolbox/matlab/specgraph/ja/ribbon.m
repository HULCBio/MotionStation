% RIBBON   2次元ラインを3次元のリボンとして描画
% 
% RIBBON(X,Y) は、Y の列が個々にリボンとして3次元プロットされることを
% 除けば、PLOT(X,Y) と同じです。RIBBON(Y) は、デフォルト値 X = 1:SIZE(Y,1) 
% を使用します。
%
% RIBBON(X,Y,WIDTH) は、リボンの幅を WIDTH に指定します。デフォルトは、
% WIDTH = 0.75 です。
%
% RIBBON(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = RIBBON(...) は、サーフェスオブジェクトのハンドル番号からなるベクトル
% を出力します。
%
% 参考：PLOT.


%   Clay M. Thompson 2-8-94
%   Copyright 1984-2002 The MathWorks, Inc. 

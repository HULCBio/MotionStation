% PLOTMATRIX   散布図の描画
% 
% PLOTMATRIX(X,Y) は、Y の列に対する X の列の散布図を描画します。X が
% P行M列で、Y がP行N列の場合、PLOTMATRIX は、N行M列の行列からなる軸を
% 出力します。
% PLOTMATRIX(Y) は、対角成分が HIST(Y(:,i)) で置き換えられることを除けば、
% PLOTMATRIX(Y,Y) と同じです。
%
% PLOTMATRIX(...,'LineSpec') は、文字列 'LineSpec' のラインの仕様を使います。
% '.' は、デフォルトです(使用可能な値については、PLOT を参照してください)。  
%
% PLOTMATRIX(AX,...) はGCAの代わりにBigAxとしてAXを使います。
%
% [H,AX,BigAx,P,PAx] = PLOTMATRIX(...) は、作成されたオブジェクトの
% ハンドル番号からなる行列をHに、個々の補助軸のハンドル番号からなる行列を 
% AX に補助軸を作る大きい軸(視覚不可)のハンドル番号を BigAx に、ヒスト
% グラムプロットに対するハンドル番号からなる行列を P に、ヒストグラムの
% 軸のスケールを制御する非可視の軸のハンドル番号からなる行列を PAx に
% 出力します。BigAx は､続くコマンド TITLE、XLABEL、YLABEL が軸の行列の
% 中心に配置されるように、CurrentAxesとして残されます。
%
% 例題:
% 
%       x = randn(50,3); y = x*[-1 2 1;2 0 1;1 -2 3;]';
%       plotmatrix(y)


%   Clay M. Thompson 10-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 

% TRIPLEQUAD    数値的な三重積分の計算
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX) は、3次元長方形
% 領域 XMIN <= X <= XMAX, YMIN <= Y <= YMAX, ZMIN <= Z <= ZMAX 上
% で、FUN(X,Y,Z)の三重積分を計算します。
% FUN(X,Y,Z) は、ベクトル X とスカラ および Z を受け入れ、被積分関数の
% 値のベクトルを出力します。
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL) は、デフォルト
% の 1e-6 の代わりに許容誤差 TOL を利用します。
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL) は、
% デフォルトの QUAD の代わりに求積関数 QUADL を利用します。  
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,ZMIN,ZMAX,@MYQUADF)
% は、QUAD の代わりにユーザ定義の求積関数 MYQUADF を利用します。
% MYQUADF は、QUAD および QUADL と同じ呼び出しシーケンスをもちます。
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL,P1,P2,...) 
% は、付加的なパラメータを  FUN(X,Y,P1,P2,...) に渡します。
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,[],[],P1,P2,...) は、
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,1.e-6,@QUAD,P1,P2,...) 
% と同じです。
%
% 例題:
%       FUN は、インラインオブジェクトまたは関数ハンドルにすることも可能です。
%
%         Q = triplequad(inline('y*sin(x)+z*cos(x)'), 0, pi, 0, 1, -1, 1) 
%
%       または
%
%         Q = triplequad(@integrnd, 0, pi, 0, 1, -1, 1) 
%
%       ここで、integrnd.m はM-ファイルです:       
%           function f = integrnd(x, y, z)
%           f = y*sin(x)+z*cos(x);  
%
%       これは、領域 0 <= x <= pi, 0 <= y <= 1, -1 <= z <= 1 で
%       y*sin(x)+z*cos(x) を積分します。被積分関数は、ベクトル x および
%       スカラ y, z を使って計算されることに注意してください。
%
% 参考 ： QUAD, QUADL, DBLQUAD, INLINE, @.


%   Copyright 1984-2003 The MathWorks, Inc.

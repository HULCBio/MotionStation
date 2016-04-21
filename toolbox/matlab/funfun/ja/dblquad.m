% DBLQUAD   2重積分を数値的に計算
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX) は、長方形区間 XMIN <= X <= XMAX, 
% YMIN <= Y <= YMAX で、FUN(X,Y) の2重積分を行います。F(X,Y) は、
% ベクトルX とスカラ Y を受け入れて、被積分関数値をベクトルで戻します。
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL) は、デフォルトの許容誤差 1.e-6
% の代わりに、TOL を使います。
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL) は、デフォルトの QUAD 
% の代わりに、求積関数 QUADL を使います。MYQUAD は、QUAD と QUADL と
% 同じコールの方法を使います。
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL,P1,P2,...) は、
% FUN(X,Y,P1,P2,...) にエキストラのパラメータを渡します。
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,[],[],P1,P2,...) は、
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,1.e-6,@QUAD,P1,P2,...)と同じです。
%
% 例題：
%     FUN は、インラインオブジェクト、または、関数ハンドルです。
%
%         Q = dblquad(inline('y*sin(x)+x*cos(y)'), pi, 2*pi, 0, pi) 
%
%     または、
%
%         Q = dblquad(@integrnd, pi, 2*pi, 0, pi) 
%
%     ここで、integrnd.m は、M-ファイルです。       
%           function z = integrnd(x, y)
%           z = y*sin(x)+x*cos(y);  
%
%     これは、pi <= x <= 2*pi, 0 <= y <= pi の正方形の区間で、 
%     y*sin(x)+x*cos(y) を積分します。積分は、ベクトル x とスカラ y を
%     使って計算することに注意してください。
%
%     正方形でない領域は、領域の外側にゼロを仮定して、正方形にした型で
%     積分を取り扱います。半球の体積は、つぎのように求まります。
%
%       dblquad(inline('sqrt(max(1-(x.^2+y.^2),0))'),-1,1,-1,1)
%
%     または、
%
%       dblquad(inline('sqrt(1-(x.^2+y.^2)).*(x.^2+y.^2<=1)'),-1,1,-1,1)
% 
% 参考：QUAD, QUADL, TRIPLEQUAD, INLINE, @.


%   Copyright 1984-2003 The MathWorks, Inc.

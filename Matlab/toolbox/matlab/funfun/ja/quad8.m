% QUAD8  高次の数値積分
%
% QUAD8は、廃版となっています。QUADL を代わりに使ってください。
%
% Q = QUAD8(FUN,A,B) は、適応リカーシブなNewton Cotes 8 panel法を
% 使って、相対誤差が1e-3以下になるように、A と B の間の F(X) の積分
% 値を近似します。FUN は、ベクトル入力 X を受け入れ、X の各要素におい
% て計算される関数FUNであるベクトル Y を出力します。  
% 特異点の積分を示すリカーションレベルに達すると、Q = Inf が出力されます。
%
% Q = QUAD8(FUN,A,B,TOL) は、相対誤差が TOL になるように積分します。
% 2要素の許容誤差 TOL = [rel_tol abs_tol] を使って、相対誤差と絶対誤差
% を指定します。
%
% Q = QUAD8(FUN,A,B,TOL,TRACE) は、相対誤差が TOL になるまで積分
% します。ゼロでない TRACE に対して、積分点のプロットを行い関数の実行
% を表示します。.
%
% Q = QUAD8(FUN,A,B,TOL,TRACE,P1,P2,...) は、関数 FUN(X,P1,P2,...) に
% 引数 P1, P2, ... を直接渡します。TOL や TRACE のデフォルト値を使うため
% には、空行列([])を渡してください。
%
% 参考 ： QUADL, QUAD, DBLQUAD, INLINE, @.

%   Copyright 1984-2002 The MathWorks, Inc.


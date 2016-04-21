% HYPERBOLIC   双曲線型 PDE 問題を解きます。
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D) は、P, E, T で記述される
% メッシュ上で、B によって与えられた境界条件と初期値 U0 と導関数の初期値
% UT0 をもつスカラ PDE 問題 d*d^2u/dt^2-div(c*grad(u))+a*u = f の FEM 形
% 式に合わせて解を作ります。
%
% スカラの場合、解行列 U1 の各行は、P で対応している列によって与えられる
% 座標上での解です。U1 の各列は、TLIST で対応している項目によって与えら
% れる時刻での解です。NP 節点をもつ N 次元のシステムの場合、U1 の最初の 
% NP 行は u の最初の成分を表示し、続く U1 の NP 行は u の第2の成分を、と
% いうように表示します。このようにして、u の成分は、節点の行数の N ブロ
% ックとして、ブロック U に設定します。
%
% B は、PDE 問題の境界条件を表します。B は、Boundary Condition 行列また
% は Boundary M-ファイルのファイル名のどちらでも可能です。詳細は、PDEB-
% OUND を参照してください。
%
% PDE 問題の係数 C, A, F, D は、多種多様な方法で与えることができます。詳
% 細は、ASSEMPDE を参照してください。
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL) と U1 = HYPERBOL-
% IC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL,ATOL) は、絶対許容誤差と相対許容
% 誤差を ODE ソルバに渡します。
%
% U1 = HYPERBOLIC(U0,UT0,TLIST,K,F,B,UD,M) は、初期値 U0 と UT0 をもつ 
% ODE 問題 B'*M*B*(d^2ui/dt^2)+K*ui = F, u = B*ui+ud に対する解を作成し
% ます。
%
% 参考   ASSEMPDE, PARABOLIC



%       Copyright 1994-2001 The MathWorks, Inc.

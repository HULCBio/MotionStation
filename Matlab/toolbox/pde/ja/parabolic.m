% PARABOLIC   放物型PDE問題を解きます。
%
% U1 = PARABOLIC(U0,TLIST,B,P,E,T,C,A,F,D) は、P, E, T で記述されるメッ
% シュ上で、B によって与えられた境界条件と初期値 U0 をもつスカラ PDE 問
% 題 d*du/dt-div(c*grad(u))+a*u = f の FEM 形式に合わせて解を作ります。
%
% スカラの場合、解行列 U1 の各行は、P で対応している列によって与えられる
% 座標上での解です。U1 の各列は、TLIST で対応している項目によって与えら
% れる時刻での解です。NP 節点をもつ N 次元のシステムの場合、U1 の最初の 
% NP 行は u の最初の成分を表示し、続く U1 の NP 行は u の第2の成分を、と
% いうように表示します。このようにして、u の成分は、節点の行数の N ブロ
% ックとして、ブロック U に設定します。
%
% B は、PDE 問題の境界条件を表わします。B は、Boundary Condition 行列ま
% たは Boundary M-ファイルのファイル名のどちらでも可能です。詳細は、PD-
% EBOUND を参照してください。
%
% PDE 問題の係数 C, A, F, D は、多種多様な方法で与えることができます。詳
% 細は、ASSEMPDE を参照してください。
%
% U1 = PARABOLIC(U0,TLIST,B,P,E,T,C,A,F,D,RTOL) と U1 = PARABOLIC(U0,...
% TLIST,B,P,E,T,C,A,F,D,RTOL,ATOL) は、絶対許容誤差と相対許容誤差を ODE 
% ソルバに渡します。
%
% U1 = PARABOLIC(U0,TLIST,K,F,B,UD,M) は、初期 U0 をもつ ODE 問題 
% B'*M*B*(dui/dt)+K*ui = F, u = B*ui+ud に合わせて解を作ります。
% 
% 参考   ASSEMPDE, HYPERBOLIC



%       Copyright 1994-2001 The MathWorks, Inc.

% BICGSTAB 　双共役傾斜安定化法
%
% X = BICGSTAB(A,B) は、X に関する線形方程式 A*X = B を解きます。N 行 
% N 列の係数行列 A は正方で、右辺の列ベクトル B は長さが N である必要
% があります。A は、A'*X を出力する関数です。
%
% BICGSTAB(A,B,TOL) は、方法の中にトレランスを指定できます。TOL が []
% の場合は、BICGSTAB はデフォルトの1e-6を使います。
%
% BICGSTAB(A,B,TOL,MAXIT) は、繰り返し最大回数を設定します。MAXIT が
% [] の場合は、BICGSTAB はデフォルトの min(N,20)を使います。
%
% BICGSTAB(A,B,TOL,MAXIT,M) と BICGSTAB(A,B,TOL,MAXIT,M1,M2) は、
% 前提条件 M または M = M1*M2 を使い、システム inv(M)*A*X = inv(M)*B 
% を X について、効率良く解きます。M が [] の場合は、前提条件は適用され
% ません。M は、M'\X を出力する関数です。
%
% BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) は、初期推定値を設定します。X0 が 
% [] の場合は、BICGSTAB はデフォルトのすべてがゼロ要素を使います。
%
% BICGSTAB(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、パラメータ 
% P1,P2,... を関数 AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), 
% M2FUN(X,P1,P2,...) に渡します。
%
% [X,FLAG] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) は、収束に関する情報 
% FLAG を出力します。
% 
%    0 BICGSTAB は、MAXIT 繰り返しの範囲内で、希望するトレランス TOL 
%      に収束します。
%    1 BICGSTAB は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 BICGSTAB が機能しません(2回の連続する繰り返しの結果が同じ)
%    4 BICGSTAB の間、計算されるスカラ量の1つが、計算を続けるには
%      大きすぎるか、または小さい
%
% [X,FLAG,RELRES] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) は、相対残差 
% NORM(B-A*X)/NORM(B) も出力します。FLAG が0の場合は、RELRES <= TOL です。
%
% [X,FLAG,RELRES,ITER] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) は、X が計算
% されたときの繰り返し回数も出力します。 0 <= ITER <= MAXIT。ITER は、
% 整数 +0.5 で、繰り返しを通して、片側の収束を示します。
%
% [X,FLAG,RELRES,ITER,RESVEC] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) は、
% 各繰り返しでの残差ノルムのベクトル NORM(B-A*X0) も出力します。
%
% 例題：
%  A = gallery('wilk',21);  b = sum(A,2);
%  tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%  x = bicgstab(A,b,tol,maxit,M1,[],[]);
% または、つぎの行列とベクトルの積の関数を使います。
%  function y = afun(x,n)
%  y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
% そして、前提条件の後退解法関数を使います。
%   function y = mfun(r,n)
%   y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%  BICGSTAB への入力を行います。
%   x1 = bicgstab(@afun,b,tol,maxit,@mfun,[],[],21);
% afun も mfun の両方とも BICGSTAB の追加入力 n = 21 を受け入れなければ
% ならないことに注意してください。
%
% 参考：BICG, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:28 $

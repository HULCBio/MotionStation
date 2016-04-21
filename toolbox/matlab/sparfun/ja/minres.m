% MINRES  最小残差法 

% X = MINRES(A,B) は、線形方程式 A*X = B の最小ノルム残差解を求めます。
% N 行 N 列の係数行列 A は、対称であることが必要ですが、正定である必要は
% ありません。右辺の列ベクトル B は、長さが N である必要があります。
% A は A'*X を出力する関数です。
%
% MINRES(A,B,TOL) は、方法のトレランスを指定できます。TOL が [] の場合は、
% MINRES はデフォルトの1e-6を使います。
%
% MINRES(A,B,TOL,MAXIT) は、繰り返し最大回数を設定します。MAXIT が [] 
% の場合は、MINRES はデフォルトの min(N,20) を使います。
%
% MINRES(A,B,TOL,MAXIT,M) と MINRES(A,B,TOL,MAXIT,M1,M2) は、対称正定
% の前提条件 M または M = M1*M2 を使い、システム 
% inv(sqrt(M))*A*invv(sqrt(M))*Y = inv(sqrt(M))*B を Y について、効率
% 良く解きます。ここで、X = inv(sqrt(M))*Y を出力します。M が[] の場合は、
% 前提条件は適用されません。M は、M'\X を出力する関数です。
%
% MINRES(A,B,TOL,MAXIT,M1,M2,X0) は、初期推定値を設定します。X0 が [] 
% の場合は、MINRES はデフォルトのすべてがゼロ要素を使います。
%
% MINRES(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、パラメータ
% P1,P2,...を関数 AFUN(X,P1,P2,...),M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...)
% に渡します。
%
% [X,FLAG] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) は、収束に関する情報 FLAG 
% を出力します。
% 
%    0 MINRES は、MAXIT 繰り返しの範囲内で希望するトレランス TOL に収束
%      します。
%    1 MINRES は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 MINRES が機能しません(2回の連続する繰り返しの結果が同じ)
%    4 MINRES の間、計算されるスカラ量の1つが、計算を続けるには大き
%      すぎるか、または小さい
%    5 前提条件子 M が対称正定でない
%
% [X,FLAG,RELRES] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) は、相対残差 
% NORM(BA*X)/NORM(B) も出力します。FLAG が0の場合は、RELRES <= TOL です。
%
% [X,FLAG,RELRES,ITER] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) は、X が計算
% されたときの繰り返し回数も出力します。 0 <= ITER <= MAXIT。
%
% [X,FLAG,RELRES,ITER,RESVEC] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) は、
% 各繰り返しで、NORM(B-A*X0) を含む MINRES 残差ノルムの推定のベクトルを
% 出力します。
%
% [X,FLAG,RELRES,ITER,RESVEC,RESVECCG] = MINRES(A,B,TOL,MAXIT,M1,M2,X0) 
% は、各繰り返しでの共役勾配残差ノルムのベクトルも出力します。
%
% 例題：
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -2*on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-10; maxit = 50; M1 = spdiags(4*on,0,n,n);
%   x = minres(A,b,tol,maxit,M1,[],[]);
% つぎの行列-ベクトル積関数を使用
%      function y = afun(x,n)
%      y = 4 * x;
%      y(2:n) = y(2:n) - 2 * x(1:n-1);
%      y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%
% MINRES への入力として利用します。
%      x1 = minres(@afun,b,tol,maxit,M1,M2,[],[]);
%
% 参考：BICG, BICGSTAB, CGS, GMRES, LSQR, PCG, QMR, SYMMLQ, @.


%   Penny Anderson, 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $ $Date: 2004/04/28 02:02:45 $

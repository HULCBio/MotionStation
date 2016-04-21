% PCG    前提条件付き共役傾斜法
%
% X = PCG(A,B) は、X に関する線形方程式 A*X = B を解きます。N 行 N 列の
% 係数行列 A は対称かつ正定で、右辺の列ベクトル B は長さが N である必要
% があります。A は、A'*X を出力する関数です。
%
% PCG(A,B,TOL) は、方法のトレランスを指定できます。TOL が [] の場合は、
% PCG はデフォルトの1e-6を使います。
%
% PCG(A,B,TOL,MAXIT) は、繰り返し最大回数を設定します。MAXIT が[] の
% 場合は、PCG はデフォルトの min(N,20)を使います。
%
% PCG(A,B,TOL,MAXIT,M) と PCG(A,B,TOL,MAXIT,M1,M2) は、対称かつ正定な
% 前提条件 M または M = M1*M2 を使い、システム inv(M)*A*X = inv(M)*B を
% X について効率良く解きます。M が [] の場合は、前提条件は適用されません。
% Mは、M'\X を出力する関数です。
%
% PCG(A,B,TOL,MAXIT,M1,M2,X0) は、初期推定値を指定します。X0 が [] の
% 場合は、PCG はデフォルトのすべてがゼロ要素を使います。
%
% PCG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、パラメータP1,P2,...
% を関数 AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...) に
% 渡します。
%
% [X,FLAG] = PCG(A,B,TOL,MAXIT,M1,M2,X0) は、収束に関する情報 FLAG を
% 出力します。
% 
%    0 PCG は、MAXIT 繰り返しの範囲内で希望するトレランス TOL に
%      収束します。
%    1 PCG は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 PCG が機能しません(2回の連続する繰り返しの結果が同じ)
%    4 PCG の間、計算されるスカラ量の1つが、計算を続けるには大き
%      すぎるか、または小さい
%
% [X,FLAG,RELRES] = PCG(A,B,TOL,MAXIT,M1,M2,X0) は、相対残差 
% NORM(B-A*X)/NORM(B) も出力します。FLAG が0の場合は、RELRES <= TOL です。
%
% [X,FLAG,RELRES,ITER] = PCG(A,B,TOL,MAXIT,M1,M2,X0) は、X が計算された
% ときの繰り返し回数も出力します。 0 <= ITER <= MAXIT。
%
% [X,FLAG,RELRES,ITER,RESVEC] = PCG(A,B,TOL,MAXIT,M1,M2,X0) は、各繰り
% 返しでの残差ノルムのベクトル NORM(B-A*X0) も出力します。
%
% 例題：
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = pcg(A,b,tol,maxit,M1,[],[]);
% または、つぎの1ライン行列とベクトルの積の関数を使います。
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + ...
%      [x(2:n); 0];
% そして、1ライン前提条件の後退解法関数を使います。
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
% PCG への入力として利用します。
%      x1 = pcg(@afun,b,tol,maxit,@mfun,[],[],21);
%
% 参考：BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, QMR, SYMMLQ, CHOLINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/28 02:02:49 $

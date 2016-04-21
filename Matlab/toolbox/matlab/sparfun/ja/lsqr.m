% LSQR    正規方程式での共役勾配法の実現
%
% X = LSQR(A,B) は、Aが矛盾のない場合は、X に関する線形方程式 A*X = B を
% 解きます。そうでない場合は、norm(B-A*X) を最小にする最小二乗解 X を
% 求めようとします。M 行 N 列の係数行列 A は正方で、右辺の列ベクトル B 
% は、長さが M である必要があります。A は、AFUN(X) が A*X を出力し、 
% AFUN(X,'transp') が A'*X を出力するような関数 AFUN です。
%
% LSQR(A,B,TOL) は、方法のトレランスを指定できます。TOL が [] の場合は、
% LSQR は、デフォルトの1e-6を使います。
%
% LSQR(A,B,TOL,MAXIT) は、繰り返し最大回数を設定します。MAXIT が []の
% 場合、LSQR は デフォルトの min([M,N,20]) を使います。
%
% LSQR(A,B,TOL,MAXIT,M) と LSQR(A,B,TOL,MAXIT,M1,M2) は、N 行 N 列の
% 前提条件 M または M = M1*M2 を使い、システム A*inv(M)*Y = B を Y に
% ついて効率良く解きます。ここで、X = inv(M2)*Y です。M が [] の場合は、
% 前提条件は適用されません。M は、MFUN(X) が M\X を出力し、MFUN(X,'transp') 
% が M'\X を出力するような関数 MFUN です。
%
% LSQR(A,B,TOL,MAXIT,M1,M2,X0) は、初期推定値を指定します。X0 が [] の
% 場合は、LSQR は デフォルトのすべてがゼロ要素を使います。
%
% LSQR(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、関数 AFUN にパラ
% メータ P1,P2,...を渡します。ここで、AFUN は、 AFUN(X,P1,P2,...) や 
% AFUN(X,P1,P2,...,'transp') として使用し、前提条件関数 M1FUN や M2FUN 
% と同様です。
%
% [X,FLAG] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) は、収束に関する情報 FLAG を
% 出力します。
% 
%    0 LSQR は、MAXIT 繰り返しの範囲内で希望するトレランス TOL に
%      収束します。
%    1 LSQR は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 LSQR が機能しません(2回の連続する繰り返しの結果が同じ)
%    4 LSQR の間、計算されるスカラ量の1つが、計算を続けるには大き
%      すぎるか、または小さい
%
% [X,FLAG,RELRES] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) は、相対残差 
% NORM(B-A*X)/NORM(B) も出力します。FLAG が0の場合は、RELRES <= TOL です。
%
% [X,FLAG,RELRES,ITER] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) は、X が計算され
% たときの繰り返し回数も出力します。 0 <= ITER <= MAXIT.
%
% [X,FLAG,RELRES,ITER,RESVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) は、各繰り
% 返しでの残差ノルムのベクトル NORM(B-A*X0) も出力します。
%
% [X,FLAG,RELRES,ITER,RESVEC,LSVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) 
% は、各繰り返しでの最小二乗推定のベクトルも出力します。
% NORM((A*inv(M))'*(B-A*X))/NORM(A*inv(M),'fro'). NORM(A*inv(M),'fro') の
% 推定は、各繰り返しについて変化し、改良されることに注意してください。
%
% 例題：
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = qmr(A,b,tol,maxit,M1,M2,[]);
% 行列-ベクトル積の関数を使用
%   if (nargin > 2) & strcmp(transp_flag,'transp')
%       y = 4 * x;
%       y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%       y(2:n) = y(2:n) - x(1:n-1);
%   else
%       y = 4 * x;
%       y(2:n) = y(2:n) - 2 * x(1:n-1);
%       y(1:n-1) = y(1:n-1) - x(2:n);
%   end
%
% LSQR への入力として利用します。
%      x1 = lsqr(@afun,b,tol,maxit,M1,M2,[],n);
%
% 参考：BICG, BICGSTAB, CGS, GMRES, MINRES, PCG, QMR, SYMMLQ, @.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:02:43 $

% BICG   双共役傾斜法
%
% X = BICG(A,B) は、X に関する線形方程式 A*X = B を解きます。N 行 N 列
% の係数行列 A は正方で、右辺の列ベクトル B は 長さが N である必要が
% あります。A は、AFUN(X) が A*X を出力し、 AFUN(X,'transp') が A'*X を
% 出力するような関数です。
%
% BICG(A,B,TOL) は、方法の中にトレランスを指定できます。TOL が [] の
% 場合は、BICG は デフォルトの1e-6を使います。
%
% BICG(A,B,TOL,MAXIT) は、繰り返し最大回数を設定します。MAXIT が[]の
% 場合は、BICG はデフォルトの min(N,20)を使います。
%
% BICG(A,B,TOL,MAXIT,M) と BICG(A,B,TOL,MAXIT,M1,M2) は、前提条件 M、
% または M = M1*M2 を使い、システム inv(M)*A*X = inv(M)*B を X について、
% 効率良く解きます。M が [] の場合は、前提条件は適用されません。
% M は、MFUN(X) が M\X を出力し、MFUN(X,'transp') が M'\X を出力する
% ような関数 MFUN です。
%
% BICG(A,B,TOL,MAXIT,M1,M2,X0) は、初期推定値を設定します。X0 が [] の
% 場合は、、BICG はデフォルトのすべてがゼロ要素を使います。
%
% BICG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、関数 AFUN にパラ
% メータ P1,P2,...を渡します。ここで、AFUN は、AFUN(X,P1,P2,...) や
% AFUN(X,P1,P2,...,'transp') として使用し、前提条件関数 M1FUN や M2FUN 
% と同様です。
%
% [X,FLAG] = BICG(A,B,TOL,MAXIT,M1,M2,X0) は、収束に関する情報 FLAG 
% を出力します。
% 
%    0 BICG は、MAXIT 繰り返しの範囲内で希望するトレランス TOL に収束し
%      ます。
%    1 BICG は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 BICG が機能しません(2回の連続する繰り返しの結果が同じ)
%    4 BICG の間、計算されるスカラ量の1つが、計算を続けるには
%      大きすぎるか、または小さい
%
% [X,FLAG,RELRES] = BICG(A,B,TOL,MAXIT,M1,M2,X0) は、相対残差 
% NORM(B-A*X)/NORM(B) も出力します。FLAG が0の場合は、RELRES <= TOL です。
%
% [X,FLAG,RELRES,ITER] = BICG(A,B,TOL,MAXIT,M1,M2,X0) は、X が計算さ
% れたときの繰り返し回数も出力します。 0 <= ITER <= MAXIT.
%
% [X,FLAG,RELRES,ITER,RESVEC] = BICG(A,B,TOL,MAXIT,M1,M2,X0) は、
% 各繰り返しでの残差ノルムのベクトル NORM(B-A*X0) も出力します。
%
% 例題：
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = bicg(A,b,tol,maxit,M1,M2,[]);
%   行列-ベクトル積の関数を使用
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
%   BICG への入力として利用します。
%      x1 = bicg(@afun,b,tol,maxit,M1,M2,[],n);
%
% 参考：BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


%   Penny Anderson, 1996.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:27 $

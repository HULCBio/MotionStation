% GMRES  一般化最小残差法
%
% X = GMRES(A,B) は、X に関する線形方程式 A*X =B を解きます。N 行 N 列
% の係数行列 A は正方で、右辺の列ベクトル B は長さが N である必要があり
% ます。A は、A*X を出力する関数でもある可能性があります。これは、
% MIN(N,10) を繰り返し回数の最大可能回数として、再スタートしない方法を使っ
% ています。
%
% MRES(A,B,RESTART) は、RESTART 回の繰り返し毎に方法を再スタートしま
% す。RESTART が N または [] の場合は、GMRES は、上記のように再スタート
% を行いません。
%
% GMRES(A,B,RESTART,TOL) は、方法のトレランスを設定します。TOL が [] の
% 場合は、デフォルトの1e-6 を使います。
%
% GMRES(A,B,RESTART,TOL,MAXIT) は、繰り返しの最大回数を指定します。
% 注意：繰り返しの総回数は、RESTART*MAXIT です。MAXIT が [] の場合は、
% GMRES はデフォルトの MIN(N/RESTART,10) を使います。RESTART が Nま
% たは [] の場合は、繰り返しの総回数は MAXIT になります。
%
% GMRES(A,B,RESTART,TOL,MAXIT,M) と 
% GMRES(A,B,RESTART,TOL,MAXIT,M1,M2) は
% 前提条件 M または M = M1*M2 を使い、X について inv(M)*A*X = inv(M)*B
% を効率的に解きます。M が [] の場合は、前提条件は適用されません。M は 
% M\X を出力する関数です。
%
% GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) は、初期推定を指定します。X0 
% が [] の場合は、デフォルトのすべてがゼロ要素のベクトルを使います。
%
% GMRES(AFUN,B,RESTART,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) は、関数
% にパラメータを渡します。AFUN(X,...P1,P2,...), M1FUN(X,P1,P2,...), 
% M2FUN(X,P1,P2,...).
% 
% [X,FLAG] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) は、収束に関する
% 情報 FLAG を出力します。
% 
%    0 GMRES は、MAXIT 繰り返しの範囲内で希望するトレランス TOL に収束
%      します。
%    1 GMRES は、MAXIT 回繰り返しましたが、収束しません。
%    2 前提条件 M の条件数が悪い
%    3 GMRES が機能しません(2回の連続する繰り返しの結果が同じ)
%
% [X,FLAG,RELRES] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) は、相対
% 残差 NORM(B-A*X)/NORM(B) も出力します。FLAG  が0の場合は、
% RELRES <= TOL です。前処理M1,M2を使うと、残差はNORM(M2\(M1\(B-A*X)))
% です。
%
% [X,FLAG,RELRES,ITER] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) は、X 
% が計算されたときの繰り返し回数も出力します。0 <= ITER(1) <= MAXIT と 
% 0 <= ITER(2) <= RESTART です。
%
% [X,FLAG,RELRES,ITER,RESVEC] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) 
% は NORM(B-A*X0) を含む各繰り返しでの残差ノルムのベクトルも出力しま
% す。前処理M1,M2を使うと、残差は NORM(M2\(M1\(B-A*X)))です。
%
% 例題：
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = gmres(A,b,10,tol,maxit,M1,[],[]);
% または、つぎの行列とベクトルの積の関数を使います。
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x...
%          + [x(2:n); 0];
% そして、前提条件の後退解法関数を使います。
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
% GMRES への入力として利用します。
%      x1 = gmres(@afun,b,10,tol,maxit,@mfun,[],[],21);
%
% 参考：BICG, BICGSTAB, CGS, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.


% EIGS   ARPACK を用いて行列の2、3の固有値と固有ベクトルを求めます
% 
% D = EIGS(A) は、A の固有値の中の大きいものから6個をベクトルとして出力し
% ます。
%
% [V,D] = EIGS(A) は、A の固有値の中の大きいものから6個を対角要素とする
% 行列 D として、対応する固有ベクトルを行列 V として出力します。
%
% [V,D,FLAG] = EIGS(A) は、収束フラグも出力します。FLAG が 0 の場合は、す
% べての固有値は収束しています。他の場合は、いずれかのものが収束してい
% ません。
%
% EIGS(A,B) は、一般化固有値問題 A*V == B*V*D を解きます。B は、対称(ま
% たはエルミート)で正定で、A と同じサイズでなければなりません。EIGS(A,[],...) 
% は、標準固有値問題 A*V == V*D を意味します。
%
% EIGS(A,K) と EIGS(A,B,K) は、固有値の中の大きいものから K 個を出力しま
% す。
%
% EIGS(A,K,SIGMA) と EIGS(A,B,K,SIGMA) は、SIGMA をベースに K 個の固有
% 値を出力します。
% 
%      'LM' または 'SM' - 大きさが最大または最小
% 実数対称問題に対して、SIGMA はつぎのようにもできます。
%      'LA' または 'SA' - 代数的に最大、最小
%      'BE' - 両端から、K が奇数の場合は、高い方を1つ多く
% 非対称で複素数の場合は、SIGMA をつぎのように設定します。
%      'LR' または 'SR' - 実数部が最大または最小
%      'LI' または 'SI' - 虚数部が最大または最小
% SIGMA が0を含む実数、または複素数のスカラの場合は、EIGS は SIGMA に
% 最も近い固有値を検出します。スカラの SIGMA に対して、また、SIGMA = 0
% と同じアルゴリズムを利用する SIGMA = 'SM' のときも、他のケースのように
% Cholesky 分解ではないため、B は対称(またはエルミート)の正の半正定で
% ある必要があります。
%
% EIGS(A,K,SIGMA,OPTS) と EIGS(A,B,K,SIGMA,OPTS) は、オプションを指定し
% ます。
% 
%   OPTS.issym: A の対称性またはAFUN [{0} | 1] で表わされる A-SIGMA*B
%   OPTS.isreal: A の複素数性またはAFUN [{0} | 1]で表わされる A-SIGMA*B
%   OPTS.tol   : 収束性：Ritzの推定残差 <= tol*NORM(A) [スカラ | {eps}]
%   OPTS.maxit : 繰り返し最大回数 [整数 | {300}]
%   OPTS.p     : Lanczos ベクトルの数： K+1<p<=N [整数 | {2K}]
%   OPTS.v0    : スタートベクトル 
%               [N 行 1 列のベクトル | {ARPACKでランダムに発生}]
%   OPTS.disp  : 警告情報の表示レベル [0 | {1} | 2]
%   OPTS.cholB : B は、実質Cholesky 分解 CHOL(B) [{0} | 1]
%   OPTS.permB : スパース B は、CHOL(B(permB,permB)) [permB | {1:N}]
%
% EIGS(AFUN,N) は、行列 A の代わりに関数 AFUN を受け入れます。
% Y = AFUN(X) は以下を出力します。
%    A*X            SIGMA が指定されていないか、'SM' 以外の文字列である場合
%    A\X            SIGMA が0か 'SM' である場合
%    (A-SIGMA*I)\X  SIGMA が非ゼロのスカラ(標準の固有値問題)である場合
%    (A-SIGMA*B)\X  SIGMA は非ゼロのスカラ(一般化固有値問題)である場合
% N は、A のサイズです。AFUN によって示される A-SIGMA*I A-SIGMA*B の行列 A は、
% OPTS.isreal と OPTS.issym によって他に指定されていなければ、実数で非対称
% であると仮定されます。これらの EIGS 構文のすべてにおいて、EIGS(A,...) は、
% EIGS(AFUN,N,...) で置き換えられます。
%
% EIGS(AFUN,N,K,SIGMA,OPTS,P1,...) と EIGS(AFUN,N,B,K,SIGMA,OPTS,P1,...) 
% は、AFUN(X,P1,..) に渡す付加的な引数を与えます。
%
% 例題：
%      A = delsq(numgrid('C',15));  d1 = eigs(A,5,'SM');
% 等価なものとして、dnRk は、つぎの1ライン関数のとき
%      function y = dnRk(x,R,k)
%      y = (delsq(numgrid(R,k))) \ x;
% dhRk の付加的な引数 'C' と 15 を EIGS に渡します。
%      n = size(A,1);  opts.issym = 1;  d2 = eigs(@dnRk,n,5,'SM', opts,'C',15);
%
% 参考：EIG, SVDS, ARPACKC.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:02:35 $

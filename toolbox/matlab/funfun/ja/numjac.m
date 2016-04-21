%NUMJAC 関数 F(T,Y)の ヤコビアン dF/dY を数値的に計算します
%
% [DFDY,FAC] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED) 
% T は独立変数で、列ベクトル Y は従属変数を含んでいます。関数 F は、列
% ベクトルを戻します。ベクトル FTY は、(T,Y)で計算した F です。列ベクトル 
% THRESH は、Y に対する信頼レベルのスレッシュホールドです。すなわち、
% abs(Y(i)) < THRESH(i) を満たす要素 Y(i) の正確な値は重要ではありません。
% THRESH のすべての要素は、正でなければなりません。列 FAC は、ワーキ
% ングストレージです。最初のコールでは、FAC を []に設定します。コールの
% 間で戻り値を変更できません。VECTORIZED は、NUMJAC に、F の複数の
% 値が単一関数計算で得られるか否かを伝えるものです。特に、
% VECTORIZED=1 は、F(t,[y1 y2 ...]) が、[F(t,y1) F(t,y2) ...] を戻し、
% VECTORIZED=2 は、F([x1 x2 ...] ,[y1 y2 ...]) が、[F(x1,y1) F(x2,y2) ...] 
% を戻すことを示します。ODE問題を解くとき、ODE 関数で、F(t,[y1 y2 ...]) が
% [F(t,y1) F(t,y2) ...] を出力するようにコード化されている場合、ODESETを
% 使って、ODEソルバ'Vectorized'プロパティを 'on' に設定します。BVP問題を
% 解くとき、ODE 関数で、F([x1 x2 ...],[y1 y2 ...]) が [F(x1,y1) F(x2,y2) ...] 
% を出力するようにコード化されている場合、BVPSET を使ってBVP ソルバの
% 'Vectorized'プロパティを 'on' に設定します。関数 F をベクトル化することは、
% DFDY の計算のスピードをアップすることになります。
%   
% [DFDY,FAC,G] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED,S,G) は、
% スパースJacobian 行列 DFDY を数値的に計算します。S は、0と1から構成
% される空でないスパース行列です。S(i,j) の中の0 の値は、関数 F(T,Y) の
% i 成分が、ベク トル Y の j 成分に依存していないことを示します(すなわち、
% DFDY(i,j)=0です)。列ベクトル G は、ワーキングストレージです。最初のコー
% ルでは、G を[]に設定してください。コールの間、戻り値を変更しません。
%   
% [DFDY,FAC,G,NFEVALS,NFCALLS] = NUMJAC(...) は、dFdyを作成する間に
% 計算される値の数(NFEVALS)と関数Fの呼び出し回数(NFCALLS)を出力しま
% す。F がベクトル化されない場合、NFCALLS はNFEVALS と等しくなります。
%
% ODE問題を積分する場合、偏微分係数の近似に対して、NUMJAC は特別
% に開発されていますが、他のアプリケーションにも使うことができます。特に、
% F(T,Y)で戻されるベクトルの長さがY の長さと異なる場合、DFDY は長方形
% になります。
%   
% 参考 COLGROUP, ODE15S, ODE23S, ODE23T, ODE23TB, ODESET.

% NUMJAC は、常微分方程式系 Y' = F(T,Y) を積分する場合、偏導関数の近似
% のために、 Salane による非常にロバストなスキームを実行します。これは、
% ODE コードが時刻 T で近似 Y をもち、T+H に進む場合、呼び出されます。
% ODE コードは、Y の誤差を絶対許容誤差 ATOL = THRESH よりも小さくなる
% ように制御します。前のステップで、偏導関数の計算は、 FAC に記録され
% ています。スパースヤコビアンは、関数 F に対する1度の呼び出しで近似
% できる、DFDY の列のグループを見つけるために、COLGROUP(S) を使用して
% 効率的に計算されます。COLGROUP は、2つのスキーム
% (first-fit and first-fit after reverse COLAMD ordering) 
% を実行し、より良いグルーピングを出力します。
%   
%   D.E. Salane, "Adaptive Routines for Forming Jacobians Numerically",
%   SAND86-1319, Sandia National Laboratories, 1986.
%   
%   T.F. Coleman, B.S. Garbow, and J.J. More, Software for estimating
%   sparse Jacobian matrices, ACM Trans. Math. Software, 11(1984)
%   329-345.
%   
%   L.F. Shampine and M.W. Reichelt, The MATLAB ODE Suite, SIAM Journal on
%   Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-28-94
%   Copyright 1984-2002 The MathWorks, Inc. 

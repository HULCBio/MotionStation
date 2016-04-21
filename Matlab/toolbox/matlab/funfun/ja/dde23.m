% DDE23  定数遅れをもつ遅れ微分方程式(DDEs)の解法
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN) は、DDEs 
% y'(t) = f(t,y(t),y(t - tau_1),...,y(t - tau_k)) を解きます。定数の正の遅れ
% tau_1,...,tau_k は、ベクトルLAGSとして入力されます。関数 DDEFUN(T,Y,Z) は
% f(t,y(t),y(t - tau_1),...,y(t - tau_k)) に対応する列ベクトルを出力する必要が
% あります。DDEFUNの呼び出しにおいて、T はカレントの t で、遅れ tau_j = 
% LAGS(J) に対して列ベクトル Y は y(t) を近似し、Z(:,j) は y(t - tau_j) を
% 近似します。DDEは、T0 < TF かつ TSPAN = [T0 TF] のときT0からTFに
% 積分されます。t <= T0 での解は、3種類の方法で HISTORY により指定さ
% れます。HISTORY は、列ベクトル y(t)  を出力する t の関数です。y(t) が
% 定数の場合は、HISTORY はこの列ベクトルです。このDDE23の呼び出しが
% 前のT0の積分を続ける場合は、HISTORY はその呼び出しの解SOLです。
%
% DDE23は、[T0,TF] で連続な解を生成します。解は、DDE23の出力SOLと
% 関数DEVALを使って点TINTにおいて評価されます: YINT = DEVAL(SOL,TINT). 
% 出力SOLは、つぎの要素をもつ構造体です。
%     SOL.x  -- DDE23により選択されたメッシュ
%     SOL.y  -- SOLxのメッシュ点における y(t) の近似
%     SOL.yp -- SOLxのメッシュ点における y'(t) の近似
%     SOL.solver -- 'dde23'
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN,OPTIONS) は、デフォルト
% のパラメータを関数DDESETによって作成された構造体OPTIONS内の値で
% 置き換えて、上記を解きます。詳細は、DDESETを参照してください。一般的
% に使用されるオプションは、スカラの相対許容誤差 'RelTol' (デフォルトでは
% 1e-3 )と、絶対許容誤差ベクトル 'AbsTol' (デフォルトではすべての要素が
% 1e-6)です。
%
% SOL = DDE23(DDEFUN,LAGS,HISTORY,TSPAN,OPTIONS,P1,P2,...) は、
% DDEFUN(T,Y,Z,P1,P2,...) が HISTORY(T,P1,P2,...) のように(関数である場
% 合は) history に渡すように、追加パラメータ P1,P2,... をDDE関数に渡し、
% OPTOINSで指定したすべての関数に渡します。 オプションが設定されてい
% ない場合は、OPTIONS = [] を使ってください。
%
% DDE23は、T0(history)よりも前の解の不連続や、T0の後でのtの既知の値
% での方程式の係数の不連続が、これらの不連続の位置が 'Jumps' オプション
% の値としてベクトルに与えられている場合は、これらの問題を解くことができ
% ます。 
%
% デフォルトでは、解の初期値は、T0 において HISTORY により出力される
% 値です。'InitialY' プロパティの値によっては、異なる初期値が与えられる
% 場合があります。
%
% OPTIONS の 'Events' プロパティが関数EVENTSに設定されていると、
% DDE23は上記のように解き、イベント関数 g(t,y(t),y(t - tau_1),...,y(t - tau_k)) % がゼロとなる点を求めます。 指定する各関数に対して、積分がゼロで終了
% するかどうか、およびゼロクロッシングの方向は重要です。これらは、
% EVENTS: [VALUE,ISTERMINAL,DIRECTION] = EVENTS(T,Y,Z) によって出
% 力される3つのベクトルです。i番目のイベント関数に対して、VALUE(I) は、
% 積分がこのイベント関数のゼロで終了する場合は、関数 ISTERMINAL(I) = 1
% の値で、そうでない場合は0で す。すべてのゼロが計算される(デフォルト)場
% 合は DIRECTION(I) = 0 で、イベント関数が増加した点のみゼロである場合
% は 1 で、イベント関数が減少した点のみゼロである場合は -1 です。フィー
% ルド SOL.xe は、イベントが発生する時間の列ベクトルです。SOL.ye の行は、
% 対応する解で、ベクトル SOL.ie のインデックスは、どのイベントが発生した
% かを指定します。
%   
% 例題    
%         sol = dde23(@ddex1de,[1, 0.2],@ddex1hist,[0, 5]);
% は、区間 [0, 5] においてlags が1および0.2で、関数ddex1deによって計算さ
% れる遅れ微分方程式を解きます。historyは、関数ddex1histによってt <= 0
% に対して計算されます。解は [0 5] の100個の等間隔な点において計算さ
% れます。 
%         tint = linspace(0,5);
%         yint = deval(sol,tint);
% 以下によってプロットします。
%         plot(tint,yint);
% DDEX1は、サブ関数を使ったこの問題がどのようにコード化されるかを示し
% ます。他の例題については、DDEX2を参照してください。  
%   
% 参考 ： DDESET, DDEGET, DEVAL.

%   DDE23 tracks discontinuities and integrates with the explicit Runge-Kutta
%   (2,3) pair and interpolant of ODE23. It uses iteration to take steps
%   longer than the lags.

%   Details are to be found in Solving DDEs in MATLAB, L.F. Shampine and
%   S. Thompson, Applied Numerical Mathematics, 37 (2001). 

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:52:10 $

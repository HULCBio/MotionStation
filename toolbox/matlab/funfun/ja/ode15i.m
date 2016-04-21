%ODE15I  fully implicit 微分方程式を可変次数法(variable order method)
%        で解きます。
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0) は、TSPAN = [T0 TFINAL] の場合、
% 初期条件を Y0,YP0 として、微分方程式系 f(t,y,y') = 0 を時刻 T0 から
% TFINAL まで積分します。関数 ODE15I は、 ODEs とインデックス 1 の
% DAE を解きます。初期条件は、"consistent" (f(T0,Y0,YP0) = 0 を意味
% します)でなければなりません。関数 DECIC は、推定値に近い矛盾のない 
% 初期条件を計算します。関数 ODEFUN(T,Y,YP) は、f(t,y,y') 
% に相当する列ベクトルを返す必要があります。解の配列 Y の各行は、
% 列ベクトル T で返される時間に対応する解です。特定の時刻 T0,T1,...,
% TFINAL (すべて増加、あるいは、すべて減少)で、解を得るためには、
% TSPAN = [T0 T1  ... TFINAL] を使用してください。
%   
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS) は、ODESET 関数で
% 作成された引数、OPTIONS の値で置き換えられたデフォルトの積分特性
% を使用して、上記のように解きます。詳細は、ODESET を参照してください。
% 一般に使用されるオプションは、スカラー相対許容誤差 'RelTol' 
% ( デフォルトで 1e-3 ) と 絶対許容誤差のベクトル 'AbsTol' 
% (すべての成分がデフォルトで 1e-6 ) です。  
%   
% [T,Y] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS,P1,P2...) は、付加
% パラメータ P1,P2,... を、ODEFUN(T,Y,P1,P2...)としてODE 関数と
% OPTIONS に指定されたすべての関数に渡します。オプションが設定されて
% いない場合、プレースホルダとして OPTIONS = [] を使用してください。
%   
% ヤコビ行列 df/dy と df/dy' は、信頼性と効率のために重要です。 
% FJAC(T,Y,YP) が [DFDY, DFDYP] を返す場合、関数 FJAC に対して、
% 'Jacobian'を設定するために、ODESET を使用してください。DFDY = [] 
% の場合、dfdy は、有限差分により近似され、DFDYPに対しても同様です。
% 'Jacobian' オプションが設定されていない場合(デフォルト)、両方の
% 行列が有限差分により近似されます。

% ODE 関数は、ODEFUN(T,[Y1 Y2 ...],YP) が [ODEFUN(T,Y1,YP) 
% ODEFUN(T,Y2,YP) ...] を出力するようにコードされる場合、
% 'Vectorized' {'on','off'} と設定してください。
% ODE 関数 は、ODEFUN(T,Y,[YP1 YP2 ...]) が 
% [ODEFUN(T,Y,YP1) ODEFUN(T,Y,YP2) ...]を出力するようにコードされる
% 場合、 'Vectorized' {'off','on'}と設定してください。
%  
% df/dy または df/dy' がスパース行列の場合、'JPattern' を
% スパースパターン, {SPDY,SPDYP} に対して設定してください。
% df/dy のスパースパターンは、 f(t,y,yp) の要素 i が y の要素 j に
% 依存する場合、SPDY(i,j) = 1 であり、そうでない場合、
% 0 である行列 SPDY です。df/dy が フル行列であることを示すために、
% SPDY = [] を使用してください。df/dy' および SPDYP に対しても同様です。 
% 'JPattern' のデフォルトの値は、{[],[]} です。
%
% [T,Y,TE,YE,IE] = ODE15I(ODEFUN,TSPAN,Y0,YP0,OPTIONS...) は、
% 関数 EVENTS に対して設定されるOPTIONS に'Events' プロパティが
% ある場合、上のように解かれ、イベント関数と呼ばれる、
% (T,Y,YP)の関数がゼロになる点も見つけます。各関数に対して、
% 積分を零点で終えるべきかどうか、および、ゼロクロッシングの方向が
% 問題になるかどうかを指定します。これらは、EVENTS により出力される
% 3つのベクトル、 [VALUE,ISTERMINAL,DIRECTION]= EVENTS(T,Y,YP) です。
% I番目のイベント関数に対して: VALUE(I) は、関数の値です。
% 積分がこのイベント関数のゼロ点で終えられる場合、ISTERMINAL(I)=1 
% であり、そうでない場合、0です。すべてのゼロ点を計算する場合(デフォルト)、
% DIRECTION(I)=0, イベント関数が増加しているところでのゼロ点のみ計算する場合、
% +1, イベント関数が減少しているところでのゼロ点のみ計算する場合、 -1 です。 
% 出力TE は、イベントが起こる時刻の列ベクトルです。YE の行は、対応
% する解であり、ベクトル IE のインデックスは、どのイベントが起こるか
% を指定します。    
%   
% SOL = ODE15I(ODEFUN,[T0 TFINAL],Y0,YP0,...) は、T0 と TFINALの
% 間の任意の点での解、または、解の1階導関数を評価するために DEVAL で
% 使用される構造体を出力します。ODE15I により選択されたステップは、
% 行ベクトル SOL.x に出力されます。各 I に対し、列 SOL.y(:,I) は、
% SOL.x(I) での解を含みます。イベントが見つけられる場合、SOL.xe は、
% イベントが起こる点の行ベクトルです。SOL.ye の列は、対応する解
% であり、ベクトル SOL.ie のインデックスは、どのイベントが起こるか
% を指定します。
%
% 例題
%      t0 = 1;
%      y0 = sqrt(3/2);
%      yp0 = 0;
%      [y0,yp0] = decic(@weissinger,t0,y0,1,yp0,0);
% この例では、 y(t0) に対する初期値を固定するために
% 補助関数 DECIC を使用します。
% Weissinger implicit ODE に対する、y'(t0) に対して矛盾のない
% 初期値を計算します。ODE は、ODE15I を使用して解かれ、数値解が
% 解析解に対して、プロットされます。
%      [t,y] = ode15i(@weissinger,[1 10],y0,yp0);
%      ytrue = sqrt(t.^2 + 0.5);
%      plot(t,y,t,ytrue,'o');
%
% 参考
% オプションハンドリング: ODESET, ODEGET
% 出力関数: ODEPLOT, ODEPHAS2, ODEPHAS3, ODEPRINT
% 解の評価: DEVAL
% ODE の例: IHB1DAE, IBURGERSODE

% Jacek Kierzenka and Lawrence F. Shampine
% Copyright 1984-2003 The MathWorks, Inc.

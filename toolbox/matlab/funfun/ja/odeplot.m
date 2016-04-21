% ODEPLOT   ODE出力関数
%
% 関数 'odeplot' が、'OutputFcn' プロパティとしてODEソルバに渡されるとき、
% すなわち、options = odeset('OutputFcn',@odeplot) のとき、ソルバは時間ス
% テップ毎に、ODEPLOODEPLOT(T,Y,'') を呼び出します。関数 ODEPLOT は、
% 計算の実行中に渡された解のすべての要素を、プロットの軸の範囲をダイナ
% ミックに調節して、プロットします。特定の要素のみをプロットするためには、
% ODEソルバに渡される 'OutputSel' プロパティにインデックスを指定してくださ
% い。ODEPLOTは、出力引数なしでは、ソルバのデフォルトの出力関数です。
%   
% 積分の開始時に、ソルバは出力関数を初期化するために、
% ODEPLOT(TSPAN,Y0,'init') を呼び出します。解のベクトルが Y である時間
% 点 T への積分ステップの後で、ソルバは、STATUS = ODEPLOT(T,Y,'') を
% 呼び出します。ソルバの 'Refine' プロパティが1より大きい場合(ODESETを
% 参照)は、T はすべての新しい出力時間を含む列ベクトルで、Y は対応する
% 列ベクトルからなる配列です。STOPボタンが押されていればSTATUSの
% 出力値は 1で、そうでなければ 0 です。積分が終了すると、ソルバは 
% ODEPLOT([],[],'done') を呼び出します。
%
% ODEソルバが付加的な入力パラメータと共に呼び出される場合、たとえば、
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) において、ソルバはパラ
% メータを出力関数に渡します。たとえば、ODEPLOT(T,Y,'',P1,P2...) のよう
% に行います。  
%   
% 参考 ： ODEPHAS2, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:33 $

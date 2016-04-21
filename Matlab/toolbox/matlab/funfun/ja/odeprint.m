% ODEPRINT  コマンドウィンドウへの印刷 ODE 出力関数
%
% 関数 odeprint が、'OutputFcn' プロパティとしてODEソルバに渡されるとき、
% すなわち、options = odeset('OutputFcn',@odeprint) のとき、ソルバは各時
% 間ステップの後で、ODEODEPRINT(T,Y,'') を呼び出します。関数 ODEPRINT
% は、計算の実行中に渡された解のすべての要素を印刷します。特定の要素
% のみを印刷するためには、ODEソルバに渡される 'OutputSel' プロパティに
% インデックスを指定してください。
%   
% 積分の開始時に、ソルバは出力関数を初期化するために、
% ODEPRINT(TSPAN,Y0,'init') を呼び出します。解のベクトルが Y である新し
% い時間点 T への積分ステップの後で、ソルバは、STATUS = ODEPRINT(T,Y,'')
% を呼び出します。ソルバの 'Refine' プロパティが 1 より大きい場合(ODESET
% を参照)は、T はすべての新しい出力時間を含む列ベクトルで、Y は対応す
% る列ベクトルからなる配列です。ODEPRINTは、常にSTATUS = 0を出力し
% ます。 積分が終了すると、ソルバはODEPRINT([],[],'done') を呼び出します。
%
% ODEソルバが付加的な入力パラメータと共に呼び出される場合、たとえば、   
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) において、ソルバはパラ
% メータを出力関数に渡します。たとえば、ODEPRINT(T,Y,'',P1,P2...) のように
% 行います。  
%   
% 参考 ： ODEPLOT, ODEPHAS2, ODEPHAS3, ODE45, ODE15S, ODESET.


%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:34 $

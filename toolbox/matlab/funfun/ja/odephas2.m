% ODEPHAS2  2次元位相平面のODE出力関数
% 
% 関数 odephas2 が 'OutputFcn' プロパティとしてODEソルバに渡されるとき、
% すなわち、options = odeset('OutputFcn',@odephas2) のとき、ソルバは各時
% 間ステップ毎に、ODEPHAS2(T,Y,'') を呼び出します。関数 ODEPHAS2 は、
% 計算された通りに渡される解の最初の2つの要素を、軸の範囲にダイナ
% ミックに調節しながらプロットします。特定の2つの要素をプロットするために
% は、ODEソルバに渡される 'OutputSel' プロパティにインデックスを指定して
% ください。
%   
% 積分の開始時に、ソルバは出力関数を初期化するために、
% ODEPHAS2(TSPAN,Y0,'init') を呼び出します。解のベクトルが Y である新し
% い時間点への積分ステップの後で、ソルバは STATUS = ODEPHAS2(T,Y,'').
% を呼び出します。ソルバの 'Refine' プロパティが1より大きい場合(ODESETを
% 参照)は、T はすべての新しい出力時間を含む列ベクトルで、Y は対応する
% 列ベクトルからなる配列です。STOPボタンが押されていればSTATUSの
% 出力値は 1 で、そうでなければ 0 です。積分が終了すると、ソルバは
% ODEPHAS2([],[],'done') を呼び出します。
%
% ODEソルバが付加的な入力パラメータと共に呼び出される場合、たとえば、   
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) において、ソルバはパラ
% メータを出力関数に渡します。たとえば、ODEPHAS2(T,Y,'',P1,P2...) のよう
% に行います。  
%   
% 参考 ： ODEPLOT, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.



%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:31 $

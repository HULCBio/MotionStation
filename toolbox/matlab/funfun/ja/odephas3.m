% ODEPHAS3   3次元位相平面のODE出力関数
%
% 関数 odephas3 が 'OutputFcn' プロパティとしてODEソルバに渡されるとき、
% すなわち、options = odeset('OutputFcn',@odephas3) のとき、ソルバは
% 各時間ステップ毎に ODEPHAS3(T,Y,'') を呼び出します。関数 ODEPHAS3 は、
% 計算された通りに渡される解の最初の3つの要素を、軸の範囲にダイナミック
% に調節しながらプロットします。特定の3つの要素をプロットするには、ODE
% ソルバに渡される 'OutputSel' にインデックスを指定してください。
%   
% 積分の開始時に、ソルバは出力関数を初期化するために、
% ODEPHAS3(TSPAN,Y0,'init') を呼び出します。解のベクトルが Ｙ である新し
% い時間点への積分ステップの後で、ソルバは STATUS = ODEPHAS3(T,Y,'')
% を呼び出します。ソルバの 'Refine' プロパティが1より大きい場合(ODESETを
% 参照)は、T はすべての新しい出力時間を含む列ベクトルで、Y は対応する
% 列ベクトルからなる配列です。STOPボタンが押されていればSTATUSの
% 出力値は 1で、そうでなければ 0 です。積分が終了すると、ソルバは ]
% ODEPHAS3([],[],'done') を呼び出します。
%
% ODEソルバが付加的な入力パラメータと共に呼び出される場合、たとえば、   
% ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...) において、ソルバはパラ
% メータを出力関数に渡します。たとえば、ODEPHAS3(T,Y,'',P1,P2...) のよう
% に行います。 
%   
% 参考 ： ODEPLOT, ODEPHAS2, ODEPRINT, ODE45, ODE15S, ODESET.



%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:32 $

% IDDATA/PLOT は、入出力データをプロットします。
% 
%   PLOT(DATA)    
%
% DATA は、IDDATA オブジェクトの入出力データです。
% AXIS は、オブジェクトから得られる軸情報です。
%
% データの一部をプロットするためには、サブリファレンス操作を使います。
%
% PLOT(DATA(201:300))、または、PLOT(DATA(201:300,Outputs,Inputs)) は、P-
% LOT(DATA(201,'Altitude',{'Angle_of_attack','Speed'}))、または、PLOT(D-
% ATA(:,[3 4],[3:7])と同様です。
%
% つぎのステートメントで、複数のデータを比較することができます。
% 
%   PLOT(dat1,dat2,...,datN)
% 
% カラー、ラインスタイル、マーカは、PlotStyle で設定できます。
% 
%   PLOT(dat1,'PlotStyle1',dat2,'PlotStyle2',....,datN,'PlotStyleN')
% 
% PlotStyle は、'b', 'b+:',等々の値を使用できます。HELP PLOT を参照してく
% ださい。
%
% 信号は、同じ InputNames と OutputNames と(複数の実験データには)同じEx-
% perimentNameをもつ信号を各プロットが含むようにプロットされます。Return
% キーを押すたびに、プロットは進みます。CTRL-C をタイプすることで、プロッ
% トを途中で強制終了します。
%
% 入力と出力のデータセットに対して、プロットは、入力/出力のそれぞれの組が
% 別々になるように分離します。入力または出力のどちらかを含んでいないデー
% タセットに対して、信号は別々に表示されます。
%
% 入力信号は、プロパティ'InterSample' (foh あるいは zoh)として、線形に内挿
% してプロットされた曲線、あるいは、階段状のプロットとしてプロットされます。

%   L. Ljung 87-7-8, 93-9-25


%   Copyright 1986-2001 The MathWorks, Inc.
% SQUARE は、矩形波を生成します。
%
% SQUARE(T) は、時間ベクトル T の要素に対して、周期2πをもつ矩形波を生成
% します。SQUARE(T) は、SIN(T) と似ていますが、正弦波ではなく、-1と1のピ
% ークをもつ矩形波を作成します。
% 
% SQUARE(T,DUTY) は、設定された衝撃係数 DUTY をもつ矩形波を生成します。
% 衝撃係数 DUTY とは、信号が正となる周期の割合です。
%
% たとえば、30 Hz の矩形波を発生させます。
%
%      t = 0:.0001:.0625;
%      y = SQUARE(2*pi*30*t);, plot(t,y)
%
% 参考：   SIN, COS, CHIRP, DIRIC, GAUSPULS, PULSTRAN, RECTPULS, 
%          SINC, TRIPULS.



%   Copyright 1988-2002 The MathWorks, Inc.

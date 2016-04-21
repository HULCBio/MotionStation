% GENSIG   LSIM で時間応答シミュレーション用の周期的信号生成器
%
% [U,T] = GENSIG(TYPE,TAU) は、クラス TYPE で、区間 TAU のスカラ信号 Uを生成
% します。つぎのクラスをサポートします。 
%   TYPE = 'sin'        ---   正弦波
%   TYPE = 'square'     ---   矩形波 
%   TYPE = 'pulse'      ---   周期的パルス波
% GENSIG は、サンプル時間のベクトル T とそのサンプル時間での信号値ベクトル
% Uを出力します。生成されたすべてのクラスの信号は振幅1です。
%
%  [U,T] = GENSIG(TYPE,TAU,TF,TS) は、信号の終了時間 TF とサンプル時間 TS を
% 指定して、時間 T を生成します。
%
% 参考 : LSIM, SQUARE, SAWTOOTH.


% Copyright 1986-2002 The MathWorks, Inc.

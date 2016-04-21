% TRIMF 三角形メンバシップ関数
% 
% TRIMF(X,PARAMS) は、X で計算した三角形メンバシップ関数である行列を出
% 力します。PARAMS = [A B C] は、このメンバシップ関数のブレークポイント
% を決定する3要素ベクトルです。通常、A < =  B < =  C を必要とします。
%
% MF は、常に単位高さをもつことに注意してください。単位高さより低い高さ
% の三角関数をもつには、代わりに TRAPMF を使用してください。
%
% 例題
%    x = (0:0.2:10)';
%    y1 = trimf(x,[3 4 5]);
%    y2 = trimf(x,[2 4 7]);
%    y3 = trimf(x,[1 4 9]);
%    subplot(211),plot(x,[y1 y2 y3]);
%    y1 = trimf(x,[2 3 5]);
%    y2 = trimf(x,[3 4 7]);
%    y3 = trimf(x,[4 5 9]);
%    subplot(212),plot(x,[y1 y2 y3]);
%    set(gcf,'name','trimf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, SMF, TRAPMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

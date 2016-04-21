% SMF S型曲線メンバシップ関数
% 
% SMF(X,PARAMS) は、X で計算した S 型メンバシップ関数である行列を出力し
% ます。PARAMS = [X0 X1] は、このメンバシップ関数のブレークポイントを決
% 定する2要素ベクトルです。
% 
% X0 < X1 の場合、SMF は、(X0 のときの)0から(X1 のときの)1への滑らかな移
% 行です。
% 
% X0 > =  X1 の場合、SMF は、(X0+X1)/2 で0から1へジャンプするステップ関
% 数です。
%
% 例題
%    x = 0:0.1:10;
%    subplot(311); plot(x,smf(x,[2 8]));
%    subplot(312); plot(x,smf(x,[4 6]));
%    subplot(313); plot(x,smf(x,[6 4]));
%    set(gcf,'name','smf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

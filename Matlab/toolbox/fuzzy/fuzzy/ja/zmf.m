% ZMF Z型曲線メンバシップ関数
% 
% ZMF(X,PARAMS) は、X で計算する Z 型メンバシップ関数である行列を出力し
% ます。PARAMS = [X1 X0] は、このメンバシップ関数のブレークポイントを決
% 定する2要素ベクトルです。X1 < X0 の場合、ZMF は、(X1 のときの)1から(X0
% のときの)0への滑らかな移行です。X1 > =  X0 の場合、ZMF は、(X0+X1)/2 
% で1から0へジャンプするステップ関数です。
%
% 例題
%    x = 0:0.1:10;
%    subplot(311); plot(x,zmf(x,[2 8]));
%    subplot(312); plot(x,zmf(x,[4 6]));
%    subplot(313); plot(x,zmf(x,[6 4]));
%    set(gcf,'name','zmf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, SMF, TRAPMF, TRIMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

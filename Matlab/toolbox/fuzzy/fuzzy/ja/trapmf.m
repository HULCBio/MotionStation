% TRAPMF 台形メンバシップ関数
% 
% TRAPMF(X,PARAMS) は、X で計算する台形のメンバシップ関数である行列を出
% 力します。PARAMS = [A B C D] は、このメンバシップ関数のブレークポイン
% トを決定する4要素ベクトルです。ここでは、A < =  B と C < =  D を条件と
% します。B > =  C の場合、このメンバシップ関数は単位元より小さい高さを
% もつ三角メンバシップ関数です(以下の例題参照)。
%
% 例題
%    x = (0:0.1:10)';
%    y1 = trapmf(x,[2 3 7 9]);
%    y2 = trapmf(x,[3 4 6 8]);
%    y3 = trapmf(x,[4 5 5 7]);
%    y4 = trapmf(x,[5 6 4 6]);
%    plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','trapmf','numbertitle','off');
%
% 参考   DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%        PSIGMF, SIGMF, SMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

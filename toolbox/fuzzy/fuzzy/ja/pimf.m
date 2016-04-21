% PIMF π型曲線メンバシップ関数
% 
% PIMF(X,PARAMS) は、X で計算したπ型メンバシップ関数である行列を出力し
% ます。
% PARAMS = [A B C D] は、このメンバシップ関数のブレークポイントを決定す
% る4要素ベクトルです。パラメータ A と D は、曲線の"足(π型の値の低くな
% った部分)"を表し、パラメータ B と C は、"肩(π型の値の高くなった部分)"
% を表します。特に、この MF は、SMF と ZMF の積です。
%
%      PIMF(X,PARAMS) = SMF(X,PARAMS(1:2)).*ZMF(X,PARAMS(3:4))
%
% このπ MF は、4つのパラメータをもつため、対称にならないことに注意して
% ください。このことは、2つのパラメータのみを使う、これまでのπ MF と異
% なります。
%
% 例題:
%    x = (0:0.1:10)';
%    y1 = pimf(x,[1 4 9 10]);
%    y2 = pimf(x,[2 5 8 9]);
%    y3 = pimf(x,[3 6 7 8]);
%    y4 = pimf(x,[4 7 6 7]);
%    y5 = pimf(x,[5 8 5 6]);
%    plot(x,[y1 y2 y3 y4 y5]);
%    set(gcf,'name','pimf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

% SIGMF シグモイド曲線メンバシップ関数
% 
% SIGMF(X,PARAMS) は、X で計算したシグモイドメンバシップ関数である行列
% を出力します。PARAMS は、このメンバシップ関数の型と位置を決定する2要素
% ベクトルです。特に、このメンバシップ関数の式は、つぎのとおりです。
%
%    SIGMF(X,[A,C]) = 1./(1 + EXP(-A*(X-C)))
%
% 例題
%    x = (0:0.2:10)';
%    y1 = sigmf(x,[-1 5]);
%    y2 = sigmf(x,[-3 5]);
%    y3 = sigmf(x,[4 5]);
%    y4 = sigmf(x,[8 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = sigmf(x,[5 2]);
%    y2 = sigmf(x,[5 4]);
%    y3 = sigmf(x,[5 6]);
%    y4 = sigmf(x,[5 8]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','sigmf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

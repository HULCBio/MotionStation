% GBELLMF 一般的なベル型曲線メンバシップ関数
% 
% GBELLMF(X,PARAMS) は、X で計算される一般的なベル型メンバシップ関数で
% ある行列を出力します。PARAMS は、このメンバシップ関数の型と位置を設定
% する3要素ベクトルです。より厳密に言えば、このメンバシップ関数の式は、
% つぎのとおりです。
%
%    GBELLMF(X,[A,B,C]) = 1./((1+ABS((X-C)/A))^(2*B));
%
% このメンバシップ関数は、Cauchy 確率分布関数を拡張したものであることに
% 注意してください。
%
% 例題:
%    x = (0:0.1:10)';
%    y1 = gbellmf(x,[1 2 5]);
%    y2 = gbellmf(x,[2 4 5]);
%    y3 = gbellmf(x,[3 6 5]);
%    y4 = gbellmf(x,[4 8 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = gbellmf(x,[2 1 5]);
%    y2 = gbellmf(x,[2 2 5]);
%    y3 = gbellmf(x.[2 4 5]);
%    y4 = gbellmf(x,[2 8 5]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','gbellmf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

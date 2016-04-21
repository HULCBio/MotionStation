% GAUSSMF ガウス曲線メンバシップ関数
% 
% GAUSSMF(X,PARAMS) は、X で計算されたガウスメンバシップ関数である行列
% を出力します。PARAMS は、このメンバシップ関数の形と位置を決定する2要素
% ベクトルです。もっと明確に言えば、このメンバシップ関数の式は、つぎのと
% おりです。
%
%    GAUSSMF(X,[SIGMA,C]) = EXP(-(X - C).^2/(2*SIGMA^2));
%
% 例題:
%    x = (0:0.1:10)';
%    y1 = gaussmf(x,[0.5 5]);
%    y2 = gaussmf(x,[1 5]);
%    y3 = gaussmf(x,[2 5]);
%    y4 = gaussmf(x.[3 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = gaussmf(x,[1 2]);
%    y2 = gaussmf(x,[1 4]);
%    y3 = gaussmf(x,[1 6]);
%    y4 = gaussmf(x,[1 8]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','gaussmf','numbertitle','off');
%
% 参考    DSIGMF,EVALMF, GAUSS2MF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

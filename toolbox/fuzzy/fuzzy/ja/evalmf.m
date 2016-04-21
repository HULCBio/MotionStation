% EVALMF メンバシップ関数の計算
% EVALMF 基本的なメンバシップ関数の計算
%
% 表示
% y = evalmf(x,mfParams,mfType)
% 
% 詳細
% evalmf は、メンバシップ関数を計算します。ここで、x はメンバシップ関数
% 計算での変数の範囲、mfType はツールボックスで用意されているメンバシッ
% プ関数、mfParams は関数に必要なパラメータです。メンバシップ関数名が認
% 識されていないものも計算できるので、ユーザ自身のメンバシップ関数を作成
% したい場合でも、evalmf は機能します。
% 
% 例題
%    x = 0:0.1:10;
%    mfparams = [2 4 6];
%    mftype = 'gbellmf';
%    y = evalmf(x,mfparams,mftype);
%    plot(x,y)
%    xlabel('gbellmf,P = [2 4 6]')
% 
% 参考    DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

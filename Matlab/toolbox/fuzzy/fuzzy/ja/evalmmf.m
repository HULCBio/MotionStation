% EVALMMF 複数のメンバシップ関数計算
% EVALMMF(X,MF_PARA,MF_TYPE) は、i番目の行が、タイプ MF_TYPE(i,:) とパ
% ラメータMF_PARA(i,:) をもつ MF のメンバシップ階級である行列を出力しま
% す。
% 
% MF_TYPE が単
% 一の文字列である場合、これをすべての計算に使用します。
%
% 例題:
%    x = 0:0.2:10;
%    para = [-1 2 3 4; 3 4 5 7; 5 7 8 0; 2 9 0 0];
%    type = str2mat('pimf','trapmf','trimf','sigmf');
%    mf = evalmmf(x,para,type);
%    plot(x',mf');
%    set(gcf,'name','evalmmf','numbertitle','off');
%
% 参考    DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 

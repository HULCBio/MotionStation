% function [sysnlcf,sig,sysnrcf] = sncfbal(sys,tol)
%
% SYSTEM行列の状態空間モデルSYSの正規化された左既約分解と右既約分解の(打
% 切られた)平衡化実現を求めます。SYSNLCFおよびSYSNRCF内の状態空間モデル
% は、両方共SIGによって与えられたHankel特異値を使って、平衡化実現されま
% す。  
% 
%  SYSNLCF = [Nl Ml] and Nl Nl~ + Ml Ml~ = I, SYS = Ml^(-1) Nl
%  SYSNRCF = [Nr;Mr] and Nr~ Nr + Mr~ Mr = I, SYS = Nr Mr^(-1)
%
% 結果は、すべてのHankel特異値がTOLより大きくなるように打切られます。TOL
% が省略されると、MAX(SIG(1)*1.0E-12,1.0E-16)に設定されます。SYSが不可検
% 出であるときには、ワーニングメッセージが表示されます。この場合、出力は
% 信頼できない場合があります。
%
% 参考: HANKMR, SFRWTBAL, SFRWTBLD, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

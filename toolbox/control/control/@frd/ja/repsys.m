% REPSYS   SISO LTIモデルの複製
%
% RSYS = REPSYS(SYS,K) は、SYS をK回繰り返したブロック対角モデル 
% Diag(SYS,...,SYS) を出力します。
% 
% RSYS = REPSYS(SYS,[M N]) は、M行N列のブロックモデル RSYS を作成する
% ために SYS を繰り返し並べます。
%
% 参考 : LTIMODELS.


%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 

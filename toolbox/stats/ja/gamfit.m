% GAMFIT   ガンマ分布データのパラメータ推定 
%
% GAMFIT(X) は、ベクトル X で与えられたガンマ分布のパラメータの最尤推定値
% を出力します。
%
% [PHAT, PCI] = GAMFIT(X,ALPHA) は、与えられたデータの最尤推定値（MLE)
% と 100(1-ALPHA)% の信頼区間を出力します。デフォルトでは、ALPHA = 0.05で、
% 95% の信頼区間に対応します。
%
% [ ... ] = GAMFIT( ..., OPTIONS) は、最尤推定値を計算するために、使用
% される数値的な最適化に対するコントロールパラメータを指定します。この
% 引数は、STATSET をコールして生成されます。パラメータ名とデフォルト値に
% については、STATSET('gamfit') を参照してください。
%
% 参考 : GAMCDF, GAMINV, GAMPDF, GAMRND, GAMSTAT, MLE, STATSET. 


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/04/21 19:42:38 $

% TRANSPOSE   状態空間モデルを転置
%
% TSYS = TRANSPOSE(SYS) は、TSYS = SYS.'で呼び出されます。
%
% データ(A, B, C, D) の状態空間モデル SYS が与えられる場合、TSYS = SYS.' 
% は、(A.' ,C.' ,B.' ,D.')のデータの状態空間モデルを出力します。SYS が
% 伝達関数 H の場合、結果のモデル TSYS の伝達関数は H(s).'です(または、
% 離散時間システムの場合 H(z).')。
%
% 参考 : CTRANSPOSE, SS, LTIMODELS.


%   Author(s): A. Potvin, 3-1-94, P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 

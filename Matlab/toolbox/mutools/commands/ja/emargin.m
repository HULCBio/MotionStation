% function [erow1, erow] = emargin(system,controller,ttol)
%
% 与えられたSYSTEMとCONTROLLERをもつ正のフィードバックループに対して、正
% 規化された既約因子/ギャップ計量ロバスト安定余裕を計算します。
%
% SYSTEM    : テストされる状態空間システム
% CONTROLLER: テストされるコントローラ
% TTOL      : 必要な精度(デフォルトは0.001)
%
% EROW1     : 正規化された既約因子/ギャップ計量ロバスト安定余裕に対する
%             上界
% EROW      : 1行3列の行ベクトルで、上界、下界、上界の周波数を要素として
%             います。
%
% 参考： HINFNORM, SNCFBAL, GAP, NUGAP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

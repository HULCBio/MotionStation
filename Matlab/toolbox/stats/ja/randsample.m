% RANDSAMPLE   無作為標本の復元抽出または非復元抽出
%
% Y = RANDSAMPLE(N,K) は、整数 1:N から、(非復元の)一様かつ無作為に
% 抽出された値の1行K列のベクトルとして Y を出力します。
%
% Y = RANDSAMPLE(POPULATION,K) は、ベクトル POPULATION 内の値から、
% (非復元の)一様かつ無作為に抽出された K 個の値を出力します。
%
% Y = RANDSAMPLE(...,REPLACE) は、REPLACE が真の場合、復元抽出を行い、 
% REPLACE が偽(デフォルト)の場合、非復元の標本を出力します。
%
% Y = RANDSAMPLE(...,true,W) は、正の重み W を用いて重み付けされた標本を
% 出力します。W は、多くの場合、確率のベクトルです。この関数は、復元をの
% 重みつきの標本をサポートしていません。
%
% 例題:  指定された確率により復元を使って、キャラクタ ACGT のランダムな
%        系列を生成します。
%
%      R = randsample('ACGT',48,true,[0.15 0.35 0.35 0.15])
%
% 参考 : RAND, RANDPERM.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/18 17:33:20 $

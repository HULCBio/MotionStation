%GETEXP    IDDATA オブジェクトから特定の実験データを抽出
%
%    D = GETEXP(DAT,ExpNumber)
%    D = GETEXP(DAT,ExpName)
%
%   マルチ実験 IDDATA オブジェクト DAT から、指定した実験データを抽出し
%   ます。ユーザは、番号 (例えば、ExpNumber=2) や名前 (例えば、ExpName=
%   'Day 1') で特定の実験を参照することができます。GETEXP は、要求した
%   実験を含む IDDATA オブジェクト D を出力します。
%
%   使用例: 
%      D = getexp(Dat,2)               D = getexp(Dat,[3 1])
%      D = getexp(Dat,'Period1')       D = getexp(Dat,{'Day 1','Period 2'})
%
%   参考: IDDATA, IDDATA/MERGE, IDDATA/SUBSREF



%   Copyright 1986-2001 The MathWorks, Inc.

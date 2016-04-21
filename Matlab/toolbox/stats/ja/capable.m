% CAPABLE   工程能力指標
%
% CAPABLE(DATA,SPECS) は、ある工程からの標本が、仕様 SPECS の外側に落ちる
% 確率を出力します。DATA に含まれる測定値は、一定の平均値と分散をもつ
% 正規分布をし、測定値は、統計的に独立であると仮定しています。
% 
% SPECS は、下限と上限の2要素からなるベクトルです。下限を設定しない場合、
% -Inf を使い、同様に、上限を設定しない場合、Inf が設定されます。
% 
% [P, CP, CPK] = CAPABLE(DATA,SPECS) は、能力指標 CP と CPK も出力します。


%   B.A. Jones 2-14-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:39 $

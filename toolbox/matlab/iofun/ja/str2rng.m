% STR2RNG   スプレッドシートの範囲文字列を数値配列に変換
% 
% M = STR2RNG(RNG) は、スプレッドシートの表記による範囲を、数値配列
% M = [R1 C1 R2 C2] に変換します。  
%
% 例題
%      str2rng('A2..AZ10') は、ベクトル[1 0 9 51]を出力します。


%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:25 $

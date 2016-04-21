% TIEDRANK   同順位を調整をして、標本のランクを計算
%
% [R, TIEADJ] = TIEDRANK(X) は、ベクトルX の値のランクを計算します
% Xの値が同順位の場合、TIEDRANK は、その平均のランクを計算します。
% 出力値 TIEADJは、ノンパラメトリック検定 SIGNRANK と RANKSUM で必要と
% なる同順位の調整値 TIEADJ を出力します。


%   Tom Lane, 4-16-99
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:04 $

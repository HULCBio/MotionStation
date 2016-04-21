% PHASETICKS   位相プロットに対する45度刻みの目盛りの作成
%
% [NEWTICKS,NEWLIMS] = PHASETICKS(TICKS,LIMS,DataExtent) は、HG-作成の 
% TICKS と軸 LIMS を使って、45度刻みの新しい目盛りと範囲を計算します
% (位相の変動範囲は、90度以上です)。真のデータの広がりは、新しい軸の範囲を
% 計算するために使われます。
%
% NEWTICKS = PHASETICKS(TICKS,LIMS) は、固定された位相の区間に対して、
% 新しい目盛りを計算します。
%
% 参考 : BODE, MARGIN, NICHOLS.


%   Author: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $   $Date: 2003/06/26 16:07:09 $

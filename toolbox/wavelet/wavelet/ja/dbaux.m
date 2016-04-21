% DBAUX　　Daubechies ウェーブレットフィルタの計算
% W = DBAUX(N,SUMW) は、SUM(W) = SUMW を満たす次数 N の Daubechies スケーリング
% ィルタです。N の取り得る値は、N = 1、2、3、..です。
% 
% 注意:
% N をあまり大きくすると不安定になります。
%
% W = DBAUX(N) は、W = DBAUX(N,1) と等価です。
% W = DBAUX(N,0) は、W = DBAUX(N,1) と等価です。
%
% 参考： DBWAVF, WFILTERS.



%   Copyright 1995-2002 The MathWorks, Inc.

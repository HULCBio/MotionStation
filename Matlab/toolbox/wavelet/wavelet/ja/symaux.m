% SYMAUX 　Symletウェーブレットフィルタの計算
% Symlet は、"最小で非対称な"Daubechies ウェーブレットです。 W = WYMAUX(N,SUMW) 
% は、SUM(W) = SUMW となるような、次数 N の Symlet のスケーリングフィルタです。
% N の取り得る値は、
%        N = 1、2、3、...
% です。
% 注意 : 
% N をあまり大きくすると不安定になります。
%
% W = SYMAUX(N) は、W = SYMAUX(N,1) と等価です。W = SYMAUX(N,0) は、W = ...
% SYMAUX(N,1) と等価です。
%
% 参考文献： I. Daubechies, 
%            Ten lectures on wavelets, 
%            CBMS, SIAM, 61, 1994, 198-202 and 254-256.
%
% 参考： SYMWAVF, WFILTERS.



%   Copyright 1995-2002 The MathWorks, Inc.

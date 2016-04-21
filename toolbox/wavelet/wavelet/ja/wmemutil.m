% WMEMUTIL 　メモリ関連ユーティリティ
%
% M = WMEMUTIL('add',M,V) は、メモリブロック M に V を付加します。
% M = WMEMUTIL('add',M,V,IN4) は、メモリブロック M に V を付加します。 
%
% [V,M] = WMEMUTIL('get',M)
% [V,M] = WMEMUTIL('get',M,NUM)
%
% M = WMEMUTIL('set',M,NUM,V)
%
% M = WMEMUTIL('def',N) は、N 個の空の変数をもつメモリブロックを定義します。
%
% I = WMEMUTIL('ind',M,V) は、値 V をもつブロック M のインデックスを取得します。
%
% I = WMEMUTIL('nbb',M) は、メモリブロック M において、nb で指定されたvar ブロッ
% クを取得します。
% 



%   Copyright 1995-2002 The MathWorks, Inc.

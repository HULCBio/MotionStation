% TLCHANDLE   tlcコンテキストのハンドルを表します。
%
% TLCHANDLE は、tlcコンテキストのハンドルを表す単一の整数を持つラッパー
% オブジェクトです。TLC('read',H,'FILENAME.RTW') の代わりに、
% READ(H,'FILENAME.RTW') を用いることができます。
%
% X=TLCHANDLE は、引数を設定しない場合、新たなtlcコンテキストが作成され
% ます。
% 
% X=TLCHANDLE(A) は、A が整数の場合、その整数をTLCHANDLEオブジェクトに
% 変換します。
%
% 参考 : TLCHANDLE/CLOSE, TLCHANDLE/EXECFILE,
%        TLCHANDLE/EXECSTRING, TLCHANDLE/GET,
%        TLCHANDLE/QUERY, TLCHANDLE/READ, TLCHANDLE/SET


%   Copyright 1994-2002 The MathWorks, Inc.

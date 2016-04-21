% GFROOTS   素ガロア体上の多項式の根を検出
%
% すべてのシンタックスで、F は次数 D の多項式の係数を昇ベキの順に並べた
% ものを与える行ベクトルです。
%
% 注意：GFROOTS が各根を一度正確にリストすると、重根を無視します。
%
% RT = GFROOTS(F) は、F が表現する多項式のGF(2^D) の中の根を検出します。
% RT は、列ベクトルで、各要素は、根の指数形式です。指数形式は、GF(2^D)
% 上のデフォルトの原始多項式の根に関連したものです。
%      
% RT = GFROOTS(F, M) は、F が表現する多項式の GF(2^M) の中の根を検出します。
% M は、D 以上の整数です。RT は上でリストされた形式をもっています。
% 指数形式は、GF(2^M)上のデフォルトの原始多項式の根に関連したものです。
%  
% RT = GFROOTS(F, PRIMPOLY) は、PRIMPOLY が、GF(2^M)上での M 次の原始
% 多項式の係数を昇ベキ順で並べた行ベクトルであること以外は、上のシン
% タックスと同じです。
% 
% RT = GFROOTS(F, M, P) は、2が素数 P と置き換わっている以外は、
% RT = GFROOTS(F, M) と同じです。
%
% RT = GFROOTS(F, PRIMPOLY, P) は、2 を素数P で置き換えたこと以外は、
% RT = GFROOTS(F, PRIMPOLY) と同じです。
%
% [RT, RT_TUPLE] = GFROOTS(...) は、k番目の行が根 RT(k) の多項式の形式
% となる行列 RT_TUPLE を出力します。
%
% [RT, RT_TUPLE, FIELD] = GFROOTS(...) は、指数フィールドの要素をリストする
% 行列 FIELD を出力します。 
%
% 参考： GFPRIMDF, GFLINEQ.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $ Date: $

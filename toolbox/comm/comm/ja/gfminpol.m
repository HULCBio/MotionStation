% GFMINPOL   ガロア体の元の最小多項式の探索
%
% PL = GFMINPOL(K, M) は、K の各要素について、最小多項式を生成します。 
% K はスカラか列ベクトルでなければなりません。K の各要素は、指数形式で
% GF(2^M) の元を表現します。つまり、K は alpha^K を表現します。ここで
% alpha は GF(2^M) の原始元です。PL の i 番目の行は、K(i) の最小多項式を
% 表現します。最小多項式の係数は、基底元 GF(2) のもので、昇ベキの順に
% リストされています。
%
% PL = GFMINPOL(K, PRIMPOLY) は、PRIMPOLY が、GF(2^M) についての、昇ベキ
% の順の原始多項式の係数を与えるベクトルであること以外は、同じです。M は
% PRIMPOLY の次数です。
%
% PL = GFMINPOL(K, M, P) は、2 が素数 P で置き換わったこと以外は、
% PL = GFMINPOL(K, M) と同じです。
%
% PL = GFMINPOL(K, PRIMPOLY, P) は、2 が素数 P で置き換わったこと以外
% は、PL = GFMINPOL(K, PRIMPOLY) と同じです。
%
% 参考： GFPRIMDF, GFCOSETS, GFROOTS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:39 $    

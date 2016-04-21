% GFPRIMFD   ガロア体についての原始多項式の検出 
%
% PR = GFPRIMFD(M) は、GF(2^M) 上の次数 M の原始多項式を検出します。
%
% PR = GFPRIMFD(M, OPT) は、GF(2^M) 上の原始多項式を検出します。
%       OPT = 'min'  は、最小重みの原始多項式を検出します。
%       OPT = 'max'  は、最大重みの原始多項式を検出します。
%       OPT = 'all'  は、すべての原始多項式を検出します。 
%       OPT = L      は、重み L のすべての原始多項式を検出します。
% 
% PR = GFPRIMFD(M, OPT, P) は、2を素数 P と置き換えること以外は、
% PR = GFPRIMFD(M, OPT) と同じです。
%
% 出力行ベクトル PR は、昇ベキの順に並べられている係数のリストによって
% 多項式を表現します。
% 例題: GF(5) で、A = [4 3 0 2] は 4 + 3x + 2x^3 を表現します。
%
% OPT = 'all' または L で、複数の原始多項式が制約を満たす場合、PR の各行
% は異なる多項式を表現します。制約を満たす原始多項式がない場合は、PR は
% 空行列になります。
%
% 参考:  GFPRIMCK, GFPRIMDF, GFTUPLE, GFMINPOL.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:44 $

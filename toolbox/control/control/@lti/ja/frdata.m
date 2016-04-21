% FRDATA   周波数応答データへのクイックアクセス
%
%
% [RESPONSE,FREQ] = FRDATA(SYS) は、周波数応答データ(FRD)モデル SYS の応答デー
% タと周波数サンプルを出力します。
%
% Nw 個の周波数点での Nu 入力 Ny 出力の単一のモデル SYS では、RESPONSEは
% Ny*Nu*Nw の配列になり、(I,J,K)の要素は周波数 FREQ(K) での J 番目の入力から
% I 番目の出力までの応答になります。FREQ は、FRD の周波数サンプルを含む長さ
% Nw の列ベクトルです。
%
% [RESPONSE,FREQ,TS] = FRDATA(SYS) は、サンプル時間 TS も出力します。
% SYS のその他のプロパティは、GET を用いて参照するか直接的に構造体ライクに参
% 照できます(たとえば、SYS.Ts)。
%
% 単一のSISOモデル SYS に対して、書式 [RESPONSE,FREQ] = FRDATA(SYS,'v') は、
% 3次元配列ではなく、列ベクトルとして RESPONSE を出力します。
%
% Nu 入力、Ny 出力で、Nw 個の周波数点からなるFRDモデルの S1*S2*...*Sn配列
% SYSに対して、RESPONSE は、サイズ [Ny Nu Nw S1 S2 ... Sn] の配列となり、ここ
% で、RESPONSE(:,:,K,p1,p2,...,pn) は、周波数 FREQ(K) でのモデルSYS(:,:,p1,
% p2,...,n) の応答となります。
%
% 参考 : FRD, GET, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.

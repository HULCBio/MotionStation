% FFPLOT は、周波数の線形スケールで、周波数単位 Hz を使って、周波数関数
% やスペクトルをプロットします。
% 
%   FFPLOT(M)
%   FFPLOT(M,SD)
%   FFPLOT(M,W) 
%   FFPLOT(M,SD,W)
%
% ここで、M は、IDPOLY, IDSS, IDARX, IDGREY と同様に、推定ルーチン(ETFE
% や SPA を含み)で得られる、IDMODEL オブジェクト、または、IDFRD オブジェ
% クトのどちらかです。指定する周波数 W の単位は、Hzです。
%
% 表記法は、BODEと同じになります。詳細は、IDMODEL/BODEを参照してください。
% つぎのように出力引数を指定できます。
% [Mag,Phase,W,SDMAG,SDPHASE] = FFPLOT(M,W)
% W の周波数単位は、Hzです。



%   Copyright 1986-2001 The MathWorks, Inc.

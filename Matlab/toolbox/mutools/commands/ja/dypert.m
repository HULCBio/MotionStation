%function rat_pert = dypert(pvec,blk,bnds,blks)
%
% BNDSにおける下界のピーク値(摂動が最も小さい周波数)で、周波数可変の摂動
% PVECを内挿する安定で有理な摂動を作成します。PVECはMUから作成される摂動
% ベクトルで、BLKはブロック構造、BNDSはMUから作成される上界と下界、BLKS
% は有理摂動出力に含まれるオプションのブロック数です。
%
% 参考: MU, MUUNWRAP, UNWRAPP, SISORAT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

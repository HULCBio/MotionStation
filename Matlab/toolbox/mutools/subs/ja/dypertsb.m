%function rat_pert = dypertsb(pvec,blk,bnds,blks)
%
% BNDSに与えられている下界のピーク値(摂動が最も小さい周波数)で、周波数可
% 変摂動PVECを内挿する安定な有理摂動を作成します。PVECは、MUから生成され
% る摂動ベクトルで、BLKはブロック構造です。BNDSはMUから生成される上界と
% 下界で、BLKSはオプションで、有理摂動出力に含まれるブロック数です。
%
% 参考: MU, UNWRAPD, UNWRAPP, SISORAT.

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:56 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 

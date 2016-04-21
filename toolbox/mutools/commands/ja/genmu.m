% function [bnd,q,dd,gg] = genmu(m,c,blk)
%
% 一般化muの上界の計算
%
% [I - Delta M;C]は、norm < 1/BNDであるBLK内のすべての摂動のDeltaの列の
% ランクがおちないように保証されています。これは、DDとGGに出力されたスケ
% ーリング行列によって確認されるように、mu(M+QC)<=BNDである行列Qによって
% 保証されています。
%
% 参考  MU, CMMUSYN



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

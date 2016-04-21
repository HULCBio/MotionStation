%function [delta,lowerbnd,upperbnd] = wcperf(Mg,blk,pertsizew,npts)
%
%
% 線形分数変換の上側のループに対して、最悪ケースの性能を計算します。
%       
%   入力  : MG        - 入力行列、CONSTANT/VARYING
%           BLK       - ブロック構造
%           PERTSIZEW - 擾乱のサイズ
%	    NPTS      - 擾乱点の数 (デフォルトは 1)
%
%  出力   : DELTA     - 最悪の擾乱
%           LOWERBND  - 擾乱の下界 
%           UPPERBND  - 擾乱の上界 
%
% 参考： MU, DYPERT



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

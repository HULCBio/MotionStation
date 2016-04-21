%function pert = randel(blk,nrm,opt)
%
% 指定したノルムをもつランダムなブロック構造化摂動(すなわち、最大特異値)
% を作成します。ブロック構造は引数BLKによって指定され、ノルムは引数NRMに
% よって指定されます。
%
% 複素ブロックでは、ノルムはNRMと等しく、実数ブロックは、つぎのように指
% 定されたノルムをもちます(デフォルトは'i'です)。
%
% opt = 'i'の場合、実数ブロックはNRM以下のノルムをもちます。opt = 'b'の
% 場合、実数ブロックはNRMと等しいノルムをもちます。
%
% 参考: CRAND, DYPERT, SYSRAND.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 

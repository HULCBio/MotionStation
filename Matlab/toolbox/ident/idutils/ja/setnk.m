% SETNK は、状態空間モデルの中に遅れを設定します。
%
%   [msnew,nannew] = setnk(msold,nanold,nk)
%
% MSOLD, NANOLD は、古い構造をもつもので、a, b, c, d, k, x0 内に通常の構
% 造を使って、遅れ0または1をもっています(0/1 は、DS-行列により決定されま
% す)。
%  
% MSNEW, NANNEW は、MSOLD と同じインパルス応答(遅れを除く)をもち、nk で
% 設定される遅れをもつ新しい構造です。

% $Revision: 1.2 $ $Date: 2001/03/01 22:53:48 $
%   Copyright 1986-2001 The MathWorks, Inc.

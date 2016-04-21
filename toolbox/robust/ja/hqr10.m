% HQR10 は、順序付けられた複素 Schur 分解を行ないます。
%
% [QN,TN,M,SWAP] = HQR10(A) は、安定部が、Tn の上部に、不安定部が下部に位
% 置するように配置された複素 Schur 分解を作成します。
% 
% ここで、
%             Tn = Qn' * A * Qn
%              m = 安定極の数
%           swap = スワップの総数
%
% 複素 Givens 回転は、2つの隣り合った対角項をスワップするために使用されま
% す。
%

% Copyright 1988-2002 The MathWorks, Inc. 

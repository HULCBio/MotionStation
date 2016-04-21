% DECONV   デコンボリューションと多項式の除算
% 
% [Q,R] = DECONV(B,A)は、ベクトルBをベクトルAで除算します。B = conv(A,Q)
% + Rとなるように、商がベクトルQに、剰余がベクトルRに出力されます。
% 
% AとBが多項式の係数ベクトルの場合、デコンボリューションは、多項式の除算
% と等価です。BをAで除算した結果は、Qが商でRが剰余です。
%
% 参考：CONV, RESIDUE.


%   J.N. Little 2-6-86
%   Copyright 1984-2003 The MathWorks, Inc.

% COVF は、データ行列の共分散関数を計算します。
%   R = COVF(DATA,M)
%
%   DATA : IDDATA データオブジェクト、Help IDDATA を参照   
%
%   M: 最大遅れ - 1で、共分散関数で推定されます。
%   Z は、出力-入力データ：Z = [Data.OutputData, Data.InputData].
%   R : Z の共分散関数、要素 R((i+(j-1)*nz,k+1) は、E Zi(t) * Zj(t+k)とな
%       ります。
%       R のサイズは、nz^2 x M です。
% 複素数データ z に対して、RESHAPE(R(:,k+1),nz,nz) = E z(t)*z'(t+k) とな
% ります(z' は、複素共役転置です)。
%
% nz<3 に対して、FFT アルゴリズムが使われ、メモリサイズに制限があります。
% nz>2 に対して、直接和を計算する方法が使われます(COVF2)
%
% メモリのトレードオフは、
% 
%   R = COVF(Z,M,maxsize)
% 
% により与えられます。
%
% 参考： IDPROPS ALGORITHM  オプションの利用法に関して。

%   L. Ljung 10-1-86,11-11-94


%   Copyright 1986-2001 The MathWorks, Inc.
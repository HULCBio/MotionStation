% IDCT 逆離散コサイン変換
%
% X = IDCT(Y)は、DCT変換の逆変換を行い、データ列Yが Y = DCT(X)で得られた
% ものの場合、逆変換により、オリジナルのXを復元します。
%
% X = IDCT(Y,N)は、変換前にベクトルYにゼロを付加するか、あるいは、ベクト
% ルYを切り捨てて長さNにします。
%
% Yが行列の場合、IDCTは各列を変換します。
%
% 参考：   FFT,IFFT,DCT.



%   Copyright 1988-2002 The MathWorks, Inc.

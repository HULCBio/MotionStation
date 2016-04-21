% IDST   逆離散サイン変換を行います。
%
% X = IDST(Y) は、DST 変換の逆関数で、Y が Y = DST(X) を使って得られた場
% 合に元のベクトルを出力します。
%
% X = IDST(Y,N) は、変換する前に、ゼロを付加するかまたは打ち切ってベクト
% ル Y の長さを N にします。
%
% Y が行列の場合、IDST は各列に対して実行します。
% 
% 参考   FFT, IFFT, DST.



%       Copyright 1994-2001 The MathWorks, Inc.

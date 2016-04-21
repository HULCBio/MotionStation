% SQUEEZE   1の次元の削除
%
% B = SQUEEZE(A) は、1の次元が削除された、A と同じ要素をもつ配列 B を
% 出力します。1の次元とは、size(A,dim)==1 のような次元のことです。
% squeeze は、2次元配列に対しては何も行わないので、行ベクトルは行の
% ままです。
%
% 例えば、
%       squeeze(rand(2,1,3))
% は、2行3列になります。
%
% 参照: SHIFTDIM.

%   Clay M. Thompson 3-15-94
%   Copyright 1984-2003 The MathWorks, Inc. 

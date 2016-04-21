% REPMAT   配列の複製行列
% 
% B = REPMAT(A,M,N)は、Aを使って、M行N列分のブロック行列Bを作成します。
%
% B = REPMAT(A,[M N])は、B = REPMAT(A,M,N)と同じ結果になります。
%
% B = REPMAT(A,[M N P ...])は、Aのコピーから構成される M*N*P*...分のブロ
% ック配列を作ります。AはN次元でも構いません。
%
%
% Aがスカラのとき、REPMAT(A,M,N)は、Aの値を要素にもつM行N列の行列を作ります。
%   
% 例題:
%       repmat(magic(2), 2, 3)
%       repmat(NaN, 2, 3)
%       repmat(uint8(5), 2, 3)
%
% 参考 MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc. 

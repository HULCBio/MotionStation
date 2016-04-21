% HAMULT は、構造的な乗算を行います。
%
%   W = hamult(H,Y);
%
% は、vec = (B + A*A') *Y を計算します。ここで、
%
% 入力：
%       Y - A + B'*B と乗算されるベクトル
%       H - A と B を含むセル配列
%       B - 正方行列
%       A - 512 行をもつ行列
%
% 出力：
%       W - 積 (B + A*A') *Y
%

% $Revision: 1.5 $ $Date: 2002/06/17 12:47:46 $

%   Copyright 1990-2002 The MathWorks, Inc.


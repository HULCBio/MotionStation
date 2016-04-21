% FLIPTFORM   構造体 TFORM の入力則と出力則の反転
% TFLIP = FLIPTFORM(T) は、既に存在する構造体 TFORM の中の入力則と出力
% 則を反転することにより、新しい空間的な変換構造("TFORM 構造体")を作成
% します。
%
% 例題
% -------
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       T2 = fliptform(T);
%
% つぎのステートメントは、等価です。
%       x = tformfwd([-3 7],T)
%       x = tforminv([-3 7],T2)
%
% 参考：MAKETFORM, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.

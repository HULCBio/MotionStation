% GETZP  TH2ZPで作成されたZEPOフォーマットから零点と極を抽出
% 
%        [Z,P] = GETZP(ZEPO,KU,KY)
%
%   Z    : 零点
%   P    : 極
%   ZEPO : th2zp から出力された、零点と極の行列
%   KU   : 入力番号(デフォルトは1)。雑音源#juは、入力番号 -ju として表現。
%   KY   : 出力番号(デフォルトは1)
%
% ZEPO のいくつかの要素が同じ入出力関係に対応する場合、Z と P は各モデル
% に対して、一つの列をもちます。Z と P は、仮の 'inf' や零から可能な限り
% 遠ざけられ、明確にされます。
%
% [Z, P, Zsd, Psd] = GETZP(ZEPO, KU, KY)は、零点と極の標準偏差も出力します。
% 

%   Copyright 1986-2001 The MathWorks, Inc.

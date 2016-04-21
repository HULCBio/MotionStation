% PVECで設定されたパラメータベクトルに関する情報を取得します。
%
% [TYP,K,NV] = PVINFO(PV)は、タイプ('box'、または、'pol')、パラメータ数K
% ポリトピックシステムの場合、ポリトピックパラメータ範囲を定義するベクト
% ルの数NVを出力します。
% ボックスの場合:
% ---------
% [PMIN,PMAX,DPMIN,DPMAX] = PVINFO(PV,'par',J)
% 領域の上限と下限、J番目のパラメータの変化率を出力します。
%
% ポリトープの場合:
% --------------
% Vj = PVINFO(PV,'par',J)  ポリトープパラメータ範囲のJ番目の端点を出力し
% ます。
%
% P = PVINFO(PV,'eval',COORD)
% ポリトープ座標を与えるパラメータベクトルの値を出力します。PV = [PV1,..
% .,PVk]、かつ、COORD = [c1,...,ck]ならば、結果は、P = c1*PV1 + ... + ck
% *PVkです。
%
% 参考：    PVEC, PSYS.



% Copyright 1995-2002 The MathWorks, Inc. 

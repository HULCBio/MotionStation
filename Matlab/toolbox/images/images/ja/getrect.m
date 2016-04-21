% GETRECT   マウスによる長方形の選択
%   RECT = GETRECT(FIG) により、マウスを使って、フィギュア FIG のカレ
%   ントの軸で長方形を選択することができます。マウスのクリックとドラッ
%   グを使って、希望の長方形を設定してください。RECT は、形式[xmin 
%   ymin width height]の4要素ベクトルです。長方形を正方形にするには、
%   Shift 、または、右クリックの状態でドラッグしてください。
%
%   RECT = GETRECT(AX) は、ハンドル AX で指定した軸で長方形を選択する
%   ことができます。
%
%   参考 : GETLINE, GETPTS



%   Copyright 1993-2002 The MathWorks, Inc.

% ZPCHART   z-平面のグリッドラインを作成
%
% [GRIDLINES,LABELS] = ZPCHART(AX) は、軸 AX 上に z-平面グリッドラインを
% プロットします。固有周波数と減衰比の範囲は、AX の軸の範囲を基に自動的に
% 決定されます。GRIDLINES と LABELS は、プロットされたグリッドのラインと
% ラベルに対するハンドルを含んでいます。
%
% [GRIDLINES,LABELS] = ZPCHART(AX,ZETA,WN) は、ZETA と WN でそれぞれ
% 設定した減衰比と固有周波数に対して、軸 AX 上に z-平面グリッドをプロット
% します。
%
% [GRIDLINES,LABELS] = SPCHART(AX,OPTIONS) は、構造体 OPTIONS 内のすべての
% グリッドパラメータを指定します。有効なフィールド(パラメータ)は、以下の
% ものを含みます:
%       Damping: 減衰比のベクトル
%       Frequency: 周波数のベクトル
%       FrequencyUnits = '[ Hz | {rad/sec} ]';
%       GridLabelType  = '[ {damping} | overshoot ]';
%       SampleTime     = '[ real scalar | {-1} ]';
%
% 'Hz'の周波数単位が指定され、WN が与えられた場合、WN 値は、'Hz'の
% 単位で与えられるものと仮定されることに注意してください。
%
% 参考 : PZMAP, ZGRID.


%   Revised: Adam DiVergilio, 11-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:22 $


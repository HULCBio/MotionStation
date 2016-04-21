% WFILTERS　 ウェーブレットフィルタ
% [LO_D,HI_D,LO_R,HI_R] = WFILTERS('wname') は、文字列 'wname' で与えられた直交
% または双直交ウェーブレットに関連した4つのフィルタを計算します。4つの出力フィル
% タは、以下のとおりです。
%     LO_D、分解ローパスフィルタ
%     HI_D、分解ハイパスフィルタ
%     LO_R、再構成ローパスフィルタ
%     HI_R、再構成ハイパスフィルタ
% 利用可能なウェーブレット名 'wname' は、以下のとおりです。
%     Daubechies: 'db1'、または、'haar'、'db2'、... ,'db45'
%     Coiflets  : 'coif1'、... 、 'coif5'
%     Symlets   : 'sym2' 、... 、 'sym8'、... ,'sym45'
%     Biorthogonal:
%         'bior1.1'、'bior1.3' 、'bior1.5'
%         'bior2.2'、'bior2.4' 、'bior2.6'、'bior2.8'
%         'bior3.1'、'bior3.3' 、'bior3.5'、'bior3.7'
%         'bior3.9'、'bior4.4' 、'bior5.5'、'bior6.8'.
%     Reverse Biorthogonal: 
%         'rbio1.1'、'rbio1.3' 、'rbio1.5'
%         'rbio2.2'、'rbio2.4' 、'rbio2.6'、'rbio2.8'
%         'rbio3.1'、'rbio3.3' 、'rbio3.5'、'rbio3.7'
%         'rbio3.9'、'rbio4.4' 、'rbio5.5'、'rbio6.8'.
%
% [F1,F2] = WFILTERS('wname','type') は、つぎのフィルタを出力します。
%   'type' = 'd' のとき、LO_D 及び HI_D (分解フィルタ)
%   'type' = 'r' のとき、LO_R 及び HI_R (再構成フィルタ)
%   'type' = 'l' のとき、LO_D 及び LO_R (ローパスフィルタ)
%   'type' = 'h' のとき、HI_D 及び HI_R (ハイパスフィルタ)
%
% 参考： BIORFILT, ORTHFILT, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.

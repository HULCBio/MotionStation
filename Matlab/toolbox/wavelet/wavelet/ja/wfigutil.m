% WFIGUTIL 　フィギュアに関するユーティリティ
% 
%   [XL,YL,POS] = WFIGUTIL('PROP_SIZE',FIG,NBX,NBY)
% 
% XL は、FIG により設定されたフィギュアの nbx x_pixels の正規化された値です。
% YL は、FIG により設定されたフィギュアの nby y_pixels の正規化された値です。
% POS は、FIG により設定されたフィギュアのピクセル単位で示された位置です。
%
% POS = WFIGUTIL('POS',FIG) により、ピクセル単位で示された位置を表示します。
%
% [LEFT,UP] = WFIGUTIL('LEFT_UP',FIG)、または、[LEFT,UP] = WFIGUTIL('LEFT_UP',
% FIG,DX,DY) は、ピクセル単位で、left_up の隅を表示するか、LEFT+DX と UP+DY を表
% 示します。  



%   Copyright 1995-2002 The MathWorks, Inc.

% DWT　 単一レベルの離散1次元ウェーブレット変換
% DWT は、指定された特定のウェーブレット('wname',WFILTERS を参照)、または、指定
% された特定のウェーブレットフィルタ(Lo_D と Hi_D)のいずれかに対応する単一レベル
% での1次元ウェーブレット分解を出力します。
%
% [CA,CD] = DWT(X,'wname') は、ベクトル X のウェーブレット分解で得られた Appro-
% ximation 係数ベクトル CA と Detail 係数ベクトル CD を計算します。'wname' は、
% ウェーブレット名を含む文字列です。
%
% [CA,CD] = DWT(X,Lo_D,Hi_D) は、入力として、つぎのフィルタを与え、上述のウェー
% ブレット分解を計算します。
%   Lo_D は、分解ローパスフィルタです。
%   Hi_D は、分解ハイパスフィルタです。
%   Lo_D と Hi_D は、同じ長さでなければなりません。
%
% LX = length(X) と LF がフィルタ長である場合は、length(CA) = length(CD) = LA に
% なります。ここで、DWT の拡張モードが周期的なモードである場合、LA = CEIL(LX/2) 
% です。他の拡張モードでは 、LA = FLOOR((LX+LF-1)/2) になります。異なる信号拡張
% モードについては、DWTMODE を参照してください。
%
% [CA,CD] = DWT(X,'wname','mode',mode) または
% [CA,CD] = DWT(X,Lo_D,Hi_D,'mode',mode) は、指定可能な拡張モードで、ウェーブレ
% ットの分解を計算します。
%
% 参考： DWTMODE, IDWT, WAVEDEC, WAVEINFO



%   Copyright 1995-2002 The MathWorks, Inc.

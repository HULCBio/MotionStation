% DWT2 　単一レベルの離散2次元ウェーブレット変換
% DWT2は、指定された特定のウェーブレット('wname',WFILTERS を参照)または指定され
% た特定のウェーブレットフィルタ(Lo_D と Hi_D)のいずれかに対応する単一レベルでの
% 2次元ウェーブレット分解を出力します。
%
% [CA,CH,CV,CD] = DWT2(X,'wname') は、入力行列 X のウェーブレット分解で得られた 
% Approximation 係数行列 CA と Detail 係数行列 CH,CV,CD を計算します。'wname' は、
% ウェーブレット名を含む文字列です。
%
% [CA,CH,CV,CD] = DWT2(X,Lo_D,Hi_D) は、入力としてつぎのフィルタを与え、上述の2
% 次元ウェーブレット分解を計算します。
%   Lo_D は、分解ローパスフィルタです。
%   Hi_D は、分解ハイパスフィルタです。
%   Lo_D と Hi_D は、同じ長さでなければなりません。
%
% SX = size(X) で、LF がフィルタ長である場合、size(CA) = size(CH) = size(CV) = 
% size(CD) = SA になります。ここで、DWT 拡張モードが周期的なモードであった場合、
% SA = CEIL(SX/2) です。それ以外の拡張モードの場合、SA = FLOOR((SX+LF-1)/2) にな
% ります。異なる信号拡張モードについては、DWTMODE を参照してください。
%
% [CA,CH,CV,CD] = DWT2(X,'wname','mode',mode)、または、[CA,CH,CV,CD] = DWT2...
% (X,Lo_D,Hi_D,'mode',mode) は、指定可能な拡張モードで、ウェーブレット分解を計算
% できます。
%
% 参考： DWTMODE, IDWT2, WAVEDEC2, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.

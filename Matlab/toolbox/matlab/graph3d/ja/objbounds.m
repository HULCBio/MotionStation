% OBJBOUNDS   オブジェクトの3次元の範囲
%
% LIMS = OBJBOUNDS(H) は、ベクトル H 内のオブジェクトの範囲を計算します。
% LIMS = OBJBOUNDS(AX) は、AX で識別されるaxesの子オブジェクトであるオ
% ブジェクトの範囲を計算します。
% LIMS = OBJBOUNDS は、カレントのaxesの子オブジェクトgcaの範囲を計算し
% ます。
% 
% OBJBOUNDS は、指定したオフジェクトの3次元の範囲を計算します。範囲は、
% [xmin xmax ymin ymax zmin zmax] の形式で出力されます。これは、CAMLOOKAT
% で使用するユーティリティ関数です。
%
% 参考：CAMLOOKAT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:06 $
% RECTPULS は、サンプリングされた周期性をもたない矩形パルスを発生します。
%
% RECTPULS(T) は、配列Tに示されるサンプル点で、連続で、非周期的な単位高
% さの矩形パルスを出力し、T = 0 を中心とします。デフォルトで、矩形の幅は
% 1です。ゼロでない振幅の間隔は、右側にオープンになるように設定します。
% すなわち、RECTPULS(-0.5) = 1, RECTPULS(0.5) = 0 になります。
%
% RECTPULS(T,W)は、は、幅Wの矩形パルスを生成します。
%
% 参考：   GAUSPULS, TRIPULS, PULSTRAN.



%   Copyright 1988-2002 The MathWorks, Inc.

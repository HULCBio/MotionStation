% SCSCOPEDEMO は、スコープトリガ xPC Scope のデモです。
% 
% SCSCOPEDEMO は、xpcsosc.mdl を取得して、それをビルドして、ターゲット PC 
% にダウンロードします。そして、ランダムにモデルの Gain1/Gain(ダンピング)
% パラメータを50回の実行毎に変化させ、数回モデルの実行します。データは、一
% 方のスコープのトリガと同期的にトリガされるスコープから得られます。Scope 
% から集められるデータは、MATLAB フィギュアにプロットされます。

%   Copyright (c) 1996-2001 The MathWorks, Inc. All Rights Reserved.

% PDET2STR は、目盛りの表現を MATLAB 文字列に変換します。
% 
%      [XSTR,YSTR] = PDET2STR(AXES,EXTRAX,EXTRAY)
%
% ハンドル番号 AXES をもつ axes に対して、0,0.1,0.2, ..., 1.0 のような線
% 形間隔の目盛りを、MATLAB の文字列 0:0.1:1.0 に変換します。線形間隔でな
% い場合、空行列が出力されます。オプションの入力引数 EXTRAS は、付加的な
% 挿入する目盛りを示す配列です。

%       Copyright 1994-2001 The MathWorks, Inc.

% CSVREAD   カンマで区切られた値のファイルの読み込み
% 
% M = CSVREAD('FILENAME') は、カンマで区切られた値で書式化されたファイル
% FILENAMEを読み込みます。結果は、M に出力されます。ファイルは、数値のみ
% を含むものです。
%
% M = CSVREAD('FILENAME',R,C) は、カンマで区切られた値で書式化されたファ
% イルの行 R と列 C からデータを読み込みます。R と C は、ゼロを基準として
% いるので、R = 0 と C = 0 はファイル内の最初の値を指定します。
%
% M = CSVREAD('FILENAME',R,C,RNG) は、(R1,C1) が読み込まれるデータの
% 左上隅で、(R2,C2) が右下隅のとき、RNG = [R1 C1 R2 C2] で指定される
% 範囲のみを読み込みます。RNG は、RNG = 'A1..B7' のようなスプレッドシート
% の指定法を使っても指定できます。
%
% CSVREAD は、空のデリミタフィールドを0に設定します。カンマでラインが終了
% しているデータファイルは、すべての要素をゼロで設定した列を最終列に追加
% した結果を作成します。
%
% 参考：CSVWRITE, DLMREAD, DLMWRITE, LOAD, FILEFORMATS


%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:57:57 $

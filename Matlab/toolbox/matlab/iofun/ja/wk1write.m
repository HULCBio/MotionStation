% WK1WRITE   スプレッドシード(WK1)ファイルの書き出し
% 
% WK1WRITE('FILENAME',M) は、行列 M をLotus WK1スプレッドシートファイル
% に指定した名前で書き出します。拡張子が与えられなければ、'.wk1' が追加
% されます。
%
% WK1WRITE('FILENAME',M,R,C) は、行列 M をLotus WK1スプレッドシートファイル
% の行 R と列 C から始まる位置に書き出します。R と C はゼロを基準としている
% ので、R = C = 0 はスプレッドシートの最初のセルです。
% 
% 参考：WK1READ, DLMWRITE, DLMREAD, CSVWRITE, CSVREAD.


%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:35 $

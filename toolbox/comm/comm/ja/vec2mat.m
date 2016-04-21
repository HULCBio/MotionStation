% VEC2MAT   ベクトルを行列に変換
% 
% MAT = VEC2MAT(VEC, MATCOL) は、ベクトル VEC を1行 MATCOL 列の行列に
% 変換します。
% VEC の長さが MATCOL の倍数でない場合、関数は、MAT の最後の行に 0 を
% 加えます。
%
% MAT = VEC2MAT(VEC, MATCOL, PADDING) は、0の代わりに、余分な要素を行列 
% PADDING からの順番に使用すること以外は、最初のシンタックスと同じです。
% PADDING の要素数が不足している場合、最後の要素は残りの要素を使います。
%
% [MAT, PADDED] = VEC2MAT(...) は、MAT の最後の行に設定された余分な要素
% の数を、整数 PADDED に出力します。
%
% 参考:   RESHAPE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $

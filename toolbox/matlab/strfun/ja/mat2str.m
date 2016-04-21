% MAT2STR   行列をevalで可能な文字列に変換
% 
% STR = MAT2STR(MAT) は、行列 MAT を、EVAL(STR) がオリジナルの行列を
% 出力するようなMATLAB文字列に変換します(精度は約15桁です)。スカラでない
% 行列は、鍵括弧 [] を含む文字列に変換されます。
%
% STR = MAT2STR(MAT,N) は、N 桁の精度で変換します。
%
% STR = MAT2STR(MAT, 'class') は、MATが含まれるクラス名で文字列を作成
% します。このオプションは、STRの実行結果がクラス情報も含むことを保証します。
%
% STR = MAT2STR(MAT, N, 'class') は、N桁の精度を利用し、クラス情報を含み
% ます。
%
% 例題
% 
%     mat2str(magic(3)) は、文字列 '[8 1 6; 3 5 7; 4 9 2]' を出力します。
%     a = int8(magic(3))
%     mat2str(a,'class') は、文字列'int8([8 1 6; 3 5 7; 4 9 2])'を生成
%     します。
%
% 参考：NUM2STR, INT2STR, SPRINTF, CLASS, EVAL.


%   Copyright 1984-2002 The MathWorks, Inc. 

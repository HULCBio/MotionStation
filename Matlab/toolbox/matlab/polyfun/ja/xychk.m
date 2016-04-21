% XYCHK   1次元と2次元のデータルーチンの引数のチェック
% 
% [MSG,X,Y] = XYCHK(Y)、または
% [MSG,X,Y] = XYCHK(X,Y)、または
% [MSG,X,Y,XI] = XYCHK(X,Y,XI)は、入力引数を調べ、MSG にエラーメッセージ
% を出力するか、有効な X, Y(と XI)データを出力します。MSG は、エラーが
% なければ空になります。X はベクトルで、Y は length(x) 行(またはベクトル)
% でなければなりません。
%
% [MSG,X,Y] = XYCHK(X,Y,'plot') は、PLOT と同様に扱うことにより、行列 
% X と Y を使うことができます。

%   Copyright 1984-2003 The MathWorks, Inc.
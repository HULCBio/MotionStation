% DEAL   入力を出力へ分配
% 
% [A,B,C,...] = DEAL(X,Y,Z,...)は、入力リストと出力リストの単純なマッチ
% ングを行います。これは、A = X、B = Y、C = Z等と同じです。
% 
% [A,B,C,...] = DEAL(X)は、1つの入力を要求されるすべての出力にコピーしま
% す。これは、A = X、B = X、C = X等と同じです。
%
% DEALは、カンマで区切られた拡張リストによるセル配列や構造体を用いるとき
% に、特に便利です。つぎのような便利な構造があります。
% 
% [S.FIELD] = DEAL(X)は、構造体配列S内のFIELDというフィールドすべてに値X
% を設定します。Sが存在しなければ、[S(1:M).FIELD] = DEAL(X)を使います。
% 
% [X{:}] = DEAL(A.FIELD)は、FIELDという名前のフィールドの値を、セル配列X
% にコピーします。Xが存在しなければ、[X{1:M}] = DEAL(A.FIELD)を使います。
% 
% [A,B,C,...] = DEAL(X{:})は、セル配列Xの内容を、別々の変数A、B、Cにコピ
% ーします。
% 
% [A,B,C,...] = DEAL(S.FIELD)は、FIELDという名前のフィールドの内容を、別
% 個の変数A、B、C...にコピーします。
%
% 例題:
%       sys = {rand(3) ones(3,1) eye(3) zeros(3,1)};
%       [a,b,c,d] = deal(sys{:});
%
%       direc = dir; filenames = {};
%       [filenames{1:length(direc),1}] = deal(direc.name);
%
% 参考： LISTS, PAREN.


%   Copyright 1984-2004 The MathWorks, Inc. 

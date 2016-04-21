% SUBSTRUCT   SUBSREF、または、SUBSASGNのいずれかに対する構造体引数を
%             作成
%
% S = SUBSTRUCT(TYPE1,SUBS1,TYPE2,SUBS2,...) は、オーバロードされた 
% SUBSREF、または、SUBSASGNメソッドにより必要となるフィールドをもつ
% 構造体を作成します。各TYPE 文字列は、 '.'、'()'、 '{}'のいずれかで
% なければなりません。 対応するSUBS 引数は、('.'タイプに対しては)
% フィールド名、または、('()'、か'{}'のタイプに対しては)インデックス
% ベクトルを含むセル配列のいずれかでなければなりません。出力Sは、つぎの
% フィールドを含む構造体配列です:
%
%    type -- サブスクリプトタイプ '.'、'()'、'{}'
%    subs -- 実際のサブスクリプト値 
%            (インデックスベクトルのセル配列またはメンバー名)
%
% たとえば、シンタックス
%
%       B = A(i,j).field
%
% に等価なパラメータ付きSUBSREFは、つぎのステートメントを使います。
%
%       S = substruct('()',{i j},'.','field');
%       B = subsref(A,S);
%
% 同様に、
%
%       subsref(A, substruct('()',{1:2, ':'}))  performs  A(1:2,:)
%       subsref(A, substruct('{}',{1 2 3}))     performs  A{1,2,3}.
%
% 参考： SUBSREF, SUBSASGN.



%       Copyright 1984-2004 The MathWorks, Inc. 

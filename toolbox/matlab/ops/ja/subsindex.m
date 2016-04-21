% SUBSINDEX   サブスクリプトのインデックス
% 
% I = SUBSINDEX(A) は、A がオブジェクトのとき、シンタックス 'X(A)' に
% 対して呼び出されます。X は、組み込みのタイプです(doubleが最も一般的)。
% SUBSINDEXは、ゼロをベースにした整数のインデックスとして、オブジェクト
% の値を出力しなければなりません(I は、0から prod(size(X))-1 の範囲の
% 整数値を含まなければなりません)。SUBSINDEX は、デフォルトでは SUBSREF 
% や SUBSASGN から呼び出され、これらの関数をオーバロードする場合は、
% SUBSINDEX を呼び出せます。
%
% SUBSINDEX は、X(A,B) のような表現の中では、すべてのサブスクリプトに
% 対して個々に呼び込まれます。
% 
% 参考：SUBSREF, SUBSASGN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:05 $

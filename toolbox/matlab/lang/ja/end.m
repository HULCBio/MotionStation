% END   FOR、WHILE、SWITCH、TRY、IFステートメントの適用範囲の終了
% 
% END が入力されなければ、FOR、WHILE、SWITCH、TRY、IFは、さらに入力を
% 待ち続けます。各々のENDは、最も近く、対をなさないFOR、WHILE、SWITCH、
% IFと対になり、その適用範囲を終了させます。
%
% END は、インデックスを使った表現の中では、最後のインデックスを示します。
% す。その中で、k番目のインデックスを使う場合は END = SIZE(X,k)で、これ
% を使って、たとえば、X(3:END) や X(1,1:2:END-1) とします。配列を大きくする
% ために END を使う場合、たとえば、X(end+1) = 5 の場合は、必ず最初にXが
% 存在していなければなりません。
%
% END(A,K,N) は、END が N インデックスの中の K 番目であるとき、オブジェクト A
% を含むインデックス付き表現に対して使用されます。たとえば、表現 A(end-1,:)
% は、END(A,1,2) により A の END メソッドを呼びます。
%
% 参考：FOR, WHILE, SWITCH, TRY, IF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:53 $
%   Built-in function.


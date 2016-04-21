% RSF2CSF   実ブロック対角型から複素ブロック対角型への変換
% 
% [U,T] = RSF2CSF(U,T) は、SCHUR(X) の出力を(X が実数のとき)実Schur型から
% 複素Schur型に変換します。実Schur型は対角要素に実固有値と、2行2列の対
% 角ブロックに複素固有値をもちます。複素Schur型は、対角要素に X の固有値を
% もつ上三角行列です。
% 
% 引数 U と T は、A = U*T*U' と U'*U = eye(size(A)) であるような、行列 A の
% ユニタリ型とSchur型を表わします。
%
% 参考：SCHUR.

%   Copyright 1984-2003 The MathWorks, Inc. 


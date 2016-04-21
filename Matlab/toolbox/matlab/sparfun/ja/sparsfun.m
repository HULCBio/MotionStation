% SPARSFUN   スパース補助関数とパラメータ
% 
% M-ファイルで定義されたMATLAB関数の中には、内部のスパースなデータ構造
% にアクセスするために、最初の引数としてテキストのキーワードを使って、
% この組み込み関数を使うものがあります。たとえば、nnz = sparsfun('nnz',S) 
% や p = sparsfun('colmmd',S) です。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:55 $
%   Built-in function.

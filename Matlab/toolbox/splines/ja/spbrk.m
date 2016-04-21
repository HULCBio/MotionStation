% SPBRK   B-型またはBB-型の構成要素
%
% [KNOTS,COEFS,N,K,D] = SPBRK(SP) は、SP 内のB-型を構成要素に分割し、
% 出力引数によって指定されたものと同じ数を出力します。
%
% OUT1 = SPBRK(SP,PART) は、以下の文字列の1つ(の始まりのキャラクタ)である
% 文字列 PART によって指定された構成要素を出力します。: 
% 'knots' または 't', 'coefs', 'number', 'order', 'dimension', 'interval',
% 'breaks'
%
% PART が、1行2列の行列 [A,B] の場合、端点 A と B をもつ区間への SP 内の
% スプラインの制限/拡張が、同じ型として出力されます。
%
% [OUT1,...,OUTo] = SPBRK(SP, PART1,...,PARTi) は、o<=i のときに、j=1:o 
% での文字列 PARTj によって指定された要素を OUTj に出力します。
%
% SPBRK(SP) は、何も出力しませんが、すべての構成要素を表示します。
%
% 参考 : PPBRK, FNBRK, RSBRK, RPBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

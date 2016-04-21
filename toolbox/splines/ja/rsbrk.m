% RSBRK   B-型の有理スプラインの構成要素
%
% OUT1 = RSBRK(RS,PART) は、以下の文字列の1つ(の始まりのキャラクタ)で
% ある文字列 PART によって指定された個々の構成要素を出力します。:
% 'knots' または 't', 'coefs', 'number', 'order', 'dim'ension, 'interval'
%
% VALUE = RSBRK(RP,[A B]) は、RS にある関数を区間 [A .. B] に制限して
% 出力します。
%
% [OUT1,...,OUTo] = RSBRK(PP, PART1,...,PARTi) は、o<=i であるとき、j=1:o 
% として、文字列 PARTj によって指定された構成要素を OUTj に出力します。
%
% RSBRK(RS) は、何も出力しませんが、すべての構成要素を表示します。
%
% 参考 : RSMAK, RPBRK, PPBRK, SPBRK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

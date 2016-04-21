% STBRK   st-型の構成要素
%
% [CENTERS, COEFS, TYPE, INTERV] = STBRK(ST) は、ST 内のst-型の構成要素を
% 出力引数で指定された数だけ出力します。
%
% OUT1 = STBRK(ST, PART) 以下の文字列の1つ(の始まりのキャラクタ)で
% ある文字列 PART によって指定された個々の構成要素を出力します。:
%    'centers', 'coefficients', 'type ', 'interval', 'dimension', 'var'.
%
% ST = STBRK(ST,INTERV) は、セル配列 INTERV によって指定された値で
% ST 内のst-型の基本区間を変更します。
%
% [OUT1,...,OUTo] = RPBRK(SP, PART1,...,PARTi) は、o<=i が与えられた
% とき、j=1:o での文字列 PARTj によって指定される構成要素を OUTj に出力します。
%
% STBRK(ST) は、何も出力しませんが、すべての構成要素を表示します。
%
% 参考 : STMAK, STCOL, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

% SPVAL   B-型の関数の評価
%
% V = SPVAL(SP,X) は、B-型が SP 内にある関数 f の X の要素での値を出力
% します。
% V = SPVAL(PP,X,'l<anything>') は、左側が連続である f を取得します。
% f がm変数で、3番目の入力引数が実際にm要素のセル、たとえば LEFT の場合、
% LEFT{i}(1) = 'l' であれば、i番目の変数について左から連続になります。
%
% 大まかに言うと、V は、X の各要素を f のそこでの値によって置き換える
% ことで得られます。FNVAL に対するヘルプで説明されているように、詳細は、
% f がスカラ値かそうでないか、また f が1変数かそうでないかによって決まり
% ます。
%
% 参考 : FNVAL, PPUAL, RSVAL, STVAL, PPVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

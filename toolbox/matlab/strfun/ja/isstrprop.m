%ISSTRPROP 文字列の要素が指定したカテゴリであるかを確認
% B = ISSTRPROP(S,C) は、Sと同じ形状の論理配列をBに出力します。これは、
% Sの要素が文字列カテゴリCであることを確認します。Sのタイプは、セル配列、
% 文字、または任意のMATLAB数値タイプでかまいません。Sはセル配列の場合は、
% BはSと同じ形状のセル配列です。Sの要素の分類は、指定したカテゴリのUnicode
% 定義に従って行われます。つまり、入力配列内の要素の数値がUnicodeキャラクタ
% カテゴリを定義する範囲にある場合は、この要素は、そのカテゴリであると分類
% されます。Unicodeキャラクタコードの集合は、ASCII キャラクタコードを含みま
% すが、ASCIIセットの範囲よりも広い言語をカバーします。キャラクタの分類は、
% MATLABのlocale設定によります。 
%
% 入力引数
%
% S は、char, int8, uint8, int16, uint16, int32, uint32, int64,
% uint64, double, セル配列のいずれかです。セル配列は、上記のタイプの配列を含む
% ことが可能です。
%   
% タイプdoubleの数値は、MATLABのdouble-to-intの変換法則にしたがってint32に
% 変換されます。int32(inf)よりも大きいタイプint64およびuint64の数値は、
% int32(inf)になります。 
%
% 引数Cは、つぎの文字列でなければなりません:
% 'alpha'     : Sを英字として分類
% 'alphanum'  : Sを英数字として分類
% 'cntrl'     : Sをコントロールキャラクタ, char(0:20)として分類
% 'digit'     : Sを数値として分類
% 'graphic'   : Sをグラフィックスキャラクタとして分類。これらは、
%             {unassigned, space, line separator, paragraph separator, control
%             characters, Unicode format control characters, private
%             user-defined characters, Unicode surrogate characters, Unicode
%             other characters}でないキャラクタを表わすすべての値です。
% 'lower'     : Sを小文字として分類
% 'print'     : Sをグラフィックスキャラクタ、プラスchar(32)として分類             
% 'punct'     : Sを句読点キャラクタとして分類
% 'wspace'    : Sを空白キャラクタとして分類; この範囲は、空白のANSI C 定義
%             {' ','\t','\n','\r','\v','\f'}を含みます。
% 'upper'     : Sを大文字として分類
% 'xdigit'    : Sを有効な16進数として分類
%
%   例題
%
% B = isstrprop('abc123efg','alpha') は、B  => [1 1 1 0 0 0 1 1 1]を出力します。
% B = isstrprop('abc123efg','digit') は、B  => [0 0 0 1 1 1 0 0 0]を出力します。
% B = isstrprop('abc123efg','xdigit') は、B => [1 1 1 1 1 1 1 1 0]を出力します。
% B = isstrprop([97 98 99 49 50 51 101 102 103],'digit') は、
%     B => [0 0 0 1 1 1 0 0 0]を出力します。
% B = isstrprop(int8([97 98 99 49 50 51 101 102 103]),'digit') は、
%     B => [0 0 0 1 1 1 0 0 0]を出力します。
% B = isstrprop(['abc123efg';'abc123efg'],'digit') は、
%     B => [0 0 0 1 1 1 0 0 0; 0 0 0 1 1 1 0 0 0]を出力します。
% B = isstrprop({'abc123efg';'abc123efg'},'digit') は、
%     B => {[0 0 0 1 1 1 0 0 0]; [0 0 0 1 1 1 0 0 0]}を出力します。
% B = isstrprop(sprintf('abc\n'),'wspace') は、B  => [0 0 0 1]を出力します。
%
%   参考: ISCHAR.







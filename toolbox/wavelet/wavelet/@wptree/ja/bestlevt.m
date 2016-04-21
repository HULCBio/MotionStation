%BESTLEVT   ウェーブレットパケットツリーの最適レベル
%   BESTLEVT は、エントロピータイプの基準を考慮した初期ツリーの最適なす
%   べてのサブツリーを計算します。結果のすべてのツリーは、初期のものより%   も浅くなります。
%
%   T = BESTLEVT(T) は、最適なレベルのツリー分解に対応する、修正されたツ%   リー T を計算します。
%
%   [T,E] = BESTLEVT(T) は、最適なツリー T に加え、最適なエントロピー値 %   E を出力します。
%   インデックス j-1 のノードの最適なエントロピーは、E(j) です。
%
%   参考: BESTTREE, WENTROPY, WPDEC, WPDEC2

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.


%   Copyright 1995-2002 The MathWorks, Inc.

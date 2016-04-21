% FNRFN   F に対する区分に追加のサイトを挿入
%
% FNEW = FNRFN(F) と FNRFN(F,'mid') は、共に同じ形式で、F にある関数の
% 記述を出力しますが、その区分間隔のそれぞれに中点を挿入することにより
% 改良された区分として出力します。
%
% FNEW = FNRFN(F,ADDPTS) は、同じ形式で、F にある関数の記述を出力しま
% すが、ADDPTS の列で、サイトを挿入することで改良される区分を出力します。
% ADDPTS が空の場合、追加されるサイトはありません。
%
% 関数がB-型の場合、ADDPTS は、スプラインの次数を超えて節点の多重度
% を増加させない範囲で、追加する節点として解釈されます。
%
% 関数がpp-型である場合、ブレークポイントの列にまだ存在しない ADDPTS の
% 各要素が、追加のブレークポイントとして使用されます。
%
% F にある関数がm変数関数の場合、ADDPTS は、長さ m のセル配列でなければ
% なりません。このj番目のセルは、もしあれば、j番目の変数に追加のサイト
% を指定します。
%
% 例題:
% B-型スプラインを作成してプロットし、その後、2つの中点を用いた改良を
% 適用します。さらに、改良された結果のスプラインの制御多角形を、スプライン
% 自身に非常に近いものであるとみなし、プロットします。
%
%      k = 4; sp = spapi( k, [1,1:10,10], [cos(1),sin(1:10),cos(10)] );
%      fnplt(sp), hold on
%      sp3 = fnrfn(fnrfn(sp));
%      plot( aveknt( fnbrk(sp3,'knots'),k), fnbrk(sp3,'coefs'), 'r')
%      hold off 
%
% 第3の改良では、2つの曲線を区別できないようにします。
%
% 他の例として、同じ次数をもつ2つのB-スプラインを加えるために、FNRFN 
% を使用します。
%
%      B1 = spmak([0:4],1); B2 = spmak([2:6],1);
%      B1r = fnrfn(B1,fnbrk(B2,'knots'));
%      B2r = fnrfn(B2,fnbrk(B1,'knots'));
%      B1pB2 = spmak(fnbrk(B1r,'knots'),fnbrk(B1r,'c')+fnbrk(B2r,'c'));
%      fnplt(B1,'r'),hold on, fnplt(B2,'b'), fnplt(B1pB2,'y',2)
%      hold off
%   
% 参考 : PPRFN, SPRFN, FNCMB.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

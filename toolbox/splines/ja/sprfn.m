% SPRFN   スプラインのB-型に追加する節点を挿入
%
% SPRFN(SP,ADDKNOTS) は、SP 内に含まれたスプラインのB-型に、指定された
% ADDKNOTS を挿入します。(ADDKNOTS が)空の場合は、サイトに挿入されません。
%
% SPRFN(SP) は、すべての重要な節点の区間の中間点を挿入します。
%
% 節点の多重度は、スプラインの次数を越えて増加することはありません。
%
% SP がm変数スプラインを記述する場合、ADDKNOTS は、m個の要素のセル配列
% である必要があります。いずれかの節点列に改良を施したくない場合は、対応
% する要素を空にします。
%
% 参考 : FNRFN, PPRFN.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

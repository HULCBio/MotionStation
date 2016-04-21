% PPRFN   pp-型に付加的なブレークポイントを挿入
%
% PPRFN(PP,ADDBREAKS) は、ADDBREAKS のすべての点も含むために改良された
% ブレークポイント列をもつ形で、PP にある関数のpp-型を出力します。
%
% PPRFN(PP) は、PP の節点の区間のすべての中間点を挿入します。
%
% PP がm変数スプラインを記述する場合、ADDBREAKS は、m個の要素をもつセル
% 配列である必要があり、いずれかの変数のブレークポイント列に改良を施し
% たくない場合は、対応する要素を空にします。
%
% 参考 : FNRFN, SPRFN.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.

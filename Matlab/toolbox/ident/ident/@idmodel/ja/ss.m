% IDMODEL/SS は、LTI/SS フォーマットに変換します。
%
%   SYS = SS(MODEL)
%
% MODEL は、任意の IDMODEL オブジェクト(IDPOLY, IDSS, IDARX, IDGREY) で
% す。
% SYS は、Control System Toolbox の LTI/SS オブジェクトフォーマットにな
% ります。
%
% MODEL の中のノイズ源 - 入力(e) は、InputGroup 'Noise' としてラベル付け
% されています。一方、測定入力は、'Measured' としてグループ化されていま
% す。最初に、SYS の中のノイズ入力が単位分散をもつ無相関の源に対応するよ
% うに、ノイズチャンネルを正規化します。
%
% SYS = SS(MODEL('Measured'))、あるいは、SYS = SS(MODEL,'M')は、ノイズ入
% 力を無視します。
%
% SYS = SS(MODEL('noise')) は、ノイズチャンネルのみを表示します。
%
% 参考： IDSS.



%   Copyright 1986-2001 The MathWorks, Inc.

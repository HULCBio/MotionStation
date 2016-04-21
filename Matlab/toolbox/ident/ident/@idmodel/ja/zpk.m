% IDMODEL/ZPK は、LTI/ZPK フォーマットに変換します。
%
%   SYS = ZPK(MODEL)
%
% MODEL は、任意の IDMODEL オブジェクト(IDPOLY, IDSS, IDARX, IDGREY) で
% す。
% SYS は、Control System Toolbox の LTI/ZPK オブジェクトフォーマットにな
% ります。
%
% MODEL の中のノイズ源 - 入力(e) は、InputGroup 'Noise' としてラベル付け
% されています。一方、測定入力は、'Measured' としてグループ化されていま
% す。最初に、SYS の中のノイズ入力が単位分散をもつ無相関の源に対応するよ
% うに、ノイズチャンネルを正規化します。
%
% SYS = ZPK(MODEL('Measured')) 、あるいは、SYS = ZPK(MODEL, 'M')は、ノイ
% ズ入力を無視します。
%
% SYS = ZPK(MODEL('noise')) は、(上で正規化された)ノイズ源から出力までの
% 伝達関数システムを与えます。
%
% 参考： IDMODEL/ZPKDATA, IDMODEL/SS, LTI/ZPK



%   Copyright 1986-2001 The MathWorks, Inc.

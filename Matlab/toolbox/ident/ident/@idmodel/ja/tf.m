% IDMODEL/TF は、LTI/TF フォーマットに変換します。
%
%   SYS = TF(MODEL)
%
% MODEL は、任意の IDMODEL オブジェクト(IDPOLY, IDSS, IDARX, IDGREY) で
% す。
% SYS は、Control System Toolbox の LTI/TF オブジェクトフォーマットにな
% っています。
%
% MODEL の中のノイズ源 - 入力(e) は、InputGroup 'Noise' としてラベル付け
% されています。一方、測定入力は、'Measured' としてグループ化されていま
% す。最初に、SYS の中のノイズ入力が単位分散をもつ無相関の源に対応するよ
% うに、ノイズチャンネルを正規化します。
%
% SYS = SS(MODEL('Measured'))、あるいは、SYS = TF(MODEL,'m')は、ノイズ
% 入力を無視します。
%
% SYS = SS(MODEL('noise')) は、(上で記述されたように正規化された)ノイズ源
% から出力までの伝達関数システムを与えます。
%
% 参考 TF, IDMODEL/SS.



%   Copyright 1986-2001 The MathWorks, Inc.

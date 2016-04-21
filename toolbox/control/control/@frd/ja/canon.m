% CANON   正準型状態空間実現
%
% CSYS = CANON(SYS,TYPE) は、LTIシステム SYS に対して、正準型状態空間
% モデル CSYS を計算します。文字列 TYPE で、正準型のタイプを選択します。
% 
% 'modal'    : Modal 正準型です。ここで、システムの固有値は、対角上に現れ
%              ます。システム行列 A は、対角化可能でなければいけません。
% 
% 'companion': Companion正準型です。ここで、特性多項式が右端の列に現れ
%              ます。
%
% [CSYS,T] = CANON(SYS,TYPE) は、元の状態ベクトル x を新しい状態ベクトル
% z に、z = Tx で変換する行列 T も出力します。この書式は、SYS が状態空間
% モデルであるときのみ有効です。
%
% modal型は、システムのモードに対する相対的な可制御性を決定する場合に
% 有効です。
% 注意: Companion型は、条件数が悪くなるので、可能な限り避けるべきです。
%
% 参考 : SS2SS, CTRB, CTRBF, SS.


%   Clay M. Thompson  7-3-90
%   Revised: P. Gahinet  6-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 

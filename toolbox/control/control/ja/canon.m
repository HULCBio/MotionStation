% CANONは、正準型状態空間実現を行います。
%
%
% CSYS = CANON(SYS,TYPE) は、LTI システム SYS に対して、正準型状態空間モデル
% CSYS を計算します。文字列 TYPE で、正準型のタイプを選択します。
%    'modal'    :  Modal 正準型です。 ここで、システムの固有値は、対角上に
%                  現れます。状態行列 A は、対角化可能でなければいけません。
%    'companion':  Companion 正準型です。 ここで、特性多項式が CompanionA 行列
%                  の右端の列に現れます。
%
% [CSYS,T] = CANON(SYS,TYPE) は、元の状態ベクトル x を新しい状態ベクトルz
% に、z = Tx で変換する行列 T も出力します。この書式は、SYS が状態空間モデルで
% あるときのみ有効です。
%
% modal 型は、システムのモードに対する相対的な可制御性を決定する場合に有効で
% す。注意: Companion 型は、条件数が悪くなるので、可能な限り避けるべきです。
%
% 参考 : SS2SS, CTRB, CTRBF, SS


% Copyright 1986-2002 The MathWorks, Inc.

% IDMODEL は、IDMODEL 親オブジェクトに対するコンストラクタです。
%
% IDMODEL は、System Identification Toolbox で使われるモデルオブジェクト
% IDPOLY, IDSS, IDARX, IDGREY の親オブジェクトです。詳細は、IDHELP を参
% 照してください。
%
% M = IDMODEL(NY,NU) は、NY 出力、NU 入力をもち、デフォルトのサンプル時
% 間1をもつ IDMODEL オブジェクトを作成します。
%
% M = IDMODEL(NY,NU,TS) は、NY 出力、NU 入力をもち、デフォルトのサンプル
% 時間 TS をもつ IDMODEL オブジェクトを作成します。
%
% M = IDMODEL(NY,NU,TS,PV,CM) は、NY 出力、NU 入力をもち、デフォルトのサ
% ンプル時間 TS をもち、パラメータベクトル PV、共分散行列 CM をもつ ID-
% MODEL オブジェクトを作成します。
%
% 注意：
% この関数は、ユーザ用に作成されたものではありません。IDMODEL オブジェク
% トを作成するために、IDSS, IDPOLY, IDARX, IDGREY で使われます。



%   Copyright 1986-2001 The MathWorks, Inc.

% IDSIMSD  シミュレーションされたモデル応答内に不確かさを表示
% 
%   IDSIMSD(U,Model)
%
% U は、入力を含む列ベクトル(行列)、または、IDDATA オブジェクトです。
% Model は、任意の IDMODEL オブジェクト(IDPOLY, IDARX, IDSS, GREYBOX)で
% 設定されるモデルです。Model の共分散情報と一致する情報をもつ10個のラン
% ダムなモデルが作成されます。そして、U に関するこれらのモデルの個々の応
% 答が同じ図内にプロットされます。
%
% 計算されるモデル数、10は、IDSIMSD(U,Model,N) の N を変更することにより、
% 任意に設定できます。
%
% IDSIMSD(U,Model,N,'noise',KY) を使って、ノイズが、Model のノイズモデル
% に従って、シミュレーションに付加されます。KY は、プロットされる出力番
% 号を規定します(デフォルトはすべて)。
%
% 参考： IDSIM

%   Copyright 1986-2001 The MathWorks, Inc.

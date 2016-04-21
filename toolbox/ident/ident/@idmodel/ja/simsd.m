% SIMSD  シミュレーションされたモデル応答内に不確かさを表示
% 
%   SIMSD(Model,U)
%
% U は、入力を含む列ベクトル(行列)、または、IDDATA オブジェクトです。
% Model は、任意の IDMODEL オブジェクト(IDPOLY, IDARX, IDSS, IDGREY)で
% 設定されるモデルです。Model の共分散情報と一致する情報をもつ10個のラン
% ダムなモデルが作成されます。そして、U に関するこれらのモデルの個々の応
% 答が同じ図内にプロットされます。
%
% 計算されるモデル数、10は、SIMSD(Model,U,N) の N を変更することにより、
% 任意に設定できます。
%
% SIMSD(Model,U,N,'noise',KY) を使って、ノイズが、Model のノイズモデルに
% 従って、シミュレーションに付加されます。KY は、プロットされる出力番号
% を規定します(デフォルトはすべて)。
%
% 参考： IDMODEL/SIM

%   L.Ljung 7-8-87


%   Copyright 1986-2001 The MathWorks, Inc.

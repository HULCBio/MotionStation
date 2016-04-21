% SCHART   標準偏差をモニタする統計的工程管理図
%
% SCHART(DATA,CONF,SPECS) は、DATA の中でグループ化された応答の S 管理図
% を作成します。DATA の行は、与えられた時間での観測を表わします。行は、
% 時間順でなければなりません。
%
% CONF(オプション) は、信頼レベルの上限と下限を示します。CONF はデフォルト
% で0.9973です。これは、プロットされた点の 99.73%のものが、管理の範囲に
% 入ることを意味しています。
%
% SPECS(オプション) は、応答の下限と上限を指定する2要素ベクトルです。
%
% OUTLIERS = SCHART(DATA,CONF,SPECS) は、DATA の標準偏差から外れている
% 行のインデックスを示すベクトルを出力します。
%
% [OUTLIERS, H] = SCHART(DATA,CONF,SPECS) は、プロットしたラインのハンドル
% 番号を H に出力します。


%   B.A. Jones 2-13-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:15:37 $

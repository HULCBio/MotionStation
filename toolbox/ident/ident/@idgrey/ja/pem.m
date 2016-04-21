% IDGREY/PEM は、一般的な線形モデルの予測誤差推定を計算します。
%   MODEL = PEM(DATA,Mi)  
%
% MODEL: IDGREY オブジェクト書式で、推定される共分散と構造の情報を含んだ
% 推定モデルを出力します。M の厳密な書式に関しては、IDPROPS IDGREY とタ
% イプしてください。
%
%   DATA: IDDATA オブジェクトフォーマットで記述した推定に使用するデータ。
%         help IDDATA を参照してください。
%
%   Mi  : モデル構造を定義する IDGREY オブジェクト。help IDGREY を参照し
%         てください。
%
% MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n) によ
% り、モデル構造とアルゴリズムに関連したすべてのプロパティを設定できます。
% プロパティ名/値に関する一覧は、IDPROPS IDGREY や IDPROPS ALGORITHM と
% 入力してください。特に、プロパティ 'InitialState' と 'DisturbanceModel'
% が、Mファイルでのパラメトリゼーションを拡張・上書きする値に設定できるこ
% とに注意してください。


%	L. Ljung 10-1-86, 7-25-94


%	Copyright 1986-2001 The MathWorks, Inc.

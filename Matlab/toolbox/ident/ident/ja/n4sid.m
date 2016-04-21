% N4SID は、部分空間法を使って、状態空間モデルを推定します。
%   
%   MODEL = N4SID(DATA) 
%   MODEL = N4SID(DATA,ORDER) 
%
%   MODEL : 推定された状態空間モデルを、IDSS フォーマットで出力
%   DATA  : 出力、入力データを IDDATA オブジェクトで設定。HELP IDDATA を
%           参照。
%   ORDER : モデルの次数(状態ベクトルの次元)。一つのベクトル(たとえば、
%           3:10)として入力した場合、すべての状態の次数に関する情報とし
%           て、プロットの中に与えられます。( 1 よりも大きい入力遅延(以下
%           に示す NK )を指定すると余分な状態を付加し、結果としてより次数
%           の高いモデルになります。) ORDERとして 'best' を指定すると、
%           1:10 のデフォルト次数の中から選択されます。デフォルトでは、
%           'best' になります。
%           ORDER は、IDSS モデルオブジェクトで設定することもでき、この
%           場合、すべてのモデル構造とアルゴリズムのプロパティを、このオ
%           ブジェクトから得ることもできます。
%
% MODEL = N4SID(DATA,ORDER,Property_1,Value_1, ...., Property_n,Value_n)
% は、モデル構造とアルゴリズムに関連したすべてのプロパティを与えることが
% できます。プロパティ名/値の組の一覧については、IDSS を参照してください。
% 有効なモデル構造プロパティは、つぎのものです。
%     'Focus' : ['Prediction'|'Simulation'|フィルタ|'Stability']
%               'Simu' と 'Stab' は、モデルの安定性を補償します。
%     'nk': それぞれの入力からの遅れを設定した行ベクトル
%     初期状態は常に推定されますが、MODEL に反映するためには、
%     'InitialState' = 'Estimate' を設定しなければいけません。
%     'DisturbanceModel' = 'None' とすると、K 行列として 0 が出力され、
%     モデルの安定性が補償されます。デフォルトは、'DisturbanceModel' =
%     'None' です。
%
% 計算のほとんどの時間は、分散の推定にかかります。'CovarianceMatrix' =
% 'None' とすることで、分散の計算を省略します。
%
% アルゴリズムは、つぎのプロパティで与えられます。
%   'N4Weight'      : ['Auto'|'MOESP'|'CVA']  重みの決定。
%                     SVD の前。'Auto' は、自動選択を行います。
%   'N4Horizon'     : アルゴリズムで使用する予測平面の決定。
%      
%    N4Horizon  = [r,sy,su], ここで、
%       r  : 最大予測平面
%       sy : 予測に使用する過去の出力数
%       su : 予測に使用する過去の入力数
%       N4Horizon が複数の行をもつ場合、各行が試されます。
%       N4Horizon = 'Auto' (デフォルト) は、妥当な平面を推定します。
%       'DisturbanceModel' = 'None' がデフォルトで、この場合、sy = 0 と
%       なります。
%
%   'Trace'         : ['On'|'Off']  'On' は、スクリーン上に、適合状況や
%                     N4Horizon の選択状況を表示します。
%   'MaxSize'       : maxsize 要素より大きい行列は作成されません。大きい
%                     ものが必要な場合は、ループを使ってください。
%
% 参考：  PEM , HELP IDPROPS

%   M. Viberg, 8-13-1992, T. McKelvey, L. Ljung 9-26-1993.
%   Rewritten; L. Ljung 8-3-2000.


%   Copyright 1986-2001 The MathWorks, Inc.%

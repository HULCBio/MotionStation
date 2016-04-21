% PEM は、一般線形モデルの予測誤差推定を計算します。
% 
%   MODEL = PEM(DATA,Mi)  
%
%   MODEL : 推定するモデルを IDPOLY、または、IDSS オブジェクトフォーマッ
%           トの型で、推定した共分散と構造情報と共に出力します。
%           Model.NoiseVariance は、DATA から推定されたイノベーション分
%           散です。MODEL の正確なフォーマットは、HELP IDPOLY とHELP IDSS
%           を参照してください。
%
%   DATA :  IDDATA オブジェクトフォーマットで記述された推定に使用するデ
%           ータ。HELP IDDATA を参照。
%
%   Mi   : モデル構造を定義する行列、または、オブジェクト 
%           Mi = nx (an integer) は、次数 nx の一般線形状態モデルを与え
%           ます。
%     
%           Mi = [na nb nc nd nf nk] は、つぎのような一般多項式モデルの
%           次数を設定します。(多入力データの場合、nb,nf,nk は行ベクトル
%           で、入力チャンネル数と同じベクトル長です。)
%	  
%               A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%     
%          別な表現として、MODEL = PEM(DATA,'na',na,'nb',nb,...) があり
%          省略した次数は、ゼロと考えます。
%
%          状態空間モデルに対して、MODEL = PEM(DATA,'nx',nx) は、nx に次
%          数ベクトルを定義します。ここで、次数の最終選択が要求されます。
%
%          Mi は、IDSS, IDPOLY, IDGREY で推定したモデル、または、作成した
%          モデルです。
%          最小化は、Mi で設定されたパラメータで初期化されます。
%
% MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n) を使
% って、モデル構造やアルゴリズムに関連するすべてのプロパティが与えられま
% す。プロパティの名/値のリストについては、Help IDSS, IDPOLY, EDGREY, 
% IDPROPS ALGORITHMS を参照してください。アルゴリズムに影響するいくつかの
% 重要なプロパティは、つぎのものです。
%       'nk': 入力からの遅れ
%       'InitialState': 初期フィルタ状態の取り扱い方法
%       'Focus': 特定の周波数範囲にフィットしたフォーカス
%       'trace': 推定過程に関する情報のコマンドウィンドウ表示の制御
%
% すべての可能な表記法においてモデル構造 Mi を省略すると、データから推定
% されるモデル次数の状態空間表現になります。したがって、MODEL = PEM(Z) は、
% nk = 1 の妥当なモデル構造を推定します。
%
% 参考: IDPOLY, IDSS, IDGREY, ARMAX, OE, BJ, IDPROPS


%	L. Ljung 10-1-86, 7-25-94


%       Copyright 1986-2001 The MathWorks, Inc.

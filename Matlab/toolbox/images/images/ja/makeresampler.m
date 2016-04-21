% MAKERESAMPLER  リサンプリング構造体の生成
% R = MAKERESAMPLER(INTERPOLANT,PADMETHOD) は、TFORMARRAY と IMTRANSFORM 
% を使って、別々のリサンプリング構造体を生成します。この最も簡単な型で、
% INTERPOLANT は、つぎの文字列 'nearest', 'linear', 'cubic' のいずれかに
% なります。INTERPOLANT は、分離可能なリサンプラが使用する内挿カーネルを
% 指定します。PADMETHOD は、'replicate', 'symmetric', 'circular', 'fill', 
% 'bound' のいずれかを設定できます。PADMETHOD は、リサンプラが、入力配列
% のエッジの近くや外側でマッピングする出力要素に値をどのように内挿したり、
% 割り当てるかをコントロールします。
%
% PADMETHOD オプション
% -----------------
% 'fill', 'replicate', 'circular', 'symmetric' の場合、TFORMARRAY、または
% IMTRANSFORM により実行できるリサンプリングは、2つの論理ステップを経由し
% ます。(1) すべての入力変換スペースを満たすまで、A を無限回付加します。
% そして、(2) 幾何学マップで指定した出力点で、リサンプリングカーネルと付
% 加された A のコンボリューションを計算します。個々の変換に関係ない次元は
% 別々に取り扱われます。付加作業は、パフォーマンスやメモリの効率的な観点
% で使用する仮想的なものです。
%  
% 'circular', 'replicate', 'symmetric' は、PADARRAY での使用と同じ意味を
% もっていて、A の変換次元に適用されます。
%   
%     'replicate' -- 外側要素を繰り返す
%     'circular'  -- A を巡回的に繰り返す
%     'symmetric' -- A を境界を基準に対称に繰り返す
%   
% 'fill' は、入力配列のエッジの近くにマッピングした出力点に関して、入力
% イメージとフル値を組み合わせているので、最近傍内挿を使った部分を除いて
% スムーズに見えるエッジをもつ出力を作成します。
%  
% 'bound' は、'fill'と同様ですが、フル値と入力イメージ値を組み合わせる部
% 分を行いません。マップの外側の点は、フル値配列から値を割り当てます。マ
% ップの内側の転は、'replicate' を使って、取り扱われます。
% 'bound' と 'fill' は、INTERPOLANT が、'nearest'の場合に同じ結果を出力
% します。
% 
% カスタムのリサンプラの場合、これらの挙動を実現することもできます。
% 
% INTERPOLANT 用のアドバンストなオプション
% --------------------------------
% 一般的に、INTERPOLANT は、つぎの型の一つを使います。
%
%       1. つぎの文字列の一つ：'nearest', 'linear', 'cubic'
%
%       2. セル配列：{HALF_WIDTH, POSITIVE_HALF}
%          HALF_WIDTH は、対称な内挿カーネルの半分の幅を指定する正のスカ
%          ラ値です。POSITIVE_HALF は、[0 POSITIVE_HALF] の閉区間で、規
%          則的なサンプリングカーネル値のベクトルです。
%
%       3. セル配列：{HALF_WIDTH, INTERP_FCN}
%          INTERP_FCN は、区間 [0 POSITIVE_HALF] の中の入力値の配列を与
%          え、内挿するカーネル値を出力する関数ハンドルです。
%
%       4. セル配列要素は、上の3タイプの一つです。
%
% 型 2 と 3 は、カスタムの内挿カーネルを使った内挿に使われます。型 4 は、
% 各次元に関して、独立に内挿法を指定するために使います。型 4 に対するセ
% ル配列の中の要素数は、変換次元の数に等しくします。たとえば、INTERPO-
% LANT が、{'nearest', 'linear', {2  KERNEL_TABLE}} の場合、リサンプラ
% は、最初の変換次元に関して、最近傍内挿を使い、2番目の変換次元に関して、
% 線形内挿を、3番目の変換次元に関して、カスタムのテーブルベースの内挿を
% 使います。
%
% カスタムリサンプラ
% -----------------
% 上に記述したシンタックスは、Image Processing Toolbox と共に出荷してい
% る分離可能なリサンプラ関数を使う resampler 構造体を作成します。つぎの
% シンタックスを使って、ユーザ設定のリサンプラを使用する resampler 構造
% 体を作成することもできます。
%
%   R = MAKERESAMPLER(PropertyName,PropertyValue,...)  
%
% PropertyName は、'Type', 'PadMethod', 'Interpolant', 'NDims', 'Resam-
% pleFcn', 'CustomData' のいずれかを設定することができます。
%
% 'Type' は、'separable'、または、'custom' のどちらかを設定することがで
% き、常に、与える必要があります。'Type' が、'separable' の場合、設定で
% きる他のプロパティは、'Interpolant' と 'PadMethod' のみで、結果は、
% MAKERESAMPLER(INTERPOLANT,PADMETHOD) を使ったものと等価です。'Type' 
% が、'custom' の場合、'NDims' と 'ResampleFcn' が必要となるプロパテイ
% で、'CustomData' はオプションです。'NDims' は、正の整数で、カスタムリ
% サンプラが取り扱う次元を示すものです。Inf 値を使って、カスタムのリサン
% プラが任意の次元を取り扱うことができることを示します。'CustomData' の
% 値には、制約がありません。
%
% 'ResampleFcn' は、リサンプリングを行う関数のハンドルです。
% 関数は、つぎのインタフェースと共にコールされます。
%
%       B = RESAMPLE_FCN(A,M,TDIMS_A,TDIMS_B,FSIZE_A,FSIZE_B,F,R)
% 
% 入力 A, TDIMS_A, TDIMS_B, F に関する詳細は、TFORMARRAY に対するヘルプ
% を参照してください。
%
% M は、配列で、B の変換サブスクリプト空間を A の変換サブスクリプト空間
% にマッピングするものです。A が N の変換次数(N = length(TDIMS_A))で、B
% が P の変換次元(P = length(TDIMS_B))をもつ場合、N > 1 に対して、NDI-
% MS(M) = P + 1 となり、N == 1 の場合 P になり、SIZE(M, P + 1) = N とな
% ります。M の最初の P 次元は、出力変換空間に対応し、TDIMS_B にリストさ
% れる出力変換次元の順番に従って、置換されます(一般に、TDIMS_A と TDIMS
% _B は、小さいものから大きいものへ保存する必要はありませんが、指定した
% リサンプラにより、このような制限が課せられる場合も生じます)。それで、
% SIZE(M) の最初の P 要素は、B の変換次元のサイズを決定します。各点がマ
% ッピングされる入力変換座標は、TDIMS_A に与えられる順番に従って、M の
% 最後の次元を跨いで、配置されます。
%
% FSIZE_A と FSIZE_B は、A と B のフルサイズで、TDIMS_A, TDIMS_B, SIZE(A)
% と整合性を保つ必要がある場合1を付加します。
%
% 例題
% -------
% y-方向でキュービック補間を適用し、x-方向で最近傍補間を適用するリサンプ
% ラを使って、y-方向にイメージを引き伸ばします(これは、双キュービック補間
% を使うものと同じですが、高速です)。
%
%       A = imread('moon.tif');
%       resamp = makeresampler({'nearest','cubic'},'fill');
%       stretch = maketform('affine',[1 0; 0 1.3; 0 0]);
%       B = imtransform(A,stretch,resamp);
%
% 参考： IMTRANSFORM, TFORMARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.

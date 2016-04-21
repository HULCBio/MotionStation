% CP2TFORM   コントロールポイントの組から空間的な変換を推測
% CP2TFORM は、コントロールポイントの組を使って、空間的な変換を推測します。%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,TRANSFORMTYPE) は、空間的な
% 変換を含む TFORM 構造体を出力します。INPUT_POINTS は、ユーザが変換し
% たいイメージの中で、コントロール点のX と Y 座標を含む M 行 2 列の do-
% uble 行列です。BASE_POINTS は、ベースイメージのコントロール点のX と 
% Y 座標を含む M 行 2 列の double 行列です。TRANSFORMTYPE は、'linear 
% conformal', 'affine', 'projective',  'polynomial', 'piecewise linear', 
% 'lwm' のいずれかを使えます。TRANSFORMTYPE の選択に関する情報について
% は、CP2TFORM のリファレンスページを参照してください。
%
% TFORM = CP2TFORM(CPSTRUCT,TRANSFORMTYPE) は、入力イメージとベースイメ
% ージに対して、コントロールポイント行列を含む構造体 CPSTRUCT に機能しま
% す。コントロールポイント選択ツール CPSELECT は、CPSTRUCT を作成します。
%
% [TFORM,INPUT_POINTS,BASE_POINTS] = CP2TFORM(CPSTRUCT,...) は、INPUT_
% POINTS の中で実際に使われたコントロールポイントを出力します。一致して
% いない点や予測点は、使いません。CPSTRUCT2PAIRS を参照してください。
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'polynomial',ORDER) は、ORDER
%  を使って、使用する多項式の次数を設定します。ORDER は、2, 3, 4 のいずれ
% かを使用することができます。ORDER を省略すると、デフォルトは、3 を使い
% ます。
%
% TFORM = CP2TFORM(CPSTRUCT,'polynomial',ORDER) は、構造体 CPSTRUCT に機
% 能します。
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'piecewise linear') は、ベー
% スコントロールポイントのDelaunay の三角形を作成し、対応する入力コントロ
% ールポイントをベースコントロールポイントにマッピングします。マッピング
% は、各三角形に対して、線形(アフィン)で、コントロールポイントをクロスし
% て連続ですが、個々の三角形が、それ自身マッピングされたものになるので、
% 微分可能ですが、連続ではありません。
%
% TFORM = CP2TFORM(CPSTRUCT,'piecewise linear') は、構造体 CPSTRUCT に機
% 能します。
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'lwm',N) は、局所的な重み付き
% 平均(lwm)法を使って、マッピングを作成し、各コントロールポイントで、近傍
% のコントロールポイントを使って、多項式を推定します。任意の位置で、任意
% の位置でのマッピングは、これらの多項式の重み付き平均に依存します。個々
% の多項式を推定する点数 N をオプションで設定します。N 個の最近傍点は、
% 個々のコントロールポイントに対して、次数2の多項式を推論するために使いま
% す。N を省略すると、デフォルトの12を使います。N を6というように小さくす
% ることもできます。しかし、N を小さくすると、条件数の悪い多項式を作成す
% る危険があります。
%
% TFORM = CP2TFORM(CPSTRUCT,'lwm',N) は、構造体 CPSTRUCT 上で機能します。
%
% [TFORM,INPUT_POINTS,BASE_POINTS,INPUT_POINTS_BAD,BASE_POINTS_BAD] = ...
%    CP2TFORM(INPUT_POINTS,BASE_POINTS,'piecewise linear') は、INPUT_
% POINTS と BASE_POINTS の中に、実際に使われたコントロールポイントを出力
% します。そして、INPUT＿POINTS＿BAD と BASE_POINTS_BAD に、重なり合った
% 三角形により劣化した中央の頂点が存在するので、削除したコントロールポイ
% ントを出力します。
%
% [TFORM,INPUT_POINTS,BASE_POINTS,INPUT_POINTS_BAD,BASE_POINTS_BAD] = ...
%     CP2TFORM(CPSTRUCT,'piecewise linear') は、構造体 CPSTRUCT 上に機能
% します。
%
% TRANSFORMTYPE
% -------------
% CP2TFORM は、各TRANSFORMTYPEの TFORM を推定するために、コントロールポ
% イントの最小の数を必要とします。 
%
%       TRANSFORMTYPE         MINIMUM NUMBER OF PAIRS
%       -------------         -----------------------
%       'linear conformal'               2 
%       'affine'                         3 
%       'projective'                     4 
%       'polynomial' (ORDER=2)           6
%       'polynomial' (ORDER=3)          10
%       'polynomial' (ORDER=4)          15
%       'piecewise linear'               4
%       'lwm'                            6
%      
% TRANSFORMTYPE が、'linear conformal', 'affine', 'projective', 'polyno-
% mial'で、INPUT_POINTS と BASE_POINTS (または、CPSTRUCT) が、特別な変換
% のために必要なコントロールポイントの最少数をもつ場合、係数は、正確に求
% まります。INPUT_POINTS と BASE_POINTS が、最少数より多い場合、最小二乗
% 解が求まります。関数 MLDIVIDE を参照してください。
%
% 例題
%   -------
%   I = checkerboard;
%   J = imrotate(I,30);
%   base_points = [11 11; 41 71];
%   input_points = [14 44; 70 81];
%   cpselect(J,I,input_points,base_points);
%
%   t = cp2tform(input_points,base_points,'linear conformal');
%
%   % 角度とスケールを回復
%   ss = t.tdata.Tinv(2,1); % ss = scale * sin(angle)
%   sc = t.tdata.Tinv(1,1); % sc = scale * cos(angle)
%   angle = atan2(ss,sc)*180/pi
%   scale = sqrt(ss*ss + sc*sc)
%
% 参考： CPSELECT, CPCORR, CPSTRUCT2PAIRS, IMTRANSFORM.



%   Copyright 1993-2002 The MathWorks, Inc. 

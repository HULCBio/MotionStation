% FINDBOUNDS 空間的な変換に対する出力の範囲を検出
% OUTBOUNDS = FINDBOUNDS(TFORM,INBOUNDS) は、与えられた空間的な変換と入
% 力の範囲に対応する出力の範囲を推定します。TFORM は、MAKEFORM や CP2-
% TFORM で戻される空間的な変換の構造体です。INBOUNDS は、2行 NUM_DIMS 
% 列の行列です。INBOUNDS の最初の行は各次元の下限を、2番目の行列は上
% 限を示します。NUM_DIMS は、TFORM のndims_in フィールドと整合性を保って
% います。
%
% OUTBOUNDS は、INBOUNDS と同じ型をしています。これは、入力の範囲により
% 表現される変換された長方形を完全に含む中で、最も小さい長方形を推定し
% ます。OUTBOUNDS は、一つの推定であるので、変換された入力長方形を完全
% に含んでいない場合があります。
%
% 注意
% -----
% IMTRANSFORM は、ユーザが与えない場合、FINDBOUNDS を使って、'Output-
% Bounds'パラメータを計算します。
%
% TFORM が、フォワード変換を含んでいる場合(forward_fcnフィールドが空でない
% 場合)、FINDBOUNDS は、入力の範囲を表わす長方形の頂点を変換することで、
% 機能し、その結果の最大値と最小値を求めます。
%
% TFORM が、フォワード変換を含まない場合、FINDBOUNDS は、Neider-Mead 最
% 適化関数 FMINSEARCH を使って、出力の範囲を求めています。最適化の方法
% がうまく処理できない場合、FINDBOUNDS は、ワーニングを表わし、OUT-
% BOUNDS = INBOUNDS を戻します。
%
% 例題
% -------
%       inbounds = [0 0; 1 1]
%       tform = maketform('affine',[2 0 0; .5 3 0; 0 0 1])
%       outbounds = findbounds(tform, inbounds)
%
% 参考：CP2TFORM, IMTRANSFORM, MAKETFORM, TFORMARRAY, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.

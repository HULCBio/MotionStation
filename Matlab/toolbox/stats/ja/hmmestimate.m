% HMMESTIMATE   HMM に与えられた状態情報に対するパラメータ推定
%
% [TR, E] = HMMESTIMATE(SEQ,STATES) は、既知の状態 STATES として、系列 
% SEQ に対する HMM の確率である遷移 TR とエミッション E の最尤推定を
% 計算します。
%
% HMMESTIMATE(...,'SYMBOLS',SYMBOLS) は、エミット(emit)されるシンボルを
% 指定することができます。SYMBOLS は、数値配列、またはシンボルの名前の
% セル配列です。N が可能なエミッションの数である場合、デフォルトの
% シンボルは、1から N の間の整数です。
%
% HMMESTIMATE(...,'STATENAMES',STATENAMES) は、状態名を指定することが
% できます。STATENAMES は、数値配列、または状態の名前のセル配列です。
% デフォルトの状態名は、M が状態数の場合、1から M の間になります。
%
% HMMESTIMATE(...,'PSEUDOEMISSIONS',PSEUDOE) は、擬似カウント(pseudocount)
% エミッションの値を指定することができます。これらは、標本系列内に
% 示されない非常に低い確率をもつエミッションに対するゼロの確率推定を
% 避けるために使用されます。PSEUDOE は、MがMHH の状態数で、N が可能な
% エミッションの数である場合、M行N列の大きさの行列です。
%
% HMMESTIMATE(...,'PSEUDOTRANSITIONS',PSEUDOTR) は、擬似カウント
% (pseudocount)遷移の値を指定することができます。これらは、標本系列内に
% 示されない非常に低い確率をもつエミッションに対してゼロの確率推定を
% 避けるために使用されます。PSEUDOTR は、M が HMM 内の状態数の場合、
% M行M列の大きさの行列です。
%
% 状態が既知でない場合、モデルパラメータを推定するために、HMMTRAINを
% 使用してください。
%
% この関数は、常に状態1のモデルから始まり、つぎに遷移行列の最初の行に
% ある確率を使って最初のステップに遷移します。従って、以下で与えられた
% 例題において、状態の出力の最初の要素は、0.95の確率で1に、0.05の確率で
% 2になります。
%
% 例題:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%           
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       [seq, states] = hmmgenerate(1000,tr,e);
%       [estimateTR, estimateE] = hmmestimate(seq,states);
%
%
% 参考 : HMMGENERATE, HMMDECODE, HMMVITERBI, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/28 19:08:20 $

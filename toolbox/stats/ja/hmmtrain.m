% HMMTRAIN   HMM に対するモデルパラメータの最尤推定量
%
% [ESTTR, ESTEMIT] = HMMTRAIN(SEQS,TRGUESS,EMITGUESS) は、Baum-Welch
% アルゴリズムを用いて、系列 SEQS から隠れマルコフモデル(Hidden Markov 
% Model)に対する遷移とエミッションの確率を推定します。TRGUESS と EMITGUESS 
% は、遷移とエミッションの確率行列の初期推定値です。TRGUESS(I,J) は、
% 状態 I から状態 J に遷移する推定確率です。EMITGUESS(K,SYM) は、シンボル 
% SYM が状態 K からエミット(emit)される推定確率です。
%
% HMMTRAIN(...,'ALGORITHM',ALGORITHM) は、訓練アルゴリズムを選択する
% ことができます。ALGORITHM は、'BaumWelch' または 'Viterbi' のいずれか
% です。デフォルトのアルゴリズムは、BaumWelch です。
%
% HMMTRAIN(...,'SYMBOLS',SYMBOLS) は、エミット(emit)されるシンボルを指定
% することができます。SYMBOLS は、数値配列か、シンボルの名前のセル配列です。
% N が可能なエミッションの数である場合、デフォルトのシンボルは、1から N の
% 間の整数です。
%
% HMMTRAIN(...,'TOLERANCE',TOL) は、反復推定過程の収束のテストに対して
% 使用される許容誤差を指定することができます。デフォルトの許容誤差は、
% 1e-4です。
%
% HMMTRAIN(...,'MAXITERATIONS',MAXITER) は、推定過程に対する繰り返しの
% 最大回数を指定することができます。デフォルトの繰り返し数は、100です。
%
% HMMTRAIN(...,'VERBOSE',true) は、各繰り返しでのアルゴリズムの状態を
% 表示します。
%
% HMMTRAIN(...,'PSEUDOEMISSIONS',PSEUDOE) は、Viterbi訓練アルゴリズムに
% 対して、擬似カウント(pseudocount)エミッションの値を指定することができます。
%
% HMMTRAIN(...,'PSEUDOTRANSITIONS',PSEUDOTR) は、Viterbi訓練アルゴリズム
% に対して、擬似カウント(pseudocount)遷移の値を指定することができます。
%
% 系列に対応する状態が既知の場合、モデルパラメータの推定に HMMESTIMATE を
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
%       seq1 = hmmgenerate(100,tr,e);
%       seq2 = hmmgenerate(200,tr,e);
%       seqs = {seq1,seq2};
%       [estTR, estE] = hmmtrain(seqs,tr,e);
%
% 参考 : HMMGENERATE, HMMDECODE, HMMESTIMATE, HMMVITERBI. 


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/28 19:08:22 $

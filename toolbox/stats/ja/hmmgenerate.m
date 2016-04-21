% HMMGENERATE   隠れマルコフモデル(Hidden Markov Model)に対する系列の生成
%
% [SEQ, STATES] = HMMGENERATE(LEN,TRANSITIONS,EMISSIONS) は、遷移確率行列 
% TRANSITIONS とエミッション確率行列 EMISSIONS によって指定されたマルコフ
% モデルから長さ LEN の状態情報と系列を生成します。TRANSITIONS(I,J) は、
% 状態 I から 状態 J に遷移する確率です。EMISSIONS(K,L) は、シンボル L が
% 状態 K からエミット(emit)される確率です。
%
% HMMGENERATE(...,'SYMBOLS',SYMBOLS) は、エミット(emit)されるシンボルを
% 指定することができます。SYMBOLS は、数値配列、またはシンボルの名前の
% セル配列です。N が可能なエミッション値の場合、デフォルトのシンボルは、
% 1から N の間の整数です。
%
% HMMGENERATE(...,'STATENAMES',STATENAMES) は、状態名を指定することが
% できます。STATENAMES は、数値配列、または状態の名前のセル配列です。
%  デフォルトの状態名は、M が状態数の場合、1から M の間になります。
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
%       [seq, states] = hmmgenerate(100,tr,e)
%
%       [seq, states] = hmmgenerate(100,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'},...
%                  'Statenames',{'fair';'loaded'})
%
% 参考 : HMMVITERBI, HMMDECODE, HMMESTIMATE, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/28 19:08:18 $

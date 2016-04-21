% HMMDECODE   系列の後方の状態確率を計算
%
% PSTATES = HMMDECODE(SEQ,TRANSITIONS,EMISSIONS) は、遷移確率行列 
% TRANSITIONS と エミッション確率行列 EMISSIONS によって指定された隠れ
% マルコフモデル(Hidden Markov Model)から系列 SEQ の後方の状態確率 
% PSTATES を計算します。TRANSITIONS(I,J) は、状態 I から状態 J に遷移
% する確率です。EMISSIONS(K,SYM) は、シンボル SYM が状態 K からエミット
% (emit)される確率です。系列 SEQ の後方の確率は、確率 P(i = k | SEQ 
% ステップの状態)です。PSTATES は、モデル内の各状態に対して、SEQ および 
% 1つの行と同じ長さの配列です。PSTATES の (i,j) の要素は、モデルが SEQ の
% j番目のステップで、状態 i 内にある確率を与えます。
%
% [PSTATES, LOGPSEQ] = HMMDECODE(SEQ,TR,E) は、遷移行列 TR と エミッション
% 行列 E を与えて、系列 SEQ の確率の対数である LOGPSEQ を出力します。
%
% [PSTATES, LOGPSEQ, FORWARD, BACKWARD, S] = HMMDECODE(SEQ,TR,E) は、S に
% よってスケールされた系列の前向きおよび後ろ向き確率を出力します。
% 実際の前向き確率は、以下の書式を使うことで戻すことができます。:
%        f = FORWARD.*repmat(cumprod(s),size(FORWARD,1),1);
% 実際の後ろ向き確率は、以下の書式を使うことで戻すことができます。:
%       bscale = fliplr(cumprod(fliplr(S)));
%       b = BACKWARD.*repmat([bscale(2:end), 1],size(BACKWARD,1),1);
%
% HMMDECODE(...,'SYMBOLS',SYMBOLS) は、エミット(emit)されるシンボルを
% 指定することができます。SYMBOLS は、数値配列、またはシンボルの名前の
% セル配列です。N が可能なエミッションの数である場合、デフォルトの
% シンボルは、1から N の間の整数です。
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
%       [seq, states] = hmmgenerate(100,tr,e);
%       pStates = hmmdecode(seq,tr,e);
%
%       [seq, states] = hmmgenerate(100,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'});
%       pStates = hmmdecode(seq,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'});
%
% 参考 : HMMGENERATE, HMMESTIMATE, HMMVITERBI, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/01/28 19:08:21 $

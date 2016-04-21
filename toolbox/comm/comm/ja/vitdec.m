% VITDEC   Viterbiアルゴリズムを使って、畳み込み符号化データを復号
%
% DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,DECTYPE) は、Viterbi アルゴ
% リズムを使って、ベクトル CODE を復号します。CODE は、MATLAB 構造体 
% TRELLIS で設定された畳み込み符号器の出力と仮定しています。有効な
% TRELLIS 構造体に関しては、POLY2TRELLIS を参照してください。CODE の中の
% 各シンボルは、log2(TRELLIS.numOutputSymbols)ビットから構成され、CODE は、
% 一つまたは複数のシンボルを含んでいます。DECODE は、CODE と同じ方向の
% ベクトルで、そのシンボルの各々は、log2(TRELLIS.numInputSymbols)ビット
% で構成されています。TBLEN は、トレースバックの深さを設定する正の整数
% スカラです。
%    
% OPMODE は、復号器の演算モードを定義します。
% 'trunc' : 符号器は、ゼロ状態からスタートしていると仮定しています。
%           復号器は、最良計量を使って、状態からトレースバックします。
% 'term'  : 符号器は、最初も最後もすべてゼロ状態であると仮定しています。
%           復号器は、オールゼロ状態からトレースバックします。
% 'cont'  : 符号器は、オールゼロ状態からスタートしていると仮定しています。
%           復号器は、最良計量を使って、状態からトレースバックします。
%           TBLEN シンボルに等しい遅れが取り込まれます。
%    
% DECTYPE は、CODE に表現されるビット数を定義します。
% 'unquant' : 復号器は、符号付き実入力値を対象としています。
%             +1 は、論理ゼロ、-1 は論理1を表します。
% 'hard'    : 復号器は、2値入力値を対象としています。
% 'soft'    : つぎのシンタックスを参照してください。
%
% DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,'soft',NSDEC) は、0と 
% 2^NSDEC-1 の間の整数から構成される入力ベクトル CODE を復号します。
% ここで、0 は最も信頼ある 0、2^NSDEC-1は最も信頼ある 1を表しています。
% NSDEC は、決定タイプが'soft' の場合のみ、必要な引数であることに注意
% してください。
%    
% DECODED = VITDEC(..., 'cont', ..., INIT_METRIC,INIT_STATES,INIT_INPUTS)
% は、初期状態計量、初期トレースバック状態、初期トレースバック入力をもつ
% 復号器を与えます。INIT_METRIC の中の各実数は、対応する状態の初期状態
% 計量を表しています。INIT_STATES と INIT_INPUTS は、復号器の初期トレース
% バックメモリをお互いに設定します。これらは、共に TRELLIS.numStates 行 
% TBLEN 列の行列になります。INIT_STATES は、0から TRELLIS.numStates-1 
% までの整数で、INIT_INPUTS は、0から TRELLIS.numInputSymbols-1 までの
% 整数で構成されています。最後 3 つの引数全てについてデフォルト値を使う
% には、[],[],[] のように設定してください。
%    
% [DECODED FINAL_METRIC FINAL_STATES FINAL_INPUTS] = VITDEC(..., 'cont',  ...) 
% は、復号処理の最後で、状態計量、トレースバック状態、トレースバック入力
% を出力します。FINAL_METRIC は、最終状態計量に対応する TRELLIS.numStates 
% 要素をもつベクトルです。FINAL_STATES と FINAL_INPUTS は、
% TRELLIS.numStates 行 TBLEN 列の行列です。
%    
% 例題：
%  t = poly2trellis([3 3],[4 5 7;7 4 2]);  k = log2(t.numInputSymbols);
%  msg = [1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 1];
%  code = convenc(msg,t);    tblen = 3;
%  [d1 m1 p1 in1]=vitdec(code(1:end/2),t,tblen,'cont','hard');
%  [d2 m2 p2 in2]=vitdec(code(end/2+1:end),t,tblen,'cont','hard',....
%      m1,p1,in1);
%  [d m p in] = vitdec(code,t,tblen,'cont','hard');
%    
% 同じ復号されたメッセージが、d と[d1 d2] に出力されます。ペア、m,m2 と
% p,p2、in,in2 もまた同じです。d は、msg の遅れをもつバージョンで、その
% ために、msg(1:end-tblen*k) と d(tblen*k+1:end) は同じになります。
%    
% 参考： CONVENC, POLY2TRELLIS, ISTRELLIS.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:22 $
% Author : Katherine Kwong
% Calls vit.c

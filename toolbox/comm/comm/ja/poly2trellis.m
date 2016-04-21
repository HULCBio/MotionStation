% POLY2TRELLIS   多項式記述をトレリス表現に変換
%
% TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR) は、フィード
% フォーワード畳み込み符号器の多項式表現をトレリス表現に変換します。
% レート k/n 符号に対して、符号器入力は長さ k のベクトルで、符号器出力は
% 長さ n のベクトルです。そのため、つぎのようになります。
% 
%  - CONSTRAINTLENGTH は、各 k 個の入力ビットストリームに対して、遅れ
%    を設定する1 行 k 列のベクトルです。
%
%  - CODEGENERATOR は、毎 k 個の入力に対して、n 個の出力結合を設定する
%    8進数の k 行 n 列の行列です。
%
% TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR,FEEDBACKCONNECTION)
% は、最初のシンタックスと同じですが、フィードバック畳み込み符号器に対する
% ものです。
%
%  - FEEDBACKCONNECTION は、毎 k 個の入力に対して、フィードバック結合を
%    指定する8進数の1行 k 列のベクトルです。
%
% トレリスは、つぎのフィールドをもつ構造体として表現されます。
%      numInputSymbols,  (入力シンボルの数)
%      numOutputSymbols, (出力シンボルの数)
%      numStates,        (状態数)
%      nextStates,       (つぎの状態行列)
%      outputs,          (出力行列)
%
% トレリス構造体に関するより詳しい情報は、MATLABプロンプトで 'help istrellis'
% とタイプしてください。


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:02 $

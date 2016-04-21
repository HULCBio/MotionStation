% CONVENC  バイナリデータを畳み込み符号化
%
% CODE = CONVENC(MSG,TRELLIS) は、MATLAB 構造体 TRELLIS で定義される畳み
% 込み符号器を使って、バイナリベクトル MSG を符号化します。TRELLIS 構造
% 体に関しては、POLY2TRELLIS と ISTRELLIS を参照してください。符号器の
% 状態はオールゼロから始まります。MSG の各シンボルは、
% log2(TRELLIS.numInputSymbols)ビットから構成されています。MSG は、
% 単数、または、複数のシンボルを含んでいます。CODE は、MSG と同じ方向の
% ベクトル(列ベクトル、または、行ベクトル)で、そのシンボルの各々は、
% log2(TRELLIS.numInputSymbols) ビットから構成されています。
%
% CODE = CONVENC(MSG,TRELLIS,INIT_STATE) は、符号器のレジスタが、INIT_STATE 
% で設定される状態で始まること以外は、上のシンタックスと同じです。
% INIT_STATE は、0とTRELLIS.numStates - 1の間の整数です。INIT_STATE に
% デフォルト値を使うには、0または[]と指定してください。
%
% [CODE FINAL_STATE] = CONVENC(...) は、入力メッセージを処理した後、
% 符号器の最終状態 FINAL_STATE を出力します。
%
% 例題：
%      t = poly2trellis([3 3],[4 5 7;7 4 2]);
%      msg = [1 1 0 1 0 0 1 1];
%      [code1 state1]=convenc([msg(1:end/2)],t);
%      [code2 state2]=convenc([msg(end/2+1:end)],t,state1);
%      [codeA stateA]=convenc(msg,t);
%    
% 同じ結果が、[code1 code2] と codeA に出力されます。最終状態 state2 と 
% stateA もまた等しいものです。
%
% 参考： VITDEC, POLY2TRELLIS, ISTRELLIS.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:17 $
% Calls convcore.c

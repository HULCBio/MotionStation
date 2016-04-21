%
% LMI-Labコマンド:
%
% LMIの設定
%    lmiedit   - GUIベースでの連立LMIの設定
%    setlmis   - LMIの記述の初期化
%    lmivar    - 新規の行列変数の指定
%    lmiterm   - LMIの項のリストに新規の項を追加
%    newlmi    - 新規の連立LMIに名前、または、タグを付加
%    getlmis   - 連立LMIの内部記述の取得
%
% 情報の取得
%    lmiinfo   - 既存の連立LMIに関する情報を出力
%    lminbr    - 問題内に含まれるLMIの数を出力
%    matnbr    - 問題内に含まれる行列変数の数を出力
%    decnbr    - 決定変数の数を出力
%    dec2mat   - 決定変数が与えられたとき行列変数の値を出力
%    mat2dec   - 行列変数が与えられたとき決定変数の値を出力
%    decinfo   - 行列変数の決定変数との関連
%
% LMIソルバ
%    feasp     - 与えられた連立LMIの解の計算
%    mincx     - LMI制約下で線形目的関数の最小化
%    gevp      - 一般化固有値の最小化
%    dec2mat   - ソルバ出力を行列変数の値に変換
%    defcx     - MINCXでのC'x目的関数の設定
%
% 結果の検証
%    evallmi   - 与えられた変数の値に対する連立LMIの評価
%    showlmi   - 計算された連立LMIのlhsとrhsを出力
%
% 連立LMIの変更
%    dellmi    - 連立LMIから特定のLMIを削除
%    delmvar   - 問題から行列変数を削除
%    setmvar   - 行列変数に値を設定
%
% 特殊な問題
%    basiclmi  - M+P'*X*Q+Q'*X'*P < 0の解
%
% デモ
%    lmidem    - LMI Lab 環境のデモ

% Copyright 1995-2004 The MathWorks, Inc.

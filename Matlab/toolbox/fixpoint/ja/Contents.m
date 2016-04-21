% Fixed-Point Blockset
% Version 4.1 (R13SP1) 09-Apr-2003
%
% ライブラリと例題
%   fixpt  - Fixed-Pointブロックライブラリ
%   fixptdemo - デモ
%
% データタイプの定義
%   sfix  - 符号付き固定小数点
%   ufix  - 符号なし固定小数点
%   sint  - 符号付き整数
%   uint  - 符号なし整数
%   sfrac - 符号付き仮数
%   ufrac - 符号なし仮数
%   float - 浮動小数点数で、倍精度、単精度、ユーザ設定
% 
% 設計ツール
%   autofixexp         - 最新のシミュレーションをベースに基数の指数の自
%                        動設定
%   showfixptsimranges - 最新のシミュレーションから最小値と最大値の表示
%   showfixptsimerrors - show errors such as overflows from last simulation
%   fxptdlg            - オートスケーリングや最小値/最大値をロギングするGUI
%   fixpt_convert      - 浮動小数点モデルを固定小数点モデルに変換
%   fixptbestprec      - 固定小数点数に対する最適精度の検出
%   fixptbestexp       - 固定小数点数に対する最適指標の検出
%   num2fixpt          - 固定小数点表現を使って、値の量子化
%   fixpt_interp1      - 固定小数点演算でルックアップテーブルを計算
%   fixpt_look1_func_approx - 関数近似のためルックアップテーブルデータ
%                             を検索
%   fixpt_look1_func_plot   - 関数とルックアップテーブル近似の比較
%   fixpt_set_all      - サブシステムのFixed Pointブロック毎のプロパ
%                        ティを設定
%
% Report Generator Components
%   cfp_blk_loop       - 固定小数点ループ
%   cfp_blk_proptable  - 固定小数点ロギングオプション
%   cfp_options        - 固定小数点プロパティの一覧
%   cfp_summ_table     - 固定小数点のSummaryの一覧


% Copyright 1994-2002 The MathWorks, Inc. 
% $Date: 2003/04/21 15:17:23 $

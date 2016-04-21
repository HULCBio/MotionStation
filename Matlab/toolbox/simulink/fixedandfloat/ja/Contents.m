% Simulink Fixed Pointユーティリティ.
%
%
% 以下は、Simulink Fix Pointブロックで用いられるユーティリティです。
%
% 固定小数点データ作成ユーティリティ:
%
% fixdt  - 固定小数点または浮動小数点データタイプを記述するオブジェクトの作
%          成
% sfix   - 符号付き固定小数点データタイプを記述する構造体の作成
% sfrac  - 符号付きFRACtionalデータタイプを記述する構造体の作成
% sint   - 符号付き整数データタイプを記述する構造体の作成
% ufix   - 符号なし固定小数点データタイプを記述する構造体の作成
% ufrac  - 符号なしFRACtionalデータタイプを記述する構造体の作成
% uint   - 符号ない整数データタイプを記述する構造体の作成
% float  - 浮動小数点データタイプを記述する構造体の作成
%
% 固定小数点データの操作および表示のためのユーティリティ:
%
% fixptbestexp  - 最高精度を与える指数の決定
% fixptbestprec - 値の固定小数点表現で利用可能な最大精度の決定
% fxptdlg       - Fixed-Point Blocksetシミュレーションログのグラフィカルイン
%                 タフェース
% fxptplt       - Fixed-Pointシステムのブロックのプロットのためのグラフィカ
%                 ルインタフェース
% num2fixpt     - fixed point blockset 表現を使った値の量子化
% fixpt_interp1           - 固定小数点1-D内挿(テーブルルックアップ)
% fixpt_look1_func_approx - 関数へのルックアップテーブル近似のための点を求め
%                           る
% fixpt_look1_func_plot   - 理想的な関数とそのルックアップ近似のプロット
%
% 利用情報については、これらのコマンドでHELPを実行してください。
% たとえば、
%
% help sfix
%
% のようにMATLABプロンプトでタイプすると、関数SFIXに関連する利用情報を表示し
% ます。
%


% Copyright 1990-2004 The MathWorks, Inc.

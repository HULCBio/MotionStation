%PROFILE プロファイル関数実行時間
% PROFILE ON は、プロファイルを開始し、それ以前に記録されたプロファイル
% の統計をクリアします。
%
% PROFILE ON に、-HISTORY オプションを続けることができます。
%
% -HISTORY
% このオプションが指定された場合、関数呼び出し履歴レポートが生成され
% るような関数呼び出しの正確なシーケンスを記録します。注意：MATLABは、
% 10000個よりも多くの関数や終了イベントを記録しません。しかしMATLABは、
% このような制限を越えても、他のプロファイルの統計量は記録し続けます。
%
% PROFILE OFF  は、プロファイルの実行を中止します。
%
% PROFILE VIEWER は、プロファイラを中止し、グラフィカルなプロファイル
% ブラウザを開きます。PROFILE VIEWER に対する出力は、プロファイラウィ
% ンドウ内のHTMLファイルです。関数のプロファイルページの下にリストされ
% たファイルは、コードの各行の左側から4つの列として示されます。
%       列 1 (赤) は、ラインに費やされた時間の合計(s)です。
%       列 2 (青) は、ラインをコールする数です。
%       列 3 は、ライン番号です
%
% PROFILE RESUME は、それ以前に記録された関数の統計量をクリアしないで、
% プロファイルを再スタートします。
%
% PROFILE CLEAR は、すべての記録されたプロファイル統計量をクリアします。
%
% S = PROFILE('STATUS') は、カレントのプロファイラ状態に関する情報
% を含む構造体を出力します。S は、つぎのフィールドを含みます。
%
%       ProfilerStatus   -- 'on' または 'off'
%       DetailLevel      -- 'mmex', または 'builtin'
%       HistoryTracking  -- 'on' または 'off'
%
% STATS = PROFILE('INFO') は、プロファイラを停止し、カレントのプロファイラ
% 統計量を含む構造体を出力します。
% STATS は、つぎのフィールドを含みます。
%
%       FunctionTable    -- 呼びだされた関数についての統計を含む構造体配列
%       FunctionHistory  -- 関数呼び出し履歴テーブル
%       ClockPrecision   -- プロファイラ時間測定の精度
%       ClockSpeed       -- cpuの推定クロック速度(あるいは0)
%       Name             -- プロファイラの名前(たとえば、MATLAB)
%
% FunctionTable 配列は、STATS 構造体の最も重要な部分です。そのフィールドは、
% つぎのものです。
%
%       FunctionName     -- サブ関数リファレンスを含む、関数名
%       FileName         -- ファイル名は、完全に条件の合ったパスです
%       Type             -- M-ファンクション、MEX-ファンクション
%       NumCalls         -- この関数が呼び出される時間数
%       TotalTime        -- この関数に費やされる時間の合計
%       Children         -- FunctionTable は、child 関数にインデックスを付けます
%       Parents          -- FunctionTable は、parent 関数にインデックスを付けます
%       ExecutedLines    -- ライン毎の詳細を取り扱う配列 (下記参照)
%       IsRecursive      -- 関数が再帰的であるかどうか判定するブーリアン値
%
% ExecutedLines 配列には、いくつかの列があります。列 1 は、実行される
% ライン数です。ラインが実行されなかった場合には、この行列に現れません。
% 列 2 は、実行された時間数です。列 3 は、そのラインに費やされた時間の
% 合計です。注意: 列 3 の和は、必ずしも関数の TotalTime まで加えられません。
%
% 例題:
%
%       profile on
%       plot(magic(35))
%       profile viewer
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
% 参考 PROFVIEW.

%   Copyright 1984-2003 The MathWorks, Inc. 

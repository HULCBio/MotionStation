% decisioninfo     - モデルオブジェクトに対するcondition coverage情報
%
%
% COVERAGE = CONDITIONINFO(DATA, BLOCK) は、cvdata coverageオブジェクト
% DATA 内の BLOCK に対する条件coverageを検出します。COVERAGE は、
% [covered_cases total_cases]となる2つの要素ベクトルが出力されます。BLOCK
% についての情報の一部がない場合、COVERAGE は空になります。
%
% モデルオブジェクトを指定するBLOCKパラメータは、以下の形式を取ります:
%
% BlockPath           - Simulinkブロックまたはモデルの絶対パス　BlockHandl
%  e         - Simulinkブロックまたはモデルのハンドル SimulinkObj
%                       - SimulinkオブジェクトAPIハンドル
% StateflowID         - Stateflow ID (個々に例示されたチャートID) Stateflow
%                       Obj        - StateflowオブジェクトAPIハンドル
% (個々に例示されたチャートID) {BlockPath, sfID}    - Cell array with the p
%                                         ath to
%                                         a Stat
%                                         eflowブロックのパスとチャートのインスタンスに含まれるオブジェクトのIDを含むセル配列
% {BlockPath, sfObj}   - Stateflowブロックのパスとそのチャートに含まれるSt
%                        ateflowオブジェクトAPIハンドル
% [BlockHandle sfID]   - Stateflowブロックのハンドルとそのチャートインスタン
%                        スに含まれるオブジェクトのIDからなる配列
%
% COVERAGE = CONDITIONINFO(DATA, BLOCK, IGNORE_DECENDENTS) は、BLOCK に対す
% る条件coverageを検出し、IGNORE_DECENDENTS が真の場合、decendentオブジェクト
% 内のcoverageを無視します。
%
% [COVERAGE,DESCRIPTION] = CONDITIONINFO(DATA, BLOCK) は、coverageを検出し、
% 各条件と真の数と偽の数のテキストの記述を含む構造体配列DESCRIPTION を生成
%


% Copyright 1990-2002 The MathWorks, Inc.

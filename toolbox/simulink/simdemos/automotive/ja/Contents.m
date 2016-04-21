% Simulink: 自動車モデルのデモンストレーションと例題。
%
% デモンストレーションモデル(.mdl)
%   absbrake     - ABSブレーキシステム
%   clutch       - クラッチのエンゲージモデル
%   engine       - 自動車のエンジンモデル
%   enginewc     - 速度制御を伴う自動車エンジンモデル
%   suspn        - 自動車のサスペンションモデル
%
% デモンストレーションスクリプト(.m)
%   runabs   - ABS ブレーキのフロントエンドスクリプト
%   suspgrph - サスペンションのフロントエンド
%
% MATLABコマンド"demo simulink"を実行することにより、このディレクトリの
% ほとんどのデモとモデルのメニューが表示されます。デモメニューは、メイン
% のSimulinkブロックライブラリ(MATLABコマンドラインで"simulink"とタイプ
% する、または、Simulinkのツールバーアイコンを押すことにより表示されます)
% のDemosブロックを開くことによっても利用可能です。 
%
% デモは、MATLABコマンドラインで、デモの名前をタイプすることによっても
% 実行できます。
%
% サポートルーチンとデータファイル
%   absdata.m    - absbrakeのデータ
%   clutchplot.m - clutchのプロットルーチン
%   suspdat.m    - suspnのデータ
%   clutch.mat   - clutchのデータ


% Copyright 1990-2002 The MathWorks, Inc.

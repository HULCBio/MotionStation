% CVSIM   Coverage instrumented シミュレーションの実行
%
%
% DATA = CVSIM( TEST ) は、対応するモデルに対して、シミュレーションの実行をス
% タートさせることにより、cvtest オブジェクト TEST を実行します。結果は、
% cvdata オブジェクトに出力されます。
%
% [DATA,T,X,Y] = CVSIM( TEST ) は、シミュレーション時間ベクトル T、状態値 X、
% 出力値 Y を保存します。
%
% [DATA,T,X,Y] = CVSIM( TEST, TIMESPAN, OPTIONS) は、デフォルトのシミュレー
% ション値を書き換えます。詳細は、SIM を参照してください。
%
% [DATA1, DATA2, ...] = CVSIM( TEST1, TEST2, ... は、テストを実行し、結果を
% cvdata オブジェクトに戻します。
%
% [DATA1,T,X,Y] = CVSIM( ROOT, LABEL, SETUPCMD) は、cvtest オブジェクトを作
% 成、実行します。ROOT, LABEL, SETPCMD の記述を参照してください。
%
% 参考 : CVENABLE, CVTEST, SIM


% Copyright 1990-2002 The MathWorks, Inc.

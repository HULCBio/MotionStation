% SLSAVEAS   Simulink 5.0 (R13)のモデルをSimulink 4.1 (R12.1)のモデルに
%            変換
%
% SLSAVEAS('SYS') は、Simulink 5 (R13)モデルをSimulink 4.1 (R12.1)で
% 読み込めるように変換しっます。カレントディレクトリに 'SYS_r12' として
% コールされるモデルを作成します。
%
% SLSAVEAS は、R12のモデルのファイル名を2番目の引数に与えます。
%
% SLSAVEAS('SYS', 'SYS2')
%
% SLSAVEAS('SYS', 'SYS2','SaveAsR12PointOne')
%   Simulink R12 4.1 (R12.1)フォーマットにモデルを変換します。
%
% SLSAVEAS('SYS', 'SYS2','SaveAsR12')
%   Simulink R12 4.0 (R12)フォーマットにモデルを変換します。
%
% 上記コマンドは、R13(のみ)のSimulinkブロックを黄色のマスクされた空の
% サブシステム内に変換します。
% Simulink R13でしか含まれないブロックとして、以下のものがあります。
%     Assertion ブロック
%     Rate Transition ブロック
%   
% SLSAVEAS('SYS', 'SYS2','SaveAsR11')
%   Simulink R11 3.0 (R11)フォーマットにモデルを変換します。
%   このコマンドは、R13(のみ)のSimulinkブロックを黄色のマスクされた
%   空のサブシステム内に変換します。
%   Simulink R13でしか含まれないブロックとして、以下のものがあります。
%        Assertion ブロック
%        Rate Transition ブロック
%        Look-Up Table (n-D)
%        PreLook-Up Index Search
%        Interpolation (n-D)
%        Direct Look-Up
%        Table (n-D)
%        Polynomial
%        Matrix Concatenation
%        Signal Specification
%        Bitwise Logical Operator
%        ForIterator
%        WhileIterator
%        If
%        SwitchCase
%
% R13でしか存在しないSimulinkブロックセットは、リンク切れのブロックと
% して現れます。
%
% 注意: このコマンドは、R13のみの機能、および/または、ブロックが含まれて
%       いるモデルも変換しますが、変換されたモデルは、間違った結果になる
%       可能性があります。


%   Copyright 1990-2002 The MathWorks, Inc.

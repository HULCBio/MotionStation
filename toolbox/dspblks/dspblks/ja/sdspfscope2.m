% SDSPFSCOPE2   DSP Blocksetに対するフレームとベクトル表示ブロック
%
% DSP Blockset は、Simulinkモデル内のフレームベース、またはベクトルベース
% の信号を視覚化するための、実用的な様々なスコープを提供します。
% Communications Blockset は、Communication Scopeに対してデータを描画
% するために、このS-functionを使用します。
%
% "DSP Sinks" ライブラリ内の以下のブロックは、このスコープ表示を利用
% します。:
%    - Vector Scope
%    - FFT Frame Scope
%    - Buffered FFT Frame Scope
%
% "Communication Sinks" ライブラリ内の以下のブロックは、このスコープ表示
% を利用します。:
%    - Discrete-Time Eye Diagram Scope
%    - Discrete-Time Scatter Plot Scope
%    - Discrete-Time Signal Trajectory Scope
%
% M行N列の入力行列は、データの連続する時間サンプルが、それぞれ M として
% 与えられるデータの N チャンネルとして解釈される場合、これらのブロックは、
% 2次元の信号を受け入れます。1次元の信号は、データの1つのチャンネルとして
% 解釈されます。
%
% ほとんどのメニューオプションは、スコープ表示内で右クリックによって
% 利用できるコンテキストメニューを再現したものです。スコープブロックと
% ブロックに入力されるデータチャンネルの数によって、異なったオプションが
% 与えられます。
%
% 参考 : DSPLIB, COMMLIB.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.4.6.1 $  $Date: 2003/07/22 21:03:56 $

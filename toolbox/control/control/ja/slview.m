% SLVIEW   Simulink LTI Viewer の初期化と管理
%
% SLVIEW は、Simulink のダイアグラム Tool メニューの階層下のLinear Analysis
% メニューに対するコールバックです。Linear Analysis メニューを選択すると、
% Simulink ダイアグラムに関係している LTI Viewer がオープンするか、または、
% LTI Viewer が既に存在している場合は、ダイアグラムの新しい線形モデルを
% 取得できます。
%
% Simulink LTI Viewer が初期化される場合、Model Inputs と Outputs を含む
% Simulink ダイアグラムもオープンします。これらのドラッグ/ドロップの処理
% を適用するブロックは、線形化モデルの入力と出力信号を明記するために使用
% されます。Input Points と Output Points は、Simulink ダイアグラムの任意の
% 階層に設定できます。
%
% 一度、オープンすると、LTI Viewer 関数は、Simulinkのダイアグラムとは
% 無関係です。しかし、ダイアグラムの内部に変更を加えると、Linear Analysis 
% メニューで再度選択することにより、LTI Viewer の中で反映できます。
%
% 参考：   LTIVIEW.


%   Authors: Karen Gondoly, 12-2-96
%   Revised: Adam DiVergilio
%            Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:54 $

% これは、f14デモに対するマスタースクリプトです。
% 最初のアクションはユーザのもっているプロダクトを定義するために必要です。
% オプションは以下のとおりです。
%
%    1. control toolbox と stateflow の両方が検出され、すべてのGUIが
%       使われます。
%   
%    2. ユーザは stateflow はもっているが、control をもっていない:
%       -- この場合、モデルは制御設計を行いません。
%    
%    3. ユーザは control はもっているが、stateflow をもっていない:
%       -- この場合 stateflow を使わない F14 のモデルを使用します。
%
%    4 ユーザはSimulinkしかもっていない(control toolbox または stateflow
%      をもっていない)
%       -- この場合、F14 モデルのみ表示し、GUIは表示されません。


%   Copyright 2002 The MathWorks, Inc.

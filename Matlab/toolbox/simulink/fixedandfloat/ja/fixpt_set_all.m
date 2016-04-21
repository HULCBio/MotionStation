% FIXPT_SET_ALL   サブシステム内の固定小数点ブロック毎にプロパティを設定
%
% 使用法：
%   FIXPT_SET_ALL( SystemName, fixptPropertyName, fixptPropertyValue )
%
% 例題
%   FIXPT_SET_ALL( 'myModel/mySubsystem', 'RndMeth', 'Floor' )
%   FIXPT_SET_ALL( 'myModel/mySubsystem', 'DoSatur', 'on' )
% 
% は、丸めとオーバフロー処理を行うサブシステム内に、すべての固定小数点
% ブロックを設定します。


% Copyright 1994-2002 The MathWorks, Inc.

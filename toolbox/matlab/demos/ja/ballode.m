% BALLODE   バウンドするボールのデモを実行
% 
% BALLODE は、繰り返されるイベントの位置を求めます。ここで、初期条件は、
% 各最終イベント終了後、変化します。このデモは、ODE23を使って、10回のバ
% ウンドを計算します。ボールのスピードは、各バウンドで、0.9倍に変速しま
% す。ボールの軌道は、出力関数 ODEPLOT を使って、プロットされます。
%
% 参考：ODE23, ODE45, ODESET, ODEPLOT, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 1/3/95
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:48:03 $

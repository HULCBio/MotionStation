% WINMENU   "Window"メニューアイテムに対してサブメニューを作成
% 
% WINMENU(H) は、H で指定されるメニューの下にサブメニューを作ります。
% WINMENU(F)は、タグ 'winmenu' をもつfigure F のuimenuの子を探索して、
% 初期化します。
% 
% cb = WINMENU('callback') は、サブメニューをもつメニューアイテムに対して、
% 適切なコールバック文字列を出力します（下位互換性のため)。コールバックは
% 常に 'winmenu(gcbo)'です。
%
% 例題：
%
%  fig_handle = figure;
%  uimenu(fig_handle, 'Label', 'Window', ...
%      'Callback', winmenu('callback'), 'Tag', 'winmenu');
%  winmenu(fig_handle);  % Initialize the submenu

    
%  Steven L. Eddins, 6 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 

% PBASPECT   プロットボックスの縦横比
% 
% PBAR = PBASPECT              カレントのaxesのプロットボックスの縦横比
%                              を取得します。
% PBASPECT([X Y Z])            プロットボックスの縦横比を設定します。
% PBARMODE = PBASPECT('mode')  プロットボックスの縦横比のモードを取得
%                              します。
% PBASPECT(mode)               プロットボックスの縦横比モードを設定します
%                              (mode は、'auto'、'normal' のいずれかです)
% PBASPECT(AX,...)             カレントのaxesの代わりにAXを使用します。
%
% PBASPECT は、軸の PlotBoxAspectRatio プロパティまたは
% PlotBoxAspectRatioMode プロパティを設定あるいは取得します。
%
% 参考：DASPECT, XLIM, YLIM, ZLIM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:07 $


% DASPECT   データの縦横比または縦横比のモード
% 
% DAR = DASPECT              カレントのaxesのデータの縦横比を取得します。
% DASPECT([X Y Z])           データの縦横比を設定します。
% DARMODE = DASPECT('mode')  データの縦横比モードを取得します。
% DASPECT(mode)              データの縦横比を設定します
%                            (mode は、'auto'、'manual' のいずれかです)
% DASPECT(AX,...)            カレントのaxesの代わりに AX を使用します。
%
% DASPECT は、軸の DataAspectRatio プロパティまたは DataAspectRationMode
% プロパティを取得あるいは設定します。
%
% 参考：PBASPECT, XLIM, YLIM, ZLIM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:51 $


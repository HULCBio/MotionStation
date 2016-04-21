% UISUSPEND   figureのすべての対話的なプロパティを停止します
%
% UISTATE = UISUSPEND(FIG )は、figureウィンドウの対話的なプロパティを
% 停止して、以前の状態を構造体 UISTATE に出力します。この構造体は、
% figureのWindowButton* 関数とポインタに関する情報を含んでいます。また、
% figureのすべての子オブジェクトに対する ButtonDownFcn も含んでいます。
%
% 参考：UIRESTORE.


%   Chris Griffin, 6-19-97
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:09:08 $

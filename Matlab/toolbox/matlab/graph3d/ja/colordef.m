% COLORDEF   カラーのデフォルトの設定
% 
% COLORDEF WHITE または COLORDEF BLACK は、連続的に作成される
% figureが白または黒のaxesバックグランドカラーでプロットされるように、
% rootのカラーのデフォルトを変更します。figureのバックグランドカラーは
% グレイの色合いに変更され、他の多くのデフォルトは、ほとんどのプロットに
% 対して適切なコントラストになるように変更されます。
%
% COLORDEF NONE は、デフォルトをMATLAB 4の値に設定します。最も注意
% すべき違いは、軸のバックグランドとfigureのバックグランドカラーが同じで
% あるよに、軸のバックグランドが 'none' に設定されることです。この場合、
% figureのバックグランドカラーは黒に設定されます。
%
% COLORDEF(FIG,OPTION)は、OPTION に基づいてfigure FIG のデフォルト
% を変更します。OPTIONは、'white','black'、'none' のいずれかです。
% figureはこの COLORDEF を使う前に、(CLF によって)最初に消去されな
% ければなりません。
%
% H = COLORDEF('new',OPTION) は、指定したデフォルト OPTION によって
% 作成された新規のfigureのハンドルを出力します。このコマンドの形式は、
% デフォルト環境を制御したい場合、GUIにおいて便利です。figureは、
% フラッシュを防ぐために 'visible','off' を使って作成されます。
%
% 参考：WHITEBG.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:47 $

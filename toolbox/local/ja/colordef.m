function hh = colordef(arg1,arg2)
%COLORDEF   色のデフォルトの設定
%   COLORDEF WHITEまたはCOLORDEF BLACKは、連続するfigureの
%   axesのバックグラウンドカラーが白または黒でプロットされるように、
%   ルートの色のデフォルトを変更します。figureのバックグラウンドカラー
%   はグレイの色調に変更され、他の多くのデフォルトは、ほとんどのプ
%   ロットで適切なコントラストになるように変更されます。
%
%   COLORDEF NONEは、デフォルトをMATLAB 4のデフォルト値に設定
%   します。最も目立つ違いは、axisのバックグラウンドカラーとfigureの
%   バックグラウンドカラーを同じにするために、axisのバックグラウンド
%   が'none'に設定されることです。figureのバックグラウンドカラーは、
%   黒に設定されます。
%
%   COLORDEF(FIG,OPTION)は、FIGで識別されるfigureのデフォルトを
%   OPTIONに基づいて変更します。OPTIONは、'white','black'または
%   'none'です。figureは、このCOLORDEFによる変更を使う前に、(CLF
%   を使って)最初に消去されなければなりません。
%
%   H = COLORDEF('new',OPTION)は、指定したデフォルトのOPTIONを
%   使って作成された新たなfigureのハンドル番号を出力します。
%   この形式のコマンドは、GUIでデフォルトの環境を制御したいときに、
%   便利なものです。figureは、フラッシュを防ぐために'visible','off'で
%   作成されます。
%
%   参考    WHITEBG.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2001/03/01 23:07:38 $

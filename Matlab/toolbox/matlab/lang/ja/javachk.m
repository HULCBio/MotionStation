% JAVACHK   Javaサポートレベルの確認
%
% MSG = JAVACHK(LEVEL) は、Javaサポートの必要なレベルが使用可能か否かに
% ついて、基本的なエラーメッセージを戻します。このレベルを満たす場合は、
% 空行列を出力します。つぎのサポートレベルが存在します。
%
%   LEVEL      意味
%   -----------------------------------------------------
%   'jvm'      Java Virtual Machineが起動中
%   'awt'      AWT 要素が使用可能
%   'swing'    Swing 要素が使用可能
%   'desktop'  MATLABインタラクティブデスクトップが起動中
%
% MSG = JAVACHK(LEVEL, COMPONENT) は、必要なJavaサポートレベルが
% 使用不可の場合は、与えられた COMPONENT にエラーメッセージを出力し
% ます。 使用可能な場合は、空行列が出力されます。つぎの例題を参照して
% ください。
%
% 例題：
% Java Frameを表示するm-ファイルを書いたり、Frameが表示できない場合
% は、つぎのようにしてください。:
%   
%   error(javachk('awt','myFile'));
%   myFrame = java.awt.Frame;
%   myFrame.setVisible(1);
%
% Frameが表示できない場合は、読み込みエラーが出力されます。:
%   ??? myFile is not supported on this platform.
%
% 参考：USEJAVA

%   Copyright 1984-2002 The MathWorks, Inc.

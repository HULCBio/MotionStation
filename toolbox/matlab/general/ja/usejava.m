% USEJAVA  指定したJavaの機能がMATLABでサポートされているかを判別
%
% USEJAVA(LEVEL) は、機能がサポートされている場合は 1 で、他の場合は
% 0 です。
%
% サポートには、つぎのレベルがあります。
%
%   レベル     意味
%   -----------------------------------------------------
%   'jvm'      Java Virtual Machineが実行中
%   'awt'      AWTコンポーネントが利用可能
%   'swing'    Swingコンポーネントが利用可能
%   'desktop'  MATLABインタラクティブデスクトップが実行中
%
% "AWT コンポーネント"は、Abstract Window Toolkitの中のJavaのGUIコン
% ポーネントと考えます。"Swing コンポーネント"は、Java Foundation 
% Classesの中のJavaのlightweight GUIコンポーネントと考えます。
%
% 例題：
%
% Java Frameを表示するM-ファイルを記述したり、ディスプレイが設定できな
% いか、あるいはJVMが利用できない場合に強力にしたい場合、つぎのよう
% にしてください。
%   
%   if usejava('awt')
%      myFrame = java.awt.Frame;
%   else
%      disp('Unable to open a Java Frame.');
%   end
%
% JVMにアクセスできないMATLABセッションの中で実行している場合、Java
% コードを使ったM-ファイルを書き込み、それをうまく失敗したい場合は、つぎ
% のチェックを付けることができます。
%
%   if ~usejava('jvm')
%      error([mfilename ' requires Java to run.']);
%   end
%
% 参考：JAVACHK


%   Copyright 1984-2002 The MathWorks, Inc.

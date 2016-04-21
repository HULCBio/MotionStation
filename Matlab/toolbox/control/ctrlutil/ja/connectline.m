% CONNECTLINE   Model Inputs と Output ダイアグラムに対するコールバックを含む
% 
% CONNECTLINE(ACTION) は、ACTION で設定されたブロックコールバックを実現
% します。
% 
% ACTION は、つぎの文字列のいずれかを使用できます。   
%   1) copy:   (CopyFcn)   ブロックの名前をコピーされたライン名に変更し
%                          ます。 
%   2) delete: (DeleteFcn) ブロックを使ってラインの再結合を行います。
%   3) open:   (OpenFcn)   ブロックと交差するラインにブロックを結線したり、
%                          結線を外したりします。


%   Karen Gondoly, 12-2-96
%   Copyright 1986-2002 The MathWorks, Inc. 
% $Revision: 1.6.4.1 $

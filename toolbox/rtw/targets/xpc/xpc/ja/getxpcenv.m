% GETXPCENV は、xPC ターゲント環境プロパティを取得します。
% 
% GETXPCENV は、MATLAB コマンドウインドウに、プロパティ名、カレント
% プロパティ値と、xPC Target 環境の新しいプロパティ値の設定を表示します。
%  
% ENV = GETXPCENV は、構造体 ENV に xPC Target 環境を出力します。MATLAB
% コマンドウインドウ内の出力は、行われません。
%
% ENV=GETXPCENV('PROPNAME') は、関連するプロパティ値を出力します。
%
% ENV は、つぎの3つのフィールドネームをもっています:
% 
%          propname:     プロパティ名
%          actpropval:   カレントプロパティ値
%          newpropval:   新しいプロパティ値
% 
% 参考： SETXPCENV, UPDATEXPCENV, XPCBOOTDISK, XPCSETUP

%   Copyright 1996-2002 The MathWorks, Inc.

% TRANGE   複数のシステムの時間応答のための時間ベクトルを作成
%
% TVECS = TRANGE(PLOTTYPE,TFINAL,X0,SYS1,...,SYSk) は、LTIシステム 
% SYS1,...,SYSk の時間応答をシミュレーションするために時間ベクトル 
% TVECS{1},...,TVECS{k} を作成します。これらすべてのベクトルは、t = 0 
% からスタートし、時間 TFINAL で終了します。TFINAL までの指令値を指定
% しない場合、自動的に作成されます。
%
% 2. Tf = [] のとき、Focus = [0, ?] です。
% 実際のシミュレーション時間は、Focus(2) を超えます。


%   Author:  P. Gahinet, 4-18-96
%   Revised: B. Eryilmaz
%	 Copyright 1986-2002 The MathWorks, Inc. 

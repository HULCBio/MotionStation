% PARALLEL   2つのLTIシステムの並列結合
%
%                       +------+
%         v1 ---------->|      |----------> z1
%                       | SYS1 |
%                u1 +-->|      |---+ y1
%                   |   +------+   |
%          u ------>+              O------> y
%                   |   +------+   |
%                u2 +-->|      |---+ y2
%                       | SYS2 |
%         v2 ---------->|      |----------> z2
%                       +------+
%
% SYS = PARALLEL(SYS1,SYS2,IN1,IN2,OUT1,OUT2) は、IN1 とIN2 で指定された
% 入力を接続し、OUT1 と OUT2 で指定された出力を足し合わせて、2つのLTI
% システム SYS1 と SYS2 を並列に結合します。結果のLTIモデル SYS は、
% [v1;u;v2] から [z1;y;z2] に割り当てられます。ベクトル IN1 と IN2 は、
% SYS1 と SYS2 への入力ベクトルのインデックスを含んでいて、ダイアグラム
% の中の入力チャンネル u1 と u2 を定義しています。同様に、ベクトル OUT1 
% と OUT2 は、これら2つのシステムの出力のインデックスを含んでいます。
%
% IN1, IN2, OUT1, OUT2 が、共に省略された場合、PARALLEL は、一般的な 
% SYS1 と SYS2の並列結合を形成し、つぎの出力をします。
% 
%       SYS = SYS2 + SYS1 
%
% SYS1 と SYS2 が、LTIモデルの配列の場合、PARALLEL は同じサイズの LTI配列
% SYS を出力します。ここで、
% 
%   SYS(:,:,k) = PARALLEL(SYS1(:,:,k),SYS2(:,:,k),IN1,...)
%
% 参考 : APPEND, SERIES, FEEDBACK, LTIMODELS.


%	Clay M. Thompson 6-27-90, Pascal Gahinet, 4-15-96
%	Copyright 1986-2002 The MathWorks, Inc. 

% SUBSASGN は、IDMODEL オブジェクトに対するサブスクリプトによる設定
%
% つぎの代入演算が、任意の IDMODEL オブジェクト MOD に適用されます。
%      MOD(Outputs,Inputs)=RHS は、I/O チャンネルのサブセットを再度設定
%      します。
%      
%      MOD.Fieldname=RHS は、SET(MOD,'Fieldname',RHS) と等価です。
% 
% 左辺の表現は、MOD(1,[2 3]).inputname = {'u1','u2'} や MOD.A{1,3:4} = 
% [0.21 ,3.14] のようなサブスクリプト参照として正しい記法を利用できます。
%
% サブスクリプト手法の詳細は、HELP IDMODEL/SUBSREF や IDHELP CHANNELS を
% 参照してください。
% 



%   Copyright 1986-2001 The MathWorks, Inc.

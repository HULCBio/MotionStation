% SUBSASGN は、IDFRD オブジェクトに対するサブスクリプトによる設定
%
% つぎの代入演算が、任意のIDFRDオブジェクト H に適用できます。
%      H(Outputs,Inputs) = H は、I/O チャンネルのサブセットを再度設定
%      します。
%      H.Fieldname = RHS は、SET(H,'Fieldname',RHS) と等価です。
% 左辺の表現は、H(1,[2 3]).inputname={'u1','u2'} や H.fre{10}=0.18 のよう
% に、サブスクリプト参照として正しい記法を利用できます。
%
% サブスクリプト手法の詳細は、HELP IDFRD/SUBSREF や IDHELP CHANNELS を参
% 照してください。
% 



%   Copyright 1986-2001 The MathWorks, Inc.

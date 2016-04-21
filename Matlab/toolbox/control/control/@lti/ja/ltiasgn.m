% LTIASGN   割り当てられた操作のLTIプロパティを管理
%
% L = LTIASGN(L,INDICES,LRHS,SIZES,NEWSIZES,RSIZES) は、つぎの割り当てで
% 作成されたシステムのLTIプロパティを設定します。 
% 
%    SYS(INDICES) = RHS
%
% ベクトル SIZES と NEWSIZES は、操作の前と後の SYS のサイズで、RSIZES 
% は、RHS のサイズです。これらのベクトルは、必要な場合に、遅れの行列を
% リサイズするために利用されます。
%
% 参考 : SUBSASGN.


%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 

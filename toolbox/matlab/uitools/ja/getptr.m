% GETPTR   figureのポインタの取得
% 
% P = GETPTR(FIG) は、ハンドル番号 FIG で識別されるfigureのポインタを
% リストアするために使用する、パラメータ名と値の組合わせからなるセル配列
% を出力します。たとえば、つぎのようにします。
% 
%        p = getptr(gcf);
%        setptr(gcf,'hand')
%        ... do something ...
%        set(gcf,p{:})
%
% 参考： SETPTR. 


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $
%   T. Krauss, 4/96

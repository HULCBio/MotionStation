% SCRIBECLEARMODE   プロットエディタ補助関数
% 
% cooperativeモード切り替えのユーティリティ。figureを引き継ぐ前に、
% つぎの呼び出しを行います。 
% 
%    SCRIBECLEARMODE(Fig、OffCallbackFcn、Args、...)
%
% OffCallbackFcn はfigure上に格納され、つぎに OffCallbackFcn が呼び出され
% るときに引数 Args と共に実行されます。言い換えると、SCRIBECLEARMODE
% は、新規のモードが引き継がれているカレントのモードを通知し、自身の
% notification 関数を設定します。


%   Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:54:10 $

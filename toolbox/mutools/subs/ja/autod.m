% function rat_d = autod(clpg,blk,maxord,perctol,ddata,dsens,mubnd)
%
% 有理Dスケーリングに対して、各々の次数を繰り返すことによって、自動的に
% 次数を選択し、有理近似が他のすべてのDスケーリングに対して最適(非有理)
% 値になるような操作を行うようにします。MAXORD, PERCTOLは、調節可能です。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:25 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 

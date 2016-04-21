function idText=linkid(m,object,type)
%IDTEXT returns a DocBook link ID

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:42 $

object=strrep(object,' ','');
object=strrep(object,sprintf('\n'),'');
object=strrep(object,'/','-');
object=strrep(object,'%','');
object=strrep(object,'\','');
object=strrep(object,'_','-');

%valid types:
%fig - figures
%ax - axis
%obj - object

idText=['HG' type '-' object];


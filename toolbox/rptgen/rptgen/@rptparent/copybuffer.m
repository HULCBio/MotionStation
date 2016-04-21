function cbH=copybuffer(r);
%COPYBUFFER returns a handle to the copy buffer

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:12 $

cbTag='RPTGEN_CUT_COPY_BUFFER';

cbParent=rptsp('clipboard');
cbH=findall(allchild(cbParent.h),...
   'type','uimenu',...
   'tag',cbTag);
if isempty(cbH)
   cbH=uimenu('Parent',cbParent.h,...
      'tag',cbTag,...
      'label','CopyBuffer');   
else
   cbH=cbH(1);
end










function tf=istrue(c)
%ISTRUE checks to see if cslfilter is true
%   TF=ISTRUE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:18 $

sys=c.zslmethods.System;

if ~isempty(sys)
   if LocNumBlocks(sys)<c.att.minNumBlocks
      tf=logical(0);
   elseif LocNumSubSys(sys)<c.att.minNumSubSystems
      tf=logical(0);
   else
      tf=LocMaskTest(c.att.isMask,sys);
   end
else
   status(c,'Warning - could not find System to filter',2);
   tf=logical(0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nb=LocNumBlocks(sys)

nb=length(get_param(sys,'Blocks'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ns=LocNumSubSys(sys)

subsys=find_system(sys,'searchdepth',1,...
   'BlockType','SubSystem');
ns=length(subsys)-length(find(strcmp(subsys,sys)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocMaskTest(isMask,sys);

if strcmp(isMask,'either')
   tf=logical(1);
else
   if strcmp(get_param(sys,'type'),'block_diagram')
      hasMask=logical(0);
   else
      hasMask=strcmp(get_param(sys,'Mask'),'on');
   end
   
   if strcmp(isMask,'no');
      tf=~hasMask;
   else
      tf=hasMask;
   end
end
function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_SIG_LOOP)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure


% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:54:57 $

persistent RPTGEN_GETINFO_STRUCTURE
if isempty(RPTGEN_GETINFO_STRUCTURE)
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   out=getprotocomp(c);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   out.Name = 'Fixed-Point Block Loop';
   out.Type = 'FP';
   out.Desc = 'Applies all subcomponents to Fixed-Point blocks.';
   out.ValidChildren={logical(1)};
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   iBlock=getinfo(unpoint(csl_blk_loop));
   
   out.att=iBlock.att;
   out.attx=iBlock.attx;
   
   out.att.FilterTerms={};
   out.att.LoggedOnly='$all';
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   loopInfo=loopfixpt(c);
   
   out.attx.SortBy=struct('String','Sort blocks ',...
      'enumValues',{loopInfo.sortCode},...
      'enumNames',{loopInfo.sortName},...
      'UIcontrol','popupmenu');
   
   out.attx.LoggedOnly=struct('String','Report on ',...
      'enumValues',{loopInfo.logCode},...
      'enumNames',{loopInfo.logName},...
      'UIcontrol','popupmenu');
   
else
   out=RPTGEN_GETINFO_STRUCTURE;
end

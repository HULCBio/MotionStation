function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_SUMM_TABLE)
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
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:54 $

persistent RPTGEN_GETINFO_STRUCTURE
if isempty(RPTGEN_GETINFO_STRUCTURE)
   out=getprotocomp(c);
   
   out.Name = 'Fixed-Point Summary Table';
   out.Type = 'FP';
   out.Desc = 'Shows properties of several Fixed-Point blocks in one table';
   
   [out.att,out.attx]=get_summ_attribute(c.rpt_summ_table);
   
   RPTGEN_GETINFO_STRUCTURE=out;
   
else
   out=RPTGEN_GETINFO_STRUCTURE;
end

function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(C)
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
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:09 $


out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.Name = 'Fixed-Point Property Table';
out.Type = 'FP';
out.Desc = 'Inserts a table which reports on block property-value pairs';

%%%%%%%%%%%%%% Set the .att structure %%%%%%%%%%%%% 

r=rptproptable;
%getattributes sets up an empty .att structure
c.att=getattributes(r,'',1,1);
%applypresettable fills in the .att structure
c=applypresettable(r,c,'Default');
%reassign c.att to out.att
out.att=c.att;
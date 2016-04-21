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

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:55 $


out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out.Name = xlate('System Property Table');
out.Type = 'SL';
out.Desc = xlate('Inserts a table which reports on system property-value pairs');


%%%%%%%%%%%%%% Set the .att structure %%%%%%%%%%%%% 

r=rptproptable;
%getattributes sets up an empty .att structure
c.att=getattributes(r,'',1,1);
%applypresettable fills in the .att structure
c=applypresettable(r,c,'Default');
%reassign c.att to out.att
out.att=c.att;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%property tables require no .attx values
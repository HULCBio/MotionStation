function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CMLWHOS)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:24 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('MATLAB/Toolbox Version Number');
out.Type = 'ML';
out.Desc = xlate('Displays current MATLAB and toolbox version numbers in a table');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isVersion=logical(1);
out.att.isRelease=logical(0);
out.att.isDate=logical(0);

out.att.TableTitle='Version Number';
out.att.isHeaderRow=logical(1);
out.att.isBorder=logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isVersion.String='Version number';
out.attx.isRelease.String='Release number';
out.attx.isDate.String='Release date';

out.attx.TableTitle.String = 'Table title: ';
out.attx.isBorder.String='Display table border';
out.attx.isHeaderRow.String='Display header row';
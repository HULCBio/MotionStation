function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_BLK_FILTER)
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
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:45 $

out=getprotocomp(c);

out.Name = 'Fixed-Point Logging Options';
out.Type = 'FP';
out.Desc = 'Set options for logging data on Fixed-Point blocks';

out.ValidChildren={logical(0)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.FixLogPref  = '0';
out.att.FixUseDbl   = '0';
out.att.FixLogMerge = '0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%We can use descriptive strings if necessary.
%aString='Set logging options.';
%bString='Override/merge';
%cString='Use doubles';

aString='';
bString='';
cString='';

out.attx.FixLogPref=struct('String',aString,...
   'enumNames',{{
      'All Fixed-Point blocks'
      'No logging'
      'Use block "dolog" parameter'
   }},...
   'enumValues',{{'1','2','0'}},...
   'UIcontrol','radiobutton');

out.attx.FixUseDbl=struct('String',cString,...
   'enumNames',{{
      'All Fixed-Point blocks'
      'No doubles'
      'Use block "DblOver" parameter'
   }},...
   'enumValues',{{'1','2','0'}},...
   'UIcontrol','radiobutton');

out.attx.FixLogMerge=struct('String',bString,...
   'enumNames',{{
      'Override log'
      'Merge log'
   }},...
   'enumValues',{{'0','1'}},...
   'UIcontrol','radiobutton');

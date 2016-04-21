function [si,so] = dspblkblklms(action)
% DSPBLKBLKLMS Mask dynamic dialog function for Block LMS adaptive filter 
% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/06 15:24:14 $

blkh = gcbh;

if nargin==0, action = 'dynamic'; end
switch action
   case 'icon'
      [si, so] = getPortLabels(blkh);
  case 'dynamic'
      DynamicController(blkh);
end

% -----------------------------------------------
function [si, so] = getPortLabels(blkh)
si(1).port = 1;si(1).txt='Input';
si(2).port = 2;si(2).txt='Desired';
so(1).port = 1;so(1).txt='Output';
so(2).port = 2;so(2).txt='Error';

HasMuInport     =  strncmp(get_param(blkh,'stepflag'),'Input port',1);
HasAdaptInport  =  strcmp(get_param(blkh,'Adapt'),'on');
HasResetInport  =  ~strcmp(get_param(blkh,'resetflag'),'None');
HasWgtOutport =  strcmp(get_param(blkh,'weights'),'on');
i=3;
if HasMuInport
    si(i).port = i;si(i).txt='Step-size'; i=i+1;
end
if HasAdaptInport
    si(i).port = i;si(i).txt='Adapt'; i=i+1;
end
if HasResetInport
    si(i).port = i;si(i).txt='Reset'; i=i+1;
end
j=3;
if HasWgtOutport
    so(3).port = 3;so(3).txt='Wts';  j=j+1;
end

for m=i:5, si(m)=si(i-1); end
for n=j:3, so(n)=so(j-1); end

% -----------------------------------------------
function DynamicController(blkh)
% changes the visibility of widgets

extraparams = strcmp(get_param(blkh, 'addnparflag'), 'on');
curmaskvisibility = get_param(blkh, 'MaskVisibilities');
if extraparams
    newmaskvisibility = {'off','off','on','on','on','on','on','on','on','on','on','on'};
else
    newmaskvisibility = {'off','off','on','on','on','on','on','on','off','off','off','off'};
end

STEPSIZE = 4+2;   %mask index
wantStepPort = strcmp(get_param(blkh,'stepflag'),'Input port');
if wantStepPort
    newmaskvisibility{STEPSIZE} = 'off';
else
    newmaskvisibility{STEPSIZE} = 'on';
end

if ~isequal(curmaskvisibility, newmaskvisibility)
    set_param(blkh, 'MaskVisibilities', newmaskvisibility);
end

% [EOF] dspblkblklms.m



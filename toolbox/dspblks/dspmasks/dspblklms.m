function [si,so,disp_str,dtInfo] = dspblklms(varargin)
% DSPBLKLMS Mask dynamic dialog function for LMS adaptive filter 
% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.11.4.2 $ $Date: 2004/01/25 22:37:06 $

blkh = gcbh;
% num = misc(1)+accum(4)+prodOutput(8)+memory(16)+firstCoeff(32)+secondCoeff(64)=125;%%%+output(2)
dtInfo = dspGetFixptDataTypeInfo(blkh,125);
disp_str = drawIcon(blkh);
[si, so] = getPortLabels(blkh);

% -----------------------------------------------
function disp_str = drawIcon(blkh)
%Draw the algorithm name on the block
algorithm = get_param(blkh, 'Algo');
switch algorithm
    case 'LMS'
        disp_str = 'LMS';
    case 'Normalized LMS'
        disp_str = strvcat('Normalized','   LMS   ');
    case 'Sign-Error LMS'
        disp_str = strvcat('Sign-Error','   LMS   ');
    case 'Sign-Data LMS'
        disp_str = strvcat('Sign-Data','   LMS   ');
    case 'Sign-Sign LMS'
        disp_str = strvcat('Sign-Sign','   LMS   ');
    otherwise
        disp_str = 'LMS';  % should not come here
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

% [EOF] dspblklms.m

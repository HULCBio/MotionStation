function tic6xdsplib_initFcn
% tic6xdsplib_initFcn    Init Function for all TI C62 and C64 DSPLIB blocks
%
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:00:53 $
% Copyright 2001-2004 The MathWorks, Inc.

blk = gcbh;

% Make sure TI license has been agreed to

tic6xdsplib_licenseCheck(0);

% Ensure that Fixed-Point Toolbox and 
% Simulink Fixed Point are both installed.
% We have to do this in InitFcn to make sure that the
% s-functions are not invoked, because the s-functions
% may seg fault if the stuff is not there.

persistent FPT SFP

if (isempty(FPT) || ~FPT),
    FPT = license('test','Fixed_Point_Toolbox');
    if ~FPT,
        error(['Fixed-Point Toolbox is not installed. ' ...
            'You must install Fixed-Point Toolbox ' ...
            'and Simulink Fixed Point in order ' ...
            'to use the TI C62x or C64x DSP Library.']);
    end
end

if (isempty(SFP) || ~SFP),
    SFP = license('test','Fixed-Point_Blocks');
    if ~SFP,
        error(['Simulink Fixed-Point is not installed. ' ...
            'You must install Fixed-Point Toolbox ' ...
            'and Simulink Fixed Point in order ' ...
            'to use the TI C62x or C64x DSP Library.']);
    end
end

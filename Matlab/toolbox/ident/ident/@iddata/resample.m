function zd = resample(data,varargin)
%RESAMPLE  Change the sampling rate of a signal.
%   This routine requires the Signal Processing Toolbox.
%
%   DR = RESAMPLE(DATA,P,Q) resamples the IDDATA object DATA at P/Q times
%   the original sample rate. DR is an IDDATA object, whose signals are P/Q
%   times the length of DATA (or the ceiling of this if P/Q is not an integer).
%   P and Q must be positive integers. The intersample character of the input
%   (according to DATA.InterSample) is taken into account when resampling.
%
%   RESAMPLE applies an anti-aliasing (lowpass) FIR filter to DATA during the
%   resampling process, and compensates for the filter's delay.  The order of
%   this filter is determined by N in DR = RESAMPLE(DATA,P,Q,N). A larger N gives
%   better accuracy but longer computation time. For interpolation of piecewise
%   linear or piecewise constant inputs, N = 0 is used.
%
%   The routine RESAMPLE in the SIGNAL PROCESSING TOOLBOX is used. See HELP RESAMPLE
%   for more details.
%   A similar routine IDRESAMP is available that does not rely upon the
%   Signal Processing Toolbox.
%
%   See also IDFILT.


%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/10 23:16:19 $

if nargin < 3
    disp('Usage: DR = RESAMPLE(DATA,P,Q).')
    disp('       DR = RESAMPLE(DATA,P,Q,FILTER_ORDER)')
    return
end
[dum,ny,nu] = size(data);
if exist('signal/resample')
    y = data.OutputData;
    u = data.InputData;
    Ts = data.Ts;
    Tst = data.Tstart;
    inters = data.InterSample;
    P = varargin{1};
    Q = varargin{2};
    for kexp = 1:length(y)
        if ny>0
            yr{kexp} = resample(y{kexp},varargin{:});
        end
        uu = u{kexp};
        for ku = 1:nu
            if any(strcmp(inters{ku,kexp},{'zoh','foh'}))&P>Q
                ur1(:,ku)=resample(uu(:,ku),P,Q,0);
            else
                ur1(:,ku)=resample(uu(:,ku),varargin{:});
            end
        end
        if nu>0
            ur{kexp} = ur1;
        else
            ur{kexp} = zeros(size(yr,1),0);
        end
        if ny==0
            yr{kexp} = zeros(size(ur1,1),0);
        end
        Tsr{kexp} = Ts{kexp}*varargin{2}/varargin{1};
        if isempty(Tst{kexp})
            Tstr{kexp} = Ts{kexp};
        else
            Tstr{kexp} = Tst{kexp};
        end

    end
    zd = data;
    zd.OutputData = yr;
    zd.InputData = ur;
    zd.Ts = Tsr;
    zd.Tstart = Tstr;
else
    error(sprintf([' IDDATA/RESAMPLE requires the Signal Processing Toolbox.',...
        '\n See IDRESAMP for an alternative.']))
end

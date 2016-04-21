function varargout=adaptfilt(varargin)
%ADAPTFILT  Adaptive filter object.
%   H = ADAPTFILT.ALGORITHM(input1,...) returns an adaptive filter object,
%   H, of type ALGORITHM. You must specify an algorithm with ADAPTFILT.
%   Each algorithm takes several inputs. When you specify ADAPTFILT.ALGORITHM
%   with no inputs, a filter with default parameters is created (the
%   defaults depend on the particular filter algorithm). Some default
%   parameters can then be changed with SET(H,PARAMNAME,PARAMVAL).
%   
%   ADAPTFILT.ALGORITHM can be one of the following (type help
%   adaptfilt/algorithm to get help on a specific algorithm - e.g. help
%   adaptfilt/lms):
%		
%   adaptfilt.lms           Direct-form least-mean-square FIR adaptive filter 
%   adaptfilt.nlms          Direct-form Normalized LMS FIR adaptive filter
%   adaptfilt.dlms          Direct-form delayed LMS FIR adaptive filter
%   adaptfilt.blms          Block LMS FIR adaptive filter
%   adaptfilt.blmsfft       FFT-based block LMS FIR adaptive filter
%
%   adaptfilt.ss            Direct-form sign-sign FIR adaptive filter
%   adaptfilt.se            Direct-form sign-error FIR adaptive filter
%   adaptfilt.sd            Direct-form sign-data FIR adaptive filter
%
%   adaptfilt.filtxlms      Filtered-X LMS FIR adaptive filter
%   adaptfilt.adjlms        Adjoint LMS FIR adaptive filter
%
%   adaptfilt.lsl           Least-squares lattice FIR adaptive filter
%   adaptfilt.qrdlsl        QR-decomposition LS lattice FIR adaptive filter
%   adaptfilt.gal           Gradient adaptive lattice FIR adaptive filter
%
%   adaptfilt.fdaf          Frequency-domain FIR adaptive filter
%   adaptfilt.ufdaf         Unconstrained frequency-domain FIR adaptive filter
%   adaptfilt.pbfdaf        Partitioned-block FDAF
%   adaptfilt.pbufdaf       Partitioned-block unconstrained FDAF
%   adaptfilt.tdafdft       Transform-domain FIR adaptive filter using DFT
%   adaptfilt.tdafdct       Transform-domain FIR adaptive filter using DCT
%
%   adaptfilt.rls           Recursive least-squares FIR adaptive filter
%   adaptfilt.hrls          Householder RLS FIR adaptive filter
%   adaptfilt.swrls         Sliding-window RLS FIR adaptive filter
%   adaptfilt.hswrls        Householder SWRLS FIR adaptive filter
%   adaptfilt.qrdrls        QR-decomposition RLS FIR adaptive filter
%
%   adaptfilt.ftf           Fast transversal least-squares FIR adaptive filter
%   adaptfilt.swftf         Sliding-window FTF FIR adaptive filter
%
%   adaptfilt.ap            Affine projection FIR adaptive filter
%   adaptfilt.bap           Block AP FIR adaptive filter
%   adaptfilt.apru          AP FIR adaptive filter with recursive matrix update
%
%   The following methods are available for adaptive filters (type help
%   adaptfilt/METHOD to get help on a specific method - e.g. help
%   adaptfilt/filter):
%
%   adaptfilt/coefficients  Instantaneous adaptive filter coefficients.
%   adaptfilt/filter        Execute ("run") adaptive filter.
%   adaptfilt/freqz         Instantaneous adaptive filter frequency response.
%   adaptfilt/grpdelay      Instantaneous adaptive filter group-delay.
%   adaptfilt/impz          Instantaneous adaptive filter impulse response.
%   adaptfilt/info          Adaptive filter information.
%   adaptfilt/isfir         True for FIR adaptive filters.
%   adaptfilt/islinphase    True for linear phase adaptive filters.
%   adaptfilt/ismaxphase    True for maximum-phase adaptive filters.
%   adaptfilt/isminphase    True for minimum-phase adaptive filters.
%   adaptfilt/isreal        True for real adaptive filters.
%   adaptfilt/isstable      True for stable adaptive filters.
%   adaptfilt/maxstep       Maximum step size.
%   adaptfilt/msepred       Predicted mean-square error.
%   adaptfilt/msesim        Measured mean-square error.
%   adaptfilt/norm          Instantaneous filter norm.
%   adaptfilt/phasez        Instantaneous adaptive filter phase response.
%   adaptfilt/reset         Reset adaptive filter.
%   adaptfilt/stepz         Instantaneous adaptive filter step response.
%   adaptfilt/tf            Instantaneous adaptive filter transfer function.
%   adaptfilt/zerophase     Instantaneous adaptive filter zerophase response.
%   adaptfilt/zpk           Instantaneous adaptive filter zero/pole/gain.
%   adaptfilt/zplane        Instantaneous adaptive filter Z-plane pole-zero plot.
%
%   Example: System identification with LMS adaptive filter.
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      mu = 0.008;            % LMS step size
%      h = adaptfilt.lms(32,mu);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   For more information, enter
%      doc adaptfilt
%   at the MATLAB command line.
%
%   See also DFILT, MFILT.

%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/12 23:15:38 $

msg = sprintf(['Use ADAPTFILT.ALGORITHM to create an adaptive filter.\n',...
               'For example,\n   H = adaptfilt.lms']);
error(msg)

% [EOF]

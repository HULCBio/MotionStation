function varargout=mfilt(varargin)
%MFILT  Multirate filter object.
%   Hm = MFILT.STRUCTURE(input1,...) returns a multirate filter object,
%   Hm, of type STRUCTURE. You must specify a structure with MFILT. Each
%   structure takes one or more inputs. When you specify a MFILT.STRUCTURE
%   with no inputs, a filter with default property values is created (the
%   defaults depend on the particular filter structure). The properties may
%   be changed with SET(Hd,PARAMNAME,PARAMVAL).
%
%   MFILT.STRUCTURE can be one of the following (type help mfilt/STRUCTURE
%   to get help on a specific structure - e.g. help mfilt/cicdecim):
%
%   mfilt.cicdecim           Cascaded integrator-comb decimator
%   mfilt.cicdecimzerolat    Zero-latency cascaded integrator-comb decimator
%   mfilt.cicinterp          Cascaded integrator-comb interpolator
%   mfilt.cicinterpzerolat   Zero-latency cascaded integrator-comb interpolator
%   mfilt.fftfirinterp       Overlap-add FIR polyphase interpolator
%   mfilt.firdecim           Direct-form FIR polyphase decimator
%   mfilt.firfracdecim       Direct-form FIR polyphase fractional decimator
%   mfilt.firfracinterp      Direct-form FIR polyphase fractional interpolator
%   mfilt.firinterp          Direct-form FIR polyphase interpolator
%   mfilt.firsrc             Direct-form FIR polyphase sample-rate converter
%   mfilt.firtdecim          Direct-form transposed FIR polyphase decimator 
%   mfilt.holdinterp         FIR hold interpolator
%   mfilt.linearinterp       FIR linear interpolator
%
%   The following methods are available for multirate filters (type help
%   mfilt/METHOD to get help on a specific method - e.g. help
%   mfilt/filter):
%
%   mfilt/block              Generate a Signal Processing Blockset block.
%   mfilt/coefficients       Filter coefficients.
%   mfilt/filter             Execute ("run") multirate filter.
%   mfilt/firtype            Determine the type (1-4) of a linear phase FIR filter.
%   mfilt/freqz              Frequency response of a multirate filter.
%   mfilt/grpdelay           Group-delay of a multirate filter.
%   mfilt/impz               Impulse response.
%   mfilt/info               Filter information.
%   mfilt/isfir              True for FIR filter.
%   mfilt/islinphase         True for linear phase filter.
%   mfilt/ismaxphase         True if maximum phase.
%   mfilt/isminphase         True if minimum phase.
%   mfilt/isreal             True for filter with real coefficients.
%   mfilt/isstable           True if the filter is stable.
%   mfilt/norm               Filter norm.
%   mfilt/nstates            Number of states in multirate filter.
%   mfilt/order              Filter order.
%   mfilt/phasedelay         Phase delay of a multirate filter.
%   mfilt/phasez             Phase response of a multirate filter.
%   mfilt/polyphase          Polyphase matrix of multirate filter.
%   mfilt/reset              Reset multirate filter.
%   mfilt/stepz              Step response.
%   mfilt/tf                 Transfer function for multirate filter.
%   mfilt/zerophase          Zero-phase response.
%   mfilt/zpk                Zero-pole-gain conversion.
%   mfilt/zplane             Multirate filter Z-plane pole-zero plot.
%
%   EXAMPLE: Decimate a signal which consists of the sum of 2 sinusoids. 
%    N = 160;
%    x = sin(2*pi*.05*[0:N-1]+pi/3)+cos(2*pi*.03*[0:N-1]+pi/3);
%    M = 3;                  % Decimation factor
%    Hm = mfilt.firdecim(M); % Create a Direct-Form FIR Polyphase Decimator
%    y = filter(Hm,x);
%
%   For more information, enter
%      doc mfilt
%   at the MATLAB command line.
%
%   See also DFILT, ADAPTFILT.
%

%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2004/04/12 23:24:55 $

msg = sprintf(['Use MFILT.STRUCTURE to create a multirate filter.\n',...
               'For example,\n   Hd = mfilt.firdecim']);
error(msg)

% [EOF]

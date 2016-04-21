function this = fdesign
%FDESIGN   Filter Design object.
%   Hs = FDESIGN.TYPE(SPECTYPE,SPEC1, SPEC2,...) returns a filter design
%   object Hs, of type TYPE.  You must specify a TYPE when constructing an
%   FDESIGN object. If SPECTYPE is not specified, a default specification
%   is used. If the first input is not a specification type it will be
%   interpreted as the first specification value, SPEC1.
%
%   Different specification types may have different design methods
%   available. Use DESIGNMETHODS(Hs) to get a list of design methods
%   available for a given SPECTYPE.
%
%   By default, all frequency specifications are assumed to be in
%   normalized frequency units. Moreover, all magnitude specifications are
%   assumed to be in dB.
%
%   Hs = FDESIGN.TYPE(...,Fs) specifies the sampling frequency (in
%   Hz). In this case, all other frequency specifications are also in Hz.
%
%   Hs = FDESIGN.TYPE(...,MAGUNITS) specifies the units for any magnitude
%   specification given in the constructor. MAGUNITS can be one of the
%   following: 'linear', 'dB', or 'squared'. If this argument is omitted,
%   'dB' is assumed. Note that the magnitude specifications are always
%   converted and stored in dB regardless of how they were specified.
%
%   FDESIGN.TYPE can be one of the following (type help fdesign/TYPE
%   to get help on a specific structure - e.g. help fdesign/lowpass):
%
%   fdesign.bandpass    - Designs bandpass filters.
%   fdesign.bandstop    - Designs bandstop filters.
%   fdesign.decim       - Designs decimators.
%   fdesign.halfband    - Designs halfband filters.
%   fdesign.highpass    - Designs highpass filters.
%   fdesign.interp      - Designs interpolators.
%   fdesign.lowpass     - Designs lowpass filters.
%   fdesign.nyquist     - Designs nyquist filters.
%   fdesign.src         - Designs sample-rate converters.
%
%   The following methods are available for filter design objects (type
%   help fdesign/METHOD to get help on a specific method - e.g. help
%   fdesign/setspecs):
%
%   ---------------------Design Methods------------------------------------
%   fdesign/butter       - Design a Butterworth filter.
%   fdesign/cheby1       - Design a Chebyshev Type I filter.
%   fdesign/cheby2       - Design a Chebyshev Type II filter.
%   fdesign/ellip        - Design an Elliptic filter.
%   fdesign/equiripple   - Design an Equiripple filter.
%   fdesign/firls        - Design a Least-squares filter.
%   fdesign/kaiserwin    - Design a filter using a kaiser window.
%
%   When any of the design methods are called with no output, the designed
%   filter is shown in FVTool.
%
%   ---------------------Helper Methods------------------------------------
%   fdesign/setspecs      - Set all of the specifications simultaneously.
%   fdesign/designmethods - Returns the designmethods currently available.
%
%   SETSPECS inputs should be given in the same order as specified in the
%   constructor.  Type help fdesign/setspecs for more information.  
%
%   % EXAMPLE 1: Construct a lowpass object with default specification type.
%   hs = fdesign.lowpass(0.4,.5,1,80); % Default minimum-order specification
%   % List available design methods for this particular specification type
%   designmethods(hs);
%   % Design a Butterworth filter matching the passband specifications
%   % exactly (and exceeding the stopband specifications).
%   Hd = butter(hs,'MatchExactly','passband');
%   fvtool(Hd);
%
%   % Example 2, construct a halfband object with order and stopband
%   attenuation. Specify the sampling frequency and the magnitude units.
%   N = 80; % Filter order
%   Rst = 1e-4; % Stopband ripple, equivalent to 80 dB attenuation
%   Fs = 48e3;
%   hs = fdesign.halfband('N,Ast', N, Rst, Fs, 'linear');
%   designmethods(hs);
%   equiripple(hs); % FVTool is launched
%
%   For more information, enter
%       doc fdesign
%   at the MATLAB command line.
%
%   See also fdesign/designmethods, fdesign/setspecs, fdatool, fvtool.

%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:17:22 $

msg = sprintf(['Use FDESIGN.* to create a filter designer object.\n',...
               'For example,\n   h = fdesign.lowpass']);
error(msg)

% Not supported objects.

%   fdesign.halfband    - Designs halfband filters, both lowpass and highpass.
%   fdesign.nyquist     - Designs nyquist filters.
%   fdesign.decim       - Designs decimators.
%   fdesign.interp      - Designs interpolators.
%   fdesign.src         - Designs sample-rate converters.

%   fdesign/equiripple   - Design an Equiripple filter.
%   fdesign/firls        - Design a Least-squares filter.
%   fdesign/kaiserwin    - Design a filter using a Kaiser window.

% [EOF]

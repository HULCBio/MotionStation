% Filter Design Toolbox
% Version 3.0 (R14) 05-May-2004
%
% TABLE OF CONTENTS
% -----------------
% Adaptive Filters.
% Discrete-Time Filters.
% Filter Conversions and Frequency Transformations.
% Filter Design.
% Multirate Filters.
%
% Adaptive Filters
% ----------------
% Algorithms.
%   adaptfilt                   - Family of adaptive filters.
%
%   adaptfilt/adjlms            - Adjoint LMS FIR adaptive filter.
%   adaptfilt/blms              - Block LMS FIR adaptive filter.
%   adaptfilt/blmsfft           - FFT-based block LMS FIR adaptive filter.
%   adaptfilt/dlms              - Direct-form delayed LMS FIR adaptive filter.
%   adaptfilt/filtxlms          - Filtered-X LMS FIR adaptive filter.
%   adaptfilt/lms               - Direct-form least-mean-square FIR adaptive filter.
%   adaptfilt/nlms              - Direct-form Normalized LMS FIR adaptive filter.
%
%   adaptfilt/sd                - Direct-form sign-data FIR adaptive filter.
%   adaptfilt/se                - Direct-form sign-error FIR adaptive filter.
%   adaptfilt/ss                - Direct-form sign-sign FIR adaptive filter.
%
%   adaptfilt/gal               - Gradient adaptive lattice FIR adaptive filter.
%   adaptfilt/lsl               - Least-squares lattice FIR adaptive filter.
%   adaptfilt/qrdlsl            - QR-decomposition LS lattice FIR adaptive filter.
%
%   adaptfilt/ap                - Affine projection FIR adaptive filter.
%   adaptfilt/bap               - Block AP FIR adaptive filter.
%   adaptfilt/apru              - AP FIR adaptive filter with recursive matrix updates.
%
%   adaptfilt/fdaf              - Frequency-domain FIR adaptive filter.
%   adaptfilt/ufdaf             - Unconstrained frequency-domain FIR adaptive filter.
%   adaptfilt/pbfdaf            - Partitioned-block FDAF.
%   adaptfilt/pbufdaf           - Partitioned-block unconstrained FDAF.
%   adaptfilt/tdafdft           - Transform-domain FIR adaptive filter using DFT.
%   adaptfilt/tdafdct           - Transform-domain FIR adaptive filter using DCT.
%
%   adaptfilt/ftf               - Fast transversal least-squares FIR adaptive filter.
%   adaptfilt/swftf             - Sliding-window FTF FIR adaptive filter.
%
%   adaptfilt/hrls              - Householder RLS FIR adaptive filter.
%   adaptfilt/hswrls            - Householder SWRLS FIR adaptive filter.
%   adaptfilt/qrdrls            - QR-decomposition RLS FIR adaptive filter.
%   adaptfilt/rls               - Recursive least-squares FIR adaptive filter.
%   adaptfilt/swrls             - Sliding-window RLS FIR adaptive filter.
%
% Analysis and simulation.
%   adaptfilt/block             - Generate a Signal Processing Blockset block.
%   adaptfilt/coefficients      - Instantaneous adaptive filter coefficients.
%   adaptfilt/filter            - Execute ("run") adaptive filter.
%   adaptfilt/freqz             - Instantaneous adaptive filter frequency response.
%   adaptfilt/grpdelay          - Instantaneous adaptive filter group-delay.
%   adaptfilt/impz              - Instantaneous adaptive filter impulse response.
%   adaptfilt/info              - Adaptive filter information.
%   adaptfilt/isfir             - True for Finite Impulse Response (FIR) adaptive filters.
%   adaptfilt/islinphase        - True for linear phase adaptive filters.
%   adaptfilt/ismaxphase        - True for maximum-phase adaptive filters.
%   adaptfilt/isminphase        - True for minimum-phase adaptive filters.
%   adaptfilt/isreal            - True for adaptive filters with real coefficients.
%   adaptfilt/isstable          - True for stable adaptive filters.
%   adaptfilt/maxstep           - Maximum step size.
%   adaptfilt/msepred           - Predicted mean-square error.
%   adaptfilt/msesim            - Measured mean-square error via simulation.
%   adaptfilt/norm              - Instantaneous filter norm.
%   adaptfilt/phasez            - Instantaneous adaptive filter phase response.
%   adaptfilt/reset             - Reset adaptive filter.
%   adaptfilt/stepz             - Instantaneous adaptive filter step response.
%   adaptfilt/tf                - Instantaneous adaptive filter transfer function.
%   adaptfilt/zerophase         - Instantaneous adaptive filter zerophase response.
%   adaptfilt/zpk               - Instantaneous adaptive filter zero/pole/gain.
%   adaptfilt/zplane            - Instantaneous adaptive filter Z-plane pole-zero plot.
%
% Discrete-Time Fixed-Point/Floating-Point Filters.
% ------------------------------------------------
% Structures.
%   dfilt                       - Family of fixed-point and floating-point filters.
%   dfilt/calattice             - Coupled-allpass lattice.
%   dfilt/calatticepc           - Coupled-allpass lattice with power complementary output.
%
% Analysis and simulation.
%   coeread                     - Read a XILINX CORE Generator(tm) coefficient (.COE) file.
%   dfilt/coewrite              - Write a XILINX CORE Generator(tm) coefficient (.COE) file.
%   dfilt/cumsec                - Vector of cumulative second-order section filters.
%   dfilt/denormalize           - Restore the coefficients from a NORMALIZE.
%   dfilt/double                - Cast filter to double-precision floating-point arithmetic.
%   dfilt/firlp2hp              - FIR Type I lowpass to highpass transformation.
%   dfilt/firlp2lp              - FIR Type I lowpass to lowpass transformation.
%   dfilt/iirbpc2bpc            - Complex bandpass to complex bandpass.
%   dfilt/iirlp2bp              - Real lowpass to real    bandpass.
%   dfilt/iirlp2bpc             - Real lowpass to complex bandpass.
%   dfilt/iirlp2bs              - Real lowpass to real    bandstop.
%   dfilt/iirlp2bsc             - Real lowpass to complex bandstop.
%   dfilt/iirlp2hp              - Real lowpass to real    highpass.
%   dfilt/iirlp2lp              - Real lowpass to real    lowpass.
%   dfilt/iirlp2mb              - Real lowpass to real    multi-band.
%   dfilt/iirlp2mbc             - Real lowpass to complex multi-band.
%   dfilt/iirlp2xc              - Real lowpass to N-point complex one.
%   dfilt/iirlp2xn              - Real lowpass to N-point real one.
%   dfilt/noisepsd              - Power spectral density of output noise.
%   dfilt/norm                  - Filter norm.
%   dfilt/normalize             - Normalize filter coefficients.
%   dfilt/reffilter             - Reference double-precision floating-point filter.
%   dfilt/reorder               - Reorder second-order sections.
%   dfilt/scale                 - Scale second-order sections.
%   dfilt/scalecheck            - Check scale of second-order sections.
%   dfilt/scaleopts             - Create options object for sos scaling.
%   dfilt/specifyall            - Fully specify fixed-point filter settings.
%
% Filter Conversions and Frequency Transformations.
%--------------------------------------------------
% Filter conversions.
%   ca2tf                       - Coupled allpass to transfer function.
%   cl2tf                       - Coupled allpass lattice to transfer function.
%   firlp2hp                    - FIR Type I lowpass to highpass transformation.
%   firlp2lp                    - FIR Type I lowpass to lowpass transformation.
%   firminphase                 - Minimum-phase FIR spectral factor.
%   iirpowcomp                  - IIR power complementary filter.
%   tf2ca                       - Transfer function to coupled allpass.
%   tf2cl                       - Transfer function to coupled allpass lattice.
%
% Frequency transformations via numerator and denominator.
%   iirbpc2bpc                  - Complex bandpass to complex bandpass.
%   iirlp2bp                    - Real lowpass to real    bandpass.
%   iirlp2bpc                   - Real lowpass to complex bandpass.
%   iirlp2bs                    - Real lowpass to real    bandstop.
%   iirlp2bsc                   - Real lowpass to complex bandstop.
%   iirlp2hp                    - Real lowpass to real    highpass.
%   iirlp2lp                    - Real lowpass to real    lowpass.
%   iirlp2mb                    - Real lowpass to real    multi-band.
%   iirlp2mbc                   - Real lowpass to complex multi-band.
%   iirlp2xc                    - Real lowpass to N-point complex one.
%   iirlp2xn                    - Real lowpass to N-point real one.
%   iirrateup                   - Upsampling of the filter by integer factor.
%   iirshiftc                   - Complex rotation in the frequency domain.
%   iirshift                    - Real rotation in the frquency domain.
%   iirftransf                  - Mapping from the original filter to the target one.
%
% Frequency transformations via poles, zeros and gain factor.
%   zpkbpc2bpc                  - Complex bandpass to complex bandpass.
%   zpklp2bp                    - Real lowpass to real    bandpass.
%   zpklp2bpc                   - Real lowpass to complex bandpass.
%   zpklp2bs                    - Real lowpass to real    bandstop.
%   zpklp2bsc                   - Real lowpass to complex bandstop.
%   zpklp2hp                    - Real lowpass to real    highpass.
%   zpklp2lp                    - Real lowpass to real    lowpass.
%   zpklp2mb                    - Real lowpass to real    multi-band.
%   zpklp2mbc                   - Real lowpass to complex multi-band.
%   zpklp2xc                    - Real lowpass to N-point complex one.
%   zpklp2xn                    - Real lowpass to N-point real one.
%   zpkrateup                   - Upsampling of the filter by integer factor.
%   zpkshiftc                   - Complex rotation in the frequency domain.
%   zpkshift                    - Real rotation in the frquency domain.
%   zpkftransf                  - Mapping from the original filter to the target one.
%
% Mapping filters for frequency transformations.
%   allpassbpc2bpc              - Complex bandpass to complex bandpass.
%   allpasslp2bp                - Real lowpass to real    bandpass.
%   allpasslp2bpc               - Real lowpass to complex bandpass.
%   allpasslp2bs                - Real lowpass to real    bandstop.
%   allpasslp2bsc               - Real lowpass to complex bandstop.
%   allpasslp2hp                - Real lowpass to real    highpass.
%   allpasslp2lp                - Real lowpass to real    lowpass.
%   allpasslp2mb                - Real lowpass to real    multi-band.
%   allpasslp2mbc               - Real lowpass to complex multi-band.
%   allpasslp2xc                - Real lowpass to N-point complex one.
%   allpasslp2xn                - Real lowpass to N-point real one.
%   allpassrateup               - Upsampling of the filter by integer factor.
%   allpassshiftc               - Complex rotation in the frequency domain.
%   allpassshift                - Real rotation in the frquency domain.
%
% Filter Design.
% --------------
% Filter design algorithms.
%   firceqrip                   - Constrained equiripple FIR filter design.
%   fircband                    - Constrained-band equiripple FIR filter design.
%   fireqint                    - Equiripple FIR interpolation filter design.
%   firgr                       - Generalized Remez FIR filter design.
%   firhalfband                 - Equiripple halfband FIR filter design.
%   firlpnorm                   - Least P-norm optimal FIR filter design.
%   firnyquist                  - Equiripple Nyquist FIR filter design.
%   firpr2chfb                  - FIR perfect reconstruction 2 channel filter bank design.
%   ifir                        - Interpolated FIR filter design.
%   iircomb                     - IIR comb notching or peaking digital filter design.
%   iirgrpdelay                 - Allpass filter design given a group-delay.
%   iirlpnorm                   - Least P-norm optimal IIR filter design.
%   iirlpnormc                  - Constrained least P-norm IIR filter design.
%   iirnotch                    - Second-order IIR notch digital filter design.
%   iirpeak                     - Second-order IIR peaking (resonator) digital filter design.
%   fdesign/butter              - Design a Butterworth filter.
%   fdesign/cheby1              - Design a Chebyshev type I filter.
%   fdesign/cheby2              - Design a Chebyshev type II filter.
%   fdesign/designmethods       - Returns the designmethods currently available.
%   fdesign/ellip               - Design an elliptic filter.
%   fdesign/equiripple          - Design an equiripple filter.
%   fdesign/firls               - Design a least-squares filter.
%   fdesign/kaiserwin           - Design a filter using a Kaiser window.
%
% Filter response types.
%   fdesign                     - Family of filter design objects.
%   fdesign/bandpass            - Designs bandpass filters.
%   fdesign/bandstop            - Designs bandstop filters.
%   fdesign/decim               - Designs decimators.
%   fdesign/halfband            - Designs halfband filters.
%   fdesign/highpass            - Designs highpass filters.
%   fdesign/interp              - Designs interpolators.
%   fdesign/lowpass             - Designs lowpass filters.
%   fdesign/nyquist             - Designs nyquist filters.
%   fdesign/setspecs            - Set all of the specifications simultaneously.
%   fdesign/src                 - Designs sample-rate converters.
%
% Multirate Filters.
% ------------------
% Structures.
%   mfilt                       - Family of multirate filters.
%   mfilt/cicdecim           	- Cascaded integrator-comb decimator.
%   mfilt/cicdecimzerolat    	- Zero-latency cascaded integrator-comb decimator.
%   mfilt/cicinterp          	- Cascaded integrator-comb interpolator.
%   mfilt/cicinterpzerolat   	- Zero-latency cascaded integrator-comb interpolator.
%   mfilt/fftfirinterp       	- Overlap-add FIR polyphase interpolator.
%   mfilt/firdecim           	- Direct-form FIR polyphase decimator.
%   mfilt/firfracdecim       	- Direct-form FIR polyphase fractional decimator.
%   mfilt/firfracinterp      	- Direct-form FIR polyphase fractional interpolator.
%   mfilt/firinterp          	- Direct-form FIR polyphase interpolator.
%   mfilt/firsrc             	- Direct-form FIR polyphase sample-rate converter.
%   mfilt/firtdecim          	- Direct-form transposed FIR polyphase decimator .
%   mfilt/holdinterp         	- FIR hold interpolator.
%   mfilt/linearinterp       	- FIR linear interpolator.
%
% Analysis and simulation.
%   mfilt/block                 - Generate a Signal Processing Blockset block.
%   mfilt/coefficients          - Multirate filter coefficients.
%   mfilt/euclidfactors         - Integer factors based on Euclid's theorem.
%   mfilt/filter                - Execute ("run") multirate filter.
%   mfilt/filtmsb               - Most significant bit of a CIC filter.
%   mfilt/firtype               - Determine the type (1-4) of a linear phase FIR filter.
%   mfilt/freqz                 - Frequency response of a multirate filter.
%   mfilt/gain                  - Gain of a Cascaded Integrator-Comb (CIC) filter.
%   mfilt/grpdelay              - Group-delay of a multirate filter.
%   mfilt/impz                  - Impulse response of multirate filter.
%   mfilt/info                  - Multirate filter information.
%   mfilt/isfir                 - True for Finite Impulse Response (FIR) multirate filters.
%   mfilt/islinphase            - True for linear phase multirate filters.
%   mfilt/ismaxphase            - True for maximum-phase multirate filters.
%   mfilt/isminphase            - True for minimum-phase multirate filters.
%   mfilt/isreal                - True for multirate filters with real coefficients.
%   mfilt/isstable              - True if the multirate filter is stable.
%   mfilt/norm                  - Filter norm.
%   mfilt/nstates               - Number of states in multirate filter.
%   mfilt/order                 - Multirate filter order.
%   mfilt/phasedelay            - Phase delay of a multirate filter.
%   mfilt/phasez                - Phase response of a multirate filter.
%   mfilt/polyphase             - Polyphase matrix of multirate filter.
%   mfilt/reset                 - Reset multirate filter.
%   mfilt/stepz                 - Multirate filter step response.
%   mfilt/tf                    - Transfer function for multirate filter.
%   mfilt/zerophase             - Multirate filter zero-phase response.
%   mfilt/zpk                   - Multirate filter zero-pole-gain conversion.
%   mfilt/zplane                - Multirate filter Z-plane pole-zero plot.
%
% See also SIGNAL, FILTDESDEMOS.

%   Copyright 1999-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.44.4.6  $Date: 2004/04/01 16:08:56 $


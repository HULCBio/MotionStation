% Signal Processing Toolbox 
% Version 6.2 (R14) 05-May-2004 
%
% Table of Contents
% -----------------
% Discrete-time filter design, analysis, and implementation           
% Analog filter design, transformation, and discretization            
% Linear system transformations                                       
% Windows                                                             
% Transforms
% Cepstral analysis                                                          
% Statistical signal processing and spectral analysis.                
% Parametric modeling
% Linear prediction                                                  
% Multirate signal processing                                        
% Waveform generation                                         
% Specialized operations
% Graphical User Interfaces         
%
% Discrete-time filter design, analysis, and implementation           
% ---------------------------------------------------------
%
% FIR filter design.
%   cfirpm      - Complex and nonlinear phase equiripple FIR filter design.
%   fir1        - Window based FIR filter design - low, high, band, stop, multi.
%   fir2        - FIR arbitrary shape filter design using the frequency sampling method.
%   fircls      - Constrained Least Squares filter design - arbitrary response.
%   fircls1     - Constrained Least Squares FIR filter design - low and highpass.
%   firgauss    - FIR Gaussian digital filter design.
%   firls       - Optimal least-squares FIR filter design.
%   firpm       - Parks-McClellan optimal equiripple FIR filter design.
%   firpmord    - Parks-McClellan optimal equiripple FIR order estimator.
%   firrcos     - Raised cosine FIR filter design.
%   intfilt     - Interpolation FIR filter design.
%   kaiserord   - Kaiser window design based filter order estimation.
%   sgolay      - Savitzky-Golay FIR smoothing filter design.
%
% IIR digital filter design.
%   butter      - Butterworth filter design.
%   cheby1      - Chebyshev Type I filter design (passband ripple).
%   cheby2      - Chebyshev Type II filter design (stopband ripple).
%   ellip       - Elliptic filter design.
%   maxflat     - Generalized Butterworth lowpass filter design.
%   yulewalk    - Yule-Walker filter design.
%
% IIR filter order estimation.
%   buttord     - Butterworth filter order estimation.
%   cheb1ord    - Chebyshev Type I filter order estimation.
%   cheb2ord    - Chebyshev Type II filter order estimation.
%   ellipord    - Elliptic filter order estimation.
%
% Filter analysis.
%   abs         - Magnitude.
%   angle       - Phase angle.
%   filternorm  - Compute the 2-norm or inf-norm of a digital filter.
%   freqs       - Laplace transform frequency response.
%   freqspace   - Frequency spacing for frequency response.
%   freqz       - Z-transform frequency response.
%   fvtool      - Filter Visualization Tool.
%   grpdelay    - Group delay.
%   impz        - Discrete impulse response.
%   phasedelay  - Phase delay of a digital filter.
%   phasez      - Digital filter phase response (unwrapped).
%   zerophase   - Zero-phase response of a real filter.
%   zplane      - Discrete pole-zero plot.
%
% Filter implementation.
%   conv        - Convolution.
%   conv2       - 2-D convolution.
%   convmtx     - Convolution matrix.
%   deconv      - Deconvolution.
%   fftfilt     - Overlap-add filter implementation.
%   filter      - Filter implementation.
%   filter2     - Two-dimensional digital filtering.
%   filtfilt    - Zero-phase version of filter.
%   filtic      - Determine filter initial conditions.
%   latcfilt    - Lattice filter implementation.
%   medfilt1    - 1-Dimensional median filtering.
%   sgolayfilt  - Savitzky-Golay filter implementation.
%   sosfilt     - Second-order sections (biquad) filter implementation.
%   upfirdn     - Upsample, FIR filter, downsample.
%
% Discrete-time filter objects.
%   dfilt                 - Family of discrete-time filters.
%   dfilt/df1             - Direct-form I.
%   dfilt/df1sos          - Direct-form I, second-order sections.
%   dfilt/df1t            - Direct-form I transposed.
%   dfilt/df1tsos         - Direct-form I transposed, second-order sections.
%   dfilt/df2             - Direct-form II.
%   dfilt/df2sos          - Direct-form II, second-order sections.
%   dfilt/df2t            - Direct-form II transposed.
%   dfilt/df2tsos         - Direct-form II transposed, second-order sections.
%   dfilt/dffir           - Direct-form FIR.
%   dfilt/dffirt          - Direct-form FIR transposed.
%   dfilt/dfsymfir        - Direct-form symmetric FIR.
%   dfilt/dfasymfir       - Direct-form antisymmetric FIR.
%   dfilt/latticeallpass  - Lattice allpass.
%   dfilt/latticear       - Lattice autoregressive (AR).
%   dfilt/latticearma     - Lattice autoregressive moving-average (ARMA).
%   dfilt/latticemamax    - Lattice moving-average (MA) for maximum phase.
%   dfilt/latticemamin    - Lattice moving-average (MA) for minimum phase.
%   dfilt/scalar          - Scalar gain filter.
%   dfilt/statespace      - State-space.
%   dfilt/cascade         - Cascade (filters arranged in series).
%   dfilt/parallel        - Parallel (filters arranged in parallel).
%
% Discrete-time filter methods.
%   dfilt/addstage     - Add a stage to a cascade or parallel filter.
%   dfilt/cascade      - Cascade filter objects.
%   dfilt/coefficients - Filter coefficients.
%   dfilt/convert      - Convert structure of DFILT object.
%   dfilt/copy         - Copy discrete-time filter.
%   dfilt/fcfwrite     - Write a filter coefficient file.
%   dfilt/filter       - Execute ("run") discrete-time filter.
%   dfilt/firtype      - Determine the type (1-4) of a linear phase FIR filter.
%   dfilt/freqz        - Digital filter frequency response.
%   dfilt/grpdelay     - Group delay of a digital filter.
%   dfilt/impz         - Impulse response.
%   dfilt/impzlength   - Length of the impulse response for a digital filter.
%   dfilt/info         - Filter information.
%   dfilt/isallpass    - True for allpass filter.
%   dfilt/iscascade    - True for cascaded filter.
%   dfilt/isfir        - True for FIR filter.
%   dfilt/islinphase   - True for linear phase filter.
%   dfilt/ismaxphase   - True if maximum phase.
%   dfilt/isminphase   - True if minimum phase.
%   dfilt/isparallel   - True for filter with parallel sections.
%   dfilt/isreal       - True for filter with real coefficients.
%   dfilt/isscalar     - True if scalar filter.
%   dfilt/issos        - True if second-order section filter.
%   dfilt/isstable     - True if the filter is stable.
%   dfilt/nsections    - Number of sections in a discrete-filter.
%   dfilt/nstages      - Number of stages in a cascade or parallel filter.
%   dfilt/nstates      - Number of states in discrete-time filter.
%   dfilt/order        - Filter order.
%   dfilt/parallel     - Connect filters in parallel.
%   dfilt/phasez       - Phase response of a discrete-time filter.
%   dfilt/removestage  - Remove a stage in a cascade or parallel filter.
%   dfilt/reset        - Reset discrete-time filter.
%   dfilt/setstage     - Set a stage in a cascade or parallel filter.
%   dfilt/sos          - Convert to second-order-sections.
%   dfilt/ss           - Discrete-time filter to state-space conversion.
%   dfilt/stepz        - Step response.
%   dfilt/tf           - Convert to transfer function.
%   dfilt/zerophase    - Zero-phase response.
%   dfilt/zpk          - Discrete-time filter zero-pole-gain conversion.
%   dfilt/zplane       - Pole/Zero plot
%
% Filter States Object.
%   filtstates/dfiir - Direct-form IIR filter states.
%
% Filter States methods.
%   filtstates/double - Convert a to a double precision vector.
%   filtstates/single - Convert a to a single precision vector.
%
% Analog filter design, transformation, and discretization            
% --------------------------------------------------------
%
% Analog lowpass filter prototypes.
%   besselap    - Bessel filter prototype.
%   buttap      - Butterworth filter prototype.
%   cheb1ap     - Chebyshev Type I filter prototype (passband ripple).
%   cheb2ap     - Chebyshev Type II filter prototype (stopband ripple).
%   ellipap     - Elliptic filter prototype.
%
% Analog filter design.
%   besself     - Bessel analog filter design.
%   butter      - Butterworth filter design.
%   cheby1      - Chebyshev Type I filter design.
%   cheby2      - Chebyshev Type II filter design.
%   ellip       - Elliptic filter design.
%
% Analog filter transformation.
%   lp2bp       - Lowpass to bandpass analog filter transformation.
%   lp2bs       - Lowpass to bandstop analog filter transformation.
%   lp2hp       - Lowpass to highpass analog filter transformation.
%   lp2lp       - Lowpass to lowpass analog filter transformation.
%
% Filter discretization.
%   bilinear    - Bilinear transformation with optional prewarping.
%   impinvar    - Impulse invariance analog to digital conversion.
%
% Linear system transformations
% -----------------------------
%   latc2tf     - Lattice or lattice ladder to transfer function conversion.
%   polyscale   - Scale roots of polynomial.
%   polystab    - Polynomial stabilization.
%   residuez    - Z-transform partial fraction expansion.
%   sos2ss      - Second-order sections to state-space conversion.
%   sos2tf      - Second-order sections to transfer function conversion.
%   sos2zp      - Second-order sections to zero-pole conversion.
%   ss2sos      - State-space to second-order sections conversion.
%   ss2tf       - State-space to transfer function conversion.
%   ss2zp       - State-space to zero-pole conversion.
%   tf2latc     - Transfer function to lattice or lattice ladder conversion.
%   tf2sos      - Transfer Function to second-order sections conversion.
%   tf2ss       - Transfer function to state-space conversion.
%   tf2zpk      - Discrete-time transfer function to zero-pole conversion.
%   zp2sos      - Zero-pole to second-order sections conversion.
%   zp2ss       - Zero-pole to state-space conversion.
%   zp2tf       - Zero-pole to transfer function conversion.
%
% Windows
% -------
%   barthannwin    - Modified Bartlett-Hanning window. 
%   bartlett       - Bartlett window.
%   blackman       - Blackman window.
%   blackmanharris - Minimum 4-term Blackman-Harris window.
%   bohmanwin      - Bohman window.
%   chebwin        - Chebyshev window.
%   flattopwin     - Flat Top window.
%   gausswin       - Gaussian window.
%   hamming        - Hamming window.
%   hann           - Hann window.
%   kaiser         - Kaiser window.
%   nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
%   parzenwin      - Parzen (de la Valle-Poussin) window.
%   rectwin        - Rectangular window.
%   triang         - Triangular window.
%   tukeywin       - Tukey window.
%   wvtool         - Window Visualization Tool.
%   window         - Window function gateway.
%
% Window objects.
%   sigwin                - Family of windows.
%   sigwin/bartlett       - Bartlett window.
%   sigwin/barthannwin    - Modified Bartlett-Hanning window. 
%   sigwin/blackman       - Blackman window.
%   sigwin/blackmanharris - Minimum 4-term Blackman-Harris window.
%   sigwin/bohmanwin      - Bohman window.
%   sigwin/chebwin        - Chebyshev window.
%   sigwin/flattopwin     - Flat Top window.
%   sigwin/gausswin       - Gaussian window.
%   sigwin/hamming        - Hamming window.
%   sigwin/hann           - Hann window.
%   sigwin/kaiser         - Kaiser window.
%   sigwin/nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
%   sigwin/parzenwin      - Parzen (de la Valle-Poussin) window.
%   sigwin/rectwin        - Rectangular window.
%   sigwin/triang         - Triangular window.
%   sigwin/tukeywin       - Tukey window.
%
% Window object methods.
%   sigwin/generate - Generate a window vector.
%
% Transforms
% ----------
%   bitrevorder   - Permute input into bit-reversed order.
%   czt           - Chirp-z transform.
%   dct           - Discrete cosine transform.
%   dftmtx        - Discrete Fourier transform matrix.
%   digitrevorder - Permute input into digit-reversed order.
%   fft           - Fast Fourier transform.
%   fft2          - 2-D fast Fourier transform.
%   fftshift      - Swap vector halves.
%   goertzel      - Second-order Goertzel algorithm.
%   hilbert       - Discrete-time analytic signal via Hilbert transform.
%   idct          - Inverse discrete cosine transform.
%   ifft          - Inverse fast Fourier transform.
%   ifft2         - Inverse 2-D fast Fourier transform.
%
% Cepstral analysis
% -----------------
%   cceps       - Complex cepstrum.
%   icceps      - Inverse Complex cepstrum.
%   rceps       - Real cepstrum and minimum phase reconstruction.
%
% Statistical signal processing and spectral analysis
% ---------------------------------------------------
%   corrcoef    - Correlation coefficients.
%   corrmtx     - Autocorrelation matrix.
%   cov         - Covariance matrix.
%   cpsd        - Cross Power Spectral Density.
%   mscohere    - Magnitude squared coherence estimate.
%   pburg       - Power Spectral Density estimate via Burg's method.
%   pcov        - Power Spectral Density estimate via the Covariance method.
%   peig        - Power Spectral Density estimate via the Eigenvector method.
%   periodogram - Power Spectral Density estimate via the periodogram method.
%   pmcov       - Power Spectral Density estimate via the Modified Covariance method.
%   pmtm        - Power Spectral Density estimate via the Thomson multitaper method.
%   pmusic      - Power Spectral Density estimate via the MUSIC method.
%   pwelch      - Power Spectral Density estimate via Welch's method.
%   pyulear     - Power Spectral Density estimate via the Yule-Walker AR Method.
%   rooteig     - Sinusoid frequency and power estimation via the eigenvector algorithm.
%   rootmusic   - Sinusoid frequency and power estimation via the MUSIC algorithm.
%   tfestimate  - Transfer function estimate.
%   xcorr       - Cross-correlation function.
%   xcorr2      - 2-D cross-correlation.
%   xcov        - Covariance function.
%
% Spectral Analysis Objects.
%   spectrum             - Family of spectrum objects.
%   spectrum/burg        - Burg method.
%   spectrum/cov         - Covariance method.
%   spectrum/eigenvector - Eigenvector method.
%   spectrum/mcov        - Modified Covariance method.
%   spectrum/mtm         - Thomson multitaper method (MTM).
%   spectrum/music       - Multiple Signal Cassification (MUSIC) method.
%   spectrum/periodogram - Periodogram method.
%   spectrum/welch       - Welch method.
%   spectrum/yulear      - Yule-Walker AR Method.
%
% Spectral Analysis Object Methods
%   spectrum/msspectrum     - Mean-square Spectrum estimate (for Welch and 
%                             Periodogram).
%   spectrum/powerest       - Computes the powers and frequencies of
%                             sinusoids (for MUSIC and eigenvector objects).
%   spectrum/psd            - Power Spectral Density estimate.
%   spectrum/pseudospectrum - Pseudospectrum estimate (for MUSIC and 
%                             eigenvector).
%
% DSP Data Objects.
%   dspdata                 - Family of DSP data objecs.
%   dspdata/msspectrum      - Mean-square spectrum data object.
%   dspdata/psd             - Power Spectral Density (PSD) data object.
%   dspdata/pseudospectrum  - Pseudospectrum data object.
%
% DSP Data Object Methods.
%   dspdata/avgpower     - Average power of a PSD data object.
%   dspdata/centerdc     - Shift the DC component to center of spectrum. 
%   dspdata/halfrange    - Pseudospectrum calculated over half the Nyquist
%                          interval.
%   dspdata/onesided     - Spectrum calculated over half the Nyquist
%                          interval, but contains the full power.
%   dspdata/normalizefreq- Normalize frequency specifications.
%   dspdata/plot         - Plot the data object.
%   dspdata/twosided     - Spectrum calculated over the whole Nyquist
%                          interval.
%   dspdata/wholerange   - Pseudospectrum calculated over the whole Nyquist
%                          interval.
%
% Parametric modeling
% -------------------
%   arburg      - AR parametric modeling via Burg's method.
%   arcov       - AR parametric modeling via covariance method.
%   armcov      - AR parametric modeling via modified covariance method.
%   aryule      - AR parametric modeling via the Yule-Walker method.
%   ident       - See the System Identification Toolbox.
%   invfreqs    - Analog filter fit to frequency response.
%   invfreqz    - Discrete filter fit to frequency response.
%   prony       - Prony's discrete filter fit to time response.
%   stmcb       - Steiglitz-McBride iteration for ARMA modeling.
%
% Linear prediction
% -----------------
%   ac2poly     - Autocorrelation sequence to prediction polynomial conversion.
%   ac2rc       - Autocorrelation sequence to reflection coefficients conversion. 
%   is2rc       - Inverse sine parameters to reflection coefficients conversion.
%   lar2rc      - Log area ratios to reflection coefficients conversion.
%   levinson    - Levinson-Durbin recursion.
%   lpc         - Linear Predictive Coefficients using autocorrelation method.
%   lsf2poly    - Line spectral frequencies to prediction polynomial conversion.
%   poly2ac     - Prediction polynomial to autocorrelation sequence conversion. 
%   poly2lsf    - Prediction polynomial to line spectral frequencies conversion.
%   poly2rc     - Prediction polynomial to reflection coefficients conversion.
%   rc2ac       - Reflection coefficients to autocorrelation sequence conversion.
%   rc2is       - Reflection coefficients to inverse sine parameters conversion.
%   rc2lar      - Reflection coefficients to log area ratios conversion.
%   rc2poly     - Reflection coefficients to prediction polynomial conversion.
%   rlevinson   - Reverse Levinson-Durbin recursion.
%   schurrc     - Schur algorithm.
%
% Multirate signal processing
% ---------------------------
%   decimate    - Resample data at a lower sample rate.
%   downsample  - Downsample input signal.
%   interp      - Resample data at a higher sample rate.
%   interp1     - General 1-D interpolation. (MATLAB Toolbox)
%   resample    - Resample sequence with new sampling rate.
%   spline      - Cubic spline interpolation.
%   upfirdn     - Up sample, FIR filter, down sample.
%   upsample    - Upsample input signal.
%
% Waveform generation
% -------------------
%   chirp       - Swept-frequency cosine generator.
%   diric       - Dirichlet (periodic sinc) function.
%   gauspuls    - Gaussian RF pulse generator.
%   gmonopuls   - Gaussian monopulse generator.
%   pulstran    - Pulse train generator.
%   rectpuls    - Sampled aperiodic rectangle generator.
%   sawtooth    - Sawtooth function.
%   sinc        - Sinc or sin(pi*x)/(pi*x) function
%   square      - Square wave function.
%   tripuls     - Sampled aperiodic triangle generator.
%   vco         - Voltage controlled oscillator.
%
% Specialized operations
% ----------------------
%   buffer      - Buffer a signal vector into a matrix of data frames.
%   cell2sos    - Convert cell array to second-order-section matrix.
%   cplxpair    - Order vector into complex conjugate pairs.
%   demod       - Demodulation for communications simulation.
%   dpss        - Discrete prolate spheroidal sequences (Slepian sequences). 
%   dpssclear   - Remove discrete prolate spheroidal sequences from database.
%   dpssdir     - Discrete prolate spheroidal sequence database directory.
%   dpssload    - Load discrete prolate spheroidal sequences from database.
%   dpsssave    - Save discrete prolate spheroidal sequences in database.
%   eqtflength  - Equalize the length of a discrete-time transfer function.
%   modulate    - Modulation for communications simulation.
%   seqperiod   - Find minimum-length repeating sequence in a vector.
%   sos2cell    - Convert second-order-section matrix to cell array.
%   specgram    - Spectrogram, for speech signals.
%   stem        - Plot discrete data sequence.
%   strips      - Strip plot.
%   udecode     - Uniform decoding of the input.
%   uencode     - Uniform quantization and encoding of the input into N-bits.
%
% Graphical User Interfaces
% -------------------------
%   fdatool     - Filter Design and Analysis Tool.
%   fvtool      - Filter Visualization Tool.
%   sptool      - Signal Processing Tool.
%   wintool     - Window Design and Analysis Tool.
%   wvtool      - Window Visualization Tool.
%
% See also SIGDEMOS, AUDIO, and, in the Filter Design Toolbox, FILTERDESIGN.

%   Copyright 1988-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.62.4.5 $Date: 2004/04/01 16:20:24 $

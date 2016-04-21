% Control System Toolbox
% Version 6.0 (R14) 05-May-2004
%
% General.
%   ctrlpref    - Set Control System Toolbox preferences.
%   ltimodels   - Detailed help on the various types of LTI models.
%   ltiprops    - Detailed help on available LTI model properties.
%
% Creating linear models.
%   tf          - Create transfer function models.
%   zpk         - Create zero/pole/gain models.
%   ss, dss     - Create state-space models.
%   frd         - Create a frequency response data models.
%   filt        - Specify a digital filter.
%   lti/set     - Set/modify properties of LTI models.
%   
% Data extraction.
%   tfdata      - Extract numerator(s) and denominator(s).
%   zpkdata     - Extract zero/pole/gain data.
%   ssdata      - Extract state-space matrices.
%   dssdata     - Descriptor version of SSDATA.
%   frdata      - Extract frequency response data.
%   lti/get     - Access values of LTI model properties.
%
% Conversions.
%   tf          - Conversion to transfer function.
%   zpk         - Conversion to zero/pole/gain.
%   ss          - Conversion to state space.
%   frd         - Conversion to frequency data.
%   chgunits    - Change units of FRD model frequency points.
%   c2d         - Continuous to discrete conversion.
%   d2c         - Discrete to continuous conversion.
%   d2d         - Resample discrete-time model.
%
% System interconnections.
%   append      - Group LTI systems by appending inputs and outputs.
%   parallel    - Generalized parallel connection (see also overloaded +).
%   series      - Generalized series connection (see also overloaded *).
%   feedback    - Feedback connection of two systems.
%   lft         - Generalized feedback interconnection (Redheffer star product).
%   connect     - Derive state-space model from block diagram description.
%
% System gain and dynamics.
%   dcgain      - D.C. (low frequency) gain.
%   bandwidth   - System bandwidth.
%   lti/norm    - Norms of LTI systems.
%   pole, eig   - System poles.
%   zero        - System (transmission) zeros.
%   pzmap       - Pole-zero map.
%   iopzmap     - Input/output pole-zero map.
%   damp        - Natural frequency and damping of system poles.
%   esort       - Sort continuous poles by real part.
%   dsort       - Sort discrete poles by magnitude.
%   stabsep     - Stable/unstable decomposition.
%   modsep      - Region-based modal decomposition.
%
% Time-domain analysis.
%   ltiview     - Response analysis GUI (LTI Viewer).
%   step        - Step response.
%   impulse     - Impulse response.
%   initial     - Response of state-space system with given initial state.
%   lsim        - Response to arbitrary inputs.
%   gensig      - Generate input signal for LSIM.
%   covar       - Covariance of response to white noise.
%
% Frequency-domain analysis.
%   ltiview     - Response analysis GUI (LTI Viewer).
%   bode        - Bode diagrams of the frequency response.
%   bodemag     - Bode magnitude diagram only.
%   sigma       - Singular value frequency plot.
%   nyquist     - Nyquist plot.
%   nichols     - Nichols plot.
%   margin      - Gain and phase margins.
%   allmargin   - All crossover frequencies and related gain/phase margins.
%   freqresp    - Frequency response over a frequency grid.
%   evalfr      - Evaluate frequency response at given frequency.
%   frd/interp  - Interpolates frequency response data.
%
% Classical design.
%   sisotool    - SISO design GUI (root locus and loop shaping techniques).
%   rlocus      - Evans root locus.
%
% Pole placement.
%   place       - MIMO pole placement.
%   acker       - SISO pole placement.
%   estim       - Form estimator given estimator gain.
%   reg         - Form regulator given state-feedback and estimator gains.
%
% LQR/LQG design.
%   lqr, dlqr   - Linear-quadratic (LQ) state-feedback regulator.
%   lqry        - LQ regulator with output weighting.
%   lqrd        - Discrete LQ regulator for continuous plant.
%   kalman      - Kalman estimator.
%   kalmd       - Discrete Kalman estimator for continuous plant.
%   lqgreg      - Form LQG regulator given LQ gain and Kalman estimator.
%   augstate    - Augment output by appending states.
%
% State-space models.
%   rss, drss   - Random stable state-space models.
%   ss2ss       - State coordinate transformation.
%   canon       - State-space canonical forms.
%   ctrb        - Controllability matrix.
%   obsv        - Observability matrix.
%   gram        - Controllability and observability gramians.
%   ssbal       - Diagonal balancing of state-space realizations.  
%   balreal     - Gramian-based input/output balancing.
%   modred      - Model state reduction.
%   minreal     - Minimal realization and pole/zero cancellation.
%   sminreal    - Structurally minimal realization.
%
% Time delays.
%   hasdelay    - True for models with time delays.
%   totaldelay  - Total delay between each input/output pair.
%   delay2z     - Replace delays by poles at z=0 or FRD phase shift.
%   pade        - Pade approximation of time delays.
%
% Model dimensions and characteristics.
%   class       - Model type ('tf', 'zpk', 'ss', or 'frd').
%   size        - Model sizes and order.
%   lti/ndims   - Number of dimensions.
%   lti/isempty - True for empty models.
%   isct        - True for continuous-time models.
%   isdt        - True for discrete-time models.
%   isproper    - True for proper models.
%   issiso      - True for single-input/single-output models.
%   reshape     - Reshape array of linear models.
%
% Overloaded arithmetic operations.
%   + and -     - Add and subtract systems (parallel connection).
%   *           - Multiply systems (series connection).
%   \           - Left divide -- sys1\sys2 means inv(sys1)*sys2.
%   /           - Right divide -- sys1/sys2 means sys1*inv(sys2).
%   ^           - Powers of a given system.
%   '           - Pertransposition.
%   .'          - Transposition of input/output map.
%   [..]        - Concatenate models along inputs or outputs.
%   stack       - Stack models/arrays along some array dimension.
%   lti/inv     - Inverse of an LTI system.
%   conj        - Complex conjugation of model coefficients.
%
% Matrix equation solvers.
%   lyap, dlyap         - Solve Lyapunov equations.
%   lyapchol, dlyapchol - Square-root Lyapunov solvers.
%   care, dare          - Solve algebraic Riccati equations.
%   gcare, gdare        - Generalized Riccati solvers.
%   bdschur             - Block diagonalization of a square matrix.
%
% Demonstrations.
%   Type "demo" or "help ctrldemos" for a list of available demos.


%   Copyright 1986-2004 The MathWorks, Inc.







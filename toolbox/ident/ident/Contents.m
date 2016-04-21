% System Identification Toolbox
% Version 6.0.1 (R14) 05-May-2004
%
% Help
%   idhelp     - A micromanual. Type "help idhelp" to get started.
%   idprops    - List of properties of toolbox objects.
% Demos
%   iddemo     - Demonstrates the use of the toolbox.
%
% Graphical User Interface
%   ident      - A comprehensive estimation and analysis environment.
%   midprefs   - Specify a directory for start-up information.
%
% Simulation and prediction.
%   predict    - M-step ahead prediction.
%   pe         - Compute prediction errors.
%   sim        - Simulate a given system.
%   slident    - Simulink library for using Idmodels and Iddata
%
% Data manipulation.
%   advice     - Advice about a data set.
%   detrend    - Remove trends from data sets.
%   delayest   - Estimate the time delay (dead time) from data.
%   feedback   - Investigate feedback effects in data sets.
%   fft/ifft   - Transform iddata objects between time and frequency
%                domains.
%   getexp     - Retrieve separate experiment(s) from multiple-experiment
%                iddata objects
%   iddata     - Construct a data object.
%   idfilt     - Filter data through Butterworth filters.
%   idinput    - Generates input signals for identification.
%   isreal     - Check if a data set contains real data.
%   merge      - Merge several experiments.
%   misdata    - Estimate and replace missing input and output data.
%   nkshift    - Shift data sequences.
%   plot       - Plot iddata objects.
%   resample   - Resamples data by decimation and interpolation.
%
% Nonparametric estimation.
%   covf       - Covariance function estimate for a data matrix.
%   cra        - Correlation analysis.
%   etfe       - Empirical Transfer Function Estimate and Periodogram.
%   impulse    - Direct estimation of impulse response.
%   spa        - Spectral analysis.
%   spafdr     - Spectral analysis with frequency dependent resolution.
%   step       - Direct estimation of step response.
%
% Parameter estimation.
%   ar         - AR-models of signals using various approaches.
%   armax      - Prediction error estimate of an ARMAX model.
%   arx        - LS-estimate of ARX-models.
%   bj         - Prediction error estimate of a Box-Jenkins model.
%   ivar       - IV-estimates for the AR-part of a scalar time series.
%   iv4        - Approximately optimal IV-estimates for ARX-models.
%   n4sid      - State-space model estimation using a sub-space method.
%   oe         - Prediction error estimate of an output-error model.
%   pem        - Prediction error estimate of a general linear model.
%
% Model structure creation.
%   idarx      - Construct a multivariable ARX model object.
%   idfrd      - Create an identified frequency response data object.
%   idgrey     - Construct a user-parameterized model object.
%   idproc     - Construct simple continuous time process models.
%   idpoly     - Construct a model object from given polynomials.
%   idss       - Construct a state space model object.
%
% Model conversions.
%   arxdata    - Convert a model to its ARX-matrices (if applicable).
%   polydata   - Polynomials associated with a given model.
%   ssdata     - IDMODEL conversion to state-space.
%   tfdata     - IDMODEL conversion to transfer function.
%   zpkdata      - Zeros, poles, static gains and their standard deviations.
%   idfrd      - Model's frequency function, along with its covariance.
%   idmodred   - Reduce a model to lower order.
%   c2d, d2c   - Continuous/discrete transformations.
%   ss, tf, zpk, frd - Transformations to the LTI-objects of the CSTB.
%   Most CSTB conversion routines also apply to the model objects
%   of the Identification Toolbox.
%
% Model presentation.
%   advice     - Advice about an estimated model.
%   bode       - Bode diagram of a transfer function or spectrum 
%                (with uncertainty regions).
%   ffplot     - Frequency functions (with uncertainty regions).
%   plot       - Input - output data for data objects. 
%   present    - Display the model with uncertainties.
%   pzmap      - Zeros and poles (with uncertainty regions).
%   nyquist    - Nyquist diagram of a transfer function (with
%                uncertainty regions).
%   view       - The LTI viewer (with the Control Systems Toolbox
%                for model objects).
%
% Model validation.
%   compare    - Compare the simulated/predicted output with the measured output.
%   pe         - Prediction errors.
%   predict    - M-step ahead prediction.
%   resid      - Compute and test the residuals associated with a model.
%   sim        - Simulate a given system (with uncertainty).
%   simsd	   - Illustrate model uncertainty by Monte Carlo simualtions.
%
% Model structure selection.
%   aic, fpe   - Compute Akaike's information and final prediction criteria
%   arxstruc   - Loss functions for families of ARX-models.
%   selstruc   - Select model structures according to various criteria.
%   setstruc   - Set the structure matricies for idss objects.
%   struc      - Typical structure matrices for ARXSTRUC.

% Recursive parameter estimation.
%   rarx       - Compute estimates recursively for an ARX model.
%   rarmax     - Compute estimates recursively for an ARMAX model.
%   rbj        - Compute estimates recursively for a BOX-JENKINS model.
%   roe        - Compute estimates recursively for an output error model.
%   rpem       - Compute estimates recursively for a general model.
%   rplr       - Compute estimates recursively for a general model.
%   segment    - Segment data and track abruptly changing systems.

% Bookkeeping and display facilities
%   display    - Display of basic properties.
%   present    - More detailed display.
%   get/set    - Getting and setting the object properties.
%   setpname   - Set default parameter names.
%   timestamp  - Find out when the object was created.
%   FPE, AIC   - Direct access to various model validation criteria.

%   Copyright 1986-2004 The MathWorks, Inc.



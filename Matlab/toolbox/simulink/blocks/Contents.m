% Simulink block library.
%
% Block libraries.
%   simulink        - Open main block library.
%   simulink_extras - Simulink Extras block library.
%
% Example S-function models and blocks.
%   simo            - simo model, block diagram form.
%   simom           - simo model, M-file form.
%   simom2          - simo model, M-file form #2.
%   simosys         - simo model, S-function block form.
%   vdpm            - Van der Pol model, M-file form.
%   mixed           - Mixed continuous/discrete model, block diagram form.
%   mixedm          - Mixed continuous/discrete model, M-file form.
%   limintm         - Limited integrator block, M-file form.
%   vlimintm        - Vectorized limited integrator, M-file form.
%   vdlmintm        - Discrete-time vectorized limited integrator, M-file.
%   sfuntmpl        - M-file S-function template.
%   csfunc          - Continuous-time model, M-file form.
%   dsfunc          - Discrete-time model, M-file form.
%   vsfunc          - Variable sample-time model, M-file form.
%   sfuncont        - M-file S-function template, continuous-time model.
%   sfundsc1        - M-file S-function template, discrete real-time model.
%   sfundsc2        - M-file S-function template, discrete sampled model.
%   timestwo        - M-file S-function example. 
%
% The MATLABROOT/simulink directory contains the source code for examples
% of C, Fortran, and Ada implementations of the above blocks.


% The functions listed below this point are utility routines that are
% used by the above functions to construct the Extras subsystem in the
% block library. They are NOT ordinarily called directly by the user.
%
% Extras library S-functions (M-file form).
%   sftab2chk       - Verify sftable2 inputs.
%   sftable2        - 2-dimensional table lookup.
%   sfuncorr        - Auto - and cross-correlation.
%   sfunmem         - One integration-step memory block (obsolete).
%   sfunpsd         - Spectral analysis using ffts.
%   sfuntf          - Transfer function analysis using ffts.
%   sfunxy          - X-Y scope using graph window.
%   sfunxys         - Sampling X-Y scope.
%   sfuny           - Scope using graph window.
%   sfunyst         - Storage scope using graph window.
%   slblocks        - Defines the Extras block library.
%
% Miscellaneous.
%   filtm           - Analog filter design for extrfilt.
%   getxo           - Compute the initial states for a state space.
%   manswitch       - Interface for Manual Switch block.
%   slideg          - Sliding Gain block dialog box manager.
%   sfun_bitopcbk   - Dynamic dialog function for bitwise operator block.

% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.49 $

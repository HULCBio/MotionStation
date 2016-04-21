function varargout=sigwin(varargin)
%SIGWIN  Window object.
%   HWIN = SIGWIN.WINDOW(input1,...) returns a window object, HWIN,
%   of type WINDOW. You must specify a window type with SIGWIN. Each
%   window takes one or more inputs. When you specify SIGWIN.WINDOW
%   with no inputs, a window with default property values is created (the
%   defaults depend on the particular window). The properties may
%   be changed with SET(H,PARAMNAME,PARAMVAL).
%
%   SIGWIN.WINDOW can be one of the following:
%
%   sigwin.bartlett       - Bartlett window.
%   sigwin.barthannwin    - Modified Bartlett-Hanning window. 
%   sigwin.blackman       - Blackman window.
%   sigwin.blackmanharris - Minimum 4-term Blackman-Harris window.
%   sigwin.bohmanwin      - Bohman window.
%   sigwin.chebwin        - Chebyshev window.
%   sigwin.flattopwin     - Flat Top window.
%   sigwin.gausswin       - Gaussian window.
%   sigwin.hamming        - Hamming window.
%   sigwin.hann           - Hann window.
%   sigwin.kaiser         - Kaiser window.
%   sigwin.nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
%   sigwin.parzenwin      - Parzen (de la Valle-Poussin) window.
%   sigwin.rectwin        - Rectangular window.
%   sigwin.triang         - Triangular window.
%   sigwin.tukeywin       - Tukey window.
%
% Window object methods.
%   sigwin/generate - Generate a window vector.
%
%   % EXAMPLE: Construct a 128-point chebyshev window
%   Hwin = sigwin.chebwin(128,100);
%   w = generate(Hwin) % Returns the values representing the window 
%   wvtool(Hwin)       % Window Visualization Tool
%
%   For more information, type
%       doc sigwin
%   at the MATLAB command line.
%

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/11/21 15:38:00 $

msg = sprintf(['Use SIGWIN.WINDOW to create a window.\n',...
               'For example,\n   Hwin = sigwin.bartlett']);
error(msg)
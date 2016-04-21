function h = bartlett(varargin)
%BARTLETT Bartlett window.
%   H = SIGWIN.BARTLETT(N) returns a N-point Bartlett window object H.
%
%   EXAMPLE:
%     N = 64; 
%     h = sigwin.bartlett(N); 
%     w = generate(h);
%     stem(w); title('64-point Bartlettwindow');
%
%   See also SIGWIN/BARTHANNWIN, SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN,
%            SIGWIN/FLATTOPWIN, SIGWIN/NUTTALLWIN, SIGWIN/PARZENWIN, 
%            SIGWIN/RECTWIN, SIGWIN/TRIANG.
             
%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:07:21 $

h = sigwin.bartlett(varargin{:});

% [EOF]

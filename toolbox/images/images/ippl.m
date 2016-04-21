function varargout = ippl
%IPPL Check for presence of the Intel Performance Primitives Library (IPPL).
%   The IPPL provides a collection of basic functions used in signal and
%   image processing. It takes advantage of the parallelism of the
%   Single-Instruction, Multiple-Data (SIMD) instructions that comprise
%   the core of the MMX technology and Streaming SIMD Extensions. These
%   instructions are available only on the Intel Architecture processors.
%   IPPL is used by some of the Image Processing Toolbox functions to
%   accelerate their execution time.
%
%   A = IPPL returns true if IPPL is available and false otherwise.
%
%   [A B] = IPPL returns an additional column cell array B. Each row
%   of B contains a string describing a specific IPPL module.
%
%   When IPPL is available, the following Image Processing Toolbox functions
%   take advantage of it: IMABSDIFF, IMADD, IMSUBTRACT, IMDIVIDE, IMMULTIPLY,
%   IMLINCOMB and IMFILTER. Functions in the Image Processing Toolbox that use
%   these routines also benefit from the use of IPPL.
%
%   Notes
%   -----
%   - IPPL is utilized only for some data types and only under specific
%     conditions. See the help sections of the functions listed above for
%     detailed information on when IPPL is activated.
%     
%   - IPPL function is likely to change in the near future.
%
%   See also IMABSDIFF, IMADD, IMSUBTRACT, IMDIVIDE, IMMULTIPLY,
%            IMLINCOMB, IMFILTER.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2003/08/23 05:52:50 $

checknargin(0,0,nargin,mfilename);

if (nargout == 0 || nargout == 1)
  varargout{1} = ipplmex;
elseif nargout == 2
  [varargout{1} varargout{2}] = ipplmex;
else
  eid = sprintf('Images:%s:invalidNumOutputs',mfilename);
  msg = 'IPPL returns either one or two output arguments.';
  error(eid,'%s',msg);
end


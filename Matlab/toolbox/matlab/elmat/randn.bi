function [varargout] = randn(varargin)
%RANDN  Normally distributed random numbers.
%   RANDN(N) is an N-by-N matrix with random entries, chosen from
%   a normal distribution with mean zero, variance one and standard
%   deviation one.
%   RANDN(M,N) and RANDN([M,N]) are M-by-N matrices with random entries.
%   RANDN(M,N,P,...) or RANDN([M,N,P...]) generate random arrays.
%   RANDN with no arguments is a scalar whose value changes each time it
%   is referenced.  RANDN(SIZE(A)) is the same size as A.  
%
%   RANDN produces pseudo-random numbers.  The sequence of numbers
%   generated is determined by the state of the generator.  Since MATLAB
%   resets the state at start-up, the sequence of numbers generated will
%   be the same unless the state is changed.
%
%   S = RANDN('state') is a 2-element vector containing the current state
%   of the normal generator.  RANDN('state',S) resets the state to S.
%   RANDN('state',0) resets the generator to its initial state.
%   RANDN('state',J), for integer J, resets the generator to its J-th state.
%   RANDN('state',sum(100*clock)) resets it to a different state each time.
%
%   MATLAB Version 4.x used random number generators with a single seed.
%   RANDN('seed',0) and RANDN('seed',J) cause the MATLAB 4 generator
%   to be used.
%   RANDN('seed') returns the current seed of the MATLAB 4 normal generator.
%   RANDN('state',J) and RANDN('state',S) cause the MATLAB 5 generator
%   to be used. 
%
%   See also RAND, SPRAND, SPRANDN, RANDPERM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/16 22:06:27 $
%   Built-in function.

if nargout == 0
  builtin('randn', varargin{:});
else
  [varargout{1:nargout}] = builtin('randn', varargin{:});
end

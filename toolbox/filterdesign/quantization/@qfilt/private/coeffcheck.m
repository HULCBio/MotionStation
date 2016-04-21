function [msg,c] = coeffcheck(Hq,c,msg,depth)
%COEFFCHECK Check for valid coefficients
%   MSG = COEFFCHECK(Hq) will return a message if the coefficients of QFILT
%   object Hq do not match the FilterStructure property of Hq.  If they do
%   match, the MSG is an empty string.  This makes it handy to call in ERROR or
%   WARNING.
%
%   This function calls itself recursively, thus allowing it to check for
%   nested cell arrays of coefficients.

%   Thomas A. Bryan, 12 March 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:25:53 $

if nargin == 1
  c = Hq.referencecoefficients;
  msg = '';
  depth = 0;
end
if ~isempty(msg)
  return
end
depth = depth+1;
if depth>2
  msg = 'Coefficient cell arrays cannot be nested more than two deep.';
  return
end
if ~iscell(c) 
  msg = 'Coefficients must be contained in a cell array.';
  return
end
if isempty(c)
  msg = 'Coefficient cell array must be nonempty.';
  return
end
if ~isrow(c)
  msg = 'Coefficient cell arrays must be 1-dimensional.';
  return
end
if iscell(c{1})
  % There is more than one section
  for i=1:length(c)
    [msg,c{i}] = coeffcheck(Hq,c{i},msg,depth);
  end
else
  % I'm at the section level
  n = length(c);
  for i=1:n
    if ~isnumeric(c{i})
      msg = 'Coefficients must be numeric.';
      return
    end
  end
  filterstructure = get(Hq,'FilterStructure');
  switch lower(filterstructure)
    case {'df1','df1t','df2','df2t'}
      if n~=2 | ~privisvector(c{1}) | ~privisvector(c{2})
        msg = [' must be a cell array of two vectors {numerator, denominator} or\r' ...
              'a cascade of such cells {{num1,den1},{num2,den2},...}.'];
      else
        % Check for empties.  Default num=0, den=1.
        if isempty(c{1}), c{1} = 0; end  % b=[] --> b=0
        if isempty(c{2}), c{2} = 1; end  % a=[] --> a=1
      end
    case {'fir','firt','antisymmetricfir','symmetricfir'}
      if n~=1 | ~privisvector(c{1})
        msg = [' must be a cell array of one vector {numerator} or\r',...
              'a cascade of such cells  {{num1},{num2},...}.'];
      else
        % Check for empties.  Default num=0.
        if isempty(c{1}), c{1} = 0; end  % b=[] --> b=0
      end
    case {'latticear','latcallpass','latticeallpass','latticema','latcmax','latticemaxphase'}
      if n~=1 | ~privisvector(c{1})
        msg = [' must be a cell array of one vector {lattice} or\r',...
              'a cascade of such cells {{lattice1},{lattice2},...}.'];
      else
        % Check for empties.  Default k=0;
        if isempty(c{1}), c{1} = 0; end   % k=[] --> k=0
      end
    case {'latticearma'}
      if n~=2 | ~privisvector(c{1}) | ~privisvector(c{2})
        msg = [' must be a cell array of two vectors {lattice, ladder} or\r',...
              'a cascade  of such cells  ',...
              '{{lattice1,ladder1},{lattice2,ladder2},...}.'];
      else
        % Check for empties.  Default k=0, v=1.
        if isempty(c{1}), c{1} = 0; end  % k=[] --> k=0
        if isempty(c{2}), c{2} = 1; end  % v=[] --> v=1
      end
    case {'latticeca', 'latticecapc'}
      if n~=3 | ~privisvector(c{1}) | ~privisvector(c{2}) | ~isscalar(c{3})
        msg = [' must be a cell array of two vectors and one scalar ',...
              '{lattice1, lattice2, beta} or\r',...
              'a cascade  of such cells  ',...
              '{{lattice1_1,lattice2_1,beta1},{lattice1_2,lattice2_2,beta2},...}.'];
      else
        % Check for empties.  Default k1=0, k2=0, beta=1.
        if isempty(c{1}), c{1} = 0; end  % k1=[] --> k1=0
        if isempty(c{2}), c{2} = 0; end  % k2=[] --> k2=0
        if isempty(c{3}), c{3} = 1; end  % beta=[] --> beta=1
      end
    case {'statespace'}
      m = size(c{1},2);
      if n~=4 | size(c{1},1)~=m | ...
            ~iscolumn(c{2}) | length(c{2})~=m | ...
            ~isrow(c{3}) | length(c{3})~=m | ...
            length(c{4})>1  % length(D)<=1 implies SISO
        msg = [' must be a cell array of four matrices \r{A,B,C,D}'...
              ' of size nxn, nx1, 1xn, 1x1, respectively, or' ...
              '\ra cascade of such cells {{A1,B1,C1,D1},{A2,B2,C2,D2},...}.'];
      else
        % Check for empties.  Default A=[], B=[], C=[], D=0.
        if isempty(c{4}), c{4} = 0; end  % D=[] --> D=0
      end 
  end
  if ~isempty(msg)
    msg = sprintf(['Coefficients of ',filterstructure,msg]);
    return
  end  
end

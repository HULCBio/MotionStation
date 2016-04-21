function Hq = convert(Hq,newstruct)
%CONVERT  Convert filter structure of quantized filter.
%   CONVERT(Hq,NEWSTRUCT) returns a QFILT object whose filter structure has been
%   transformed to the filter structure in string NEWSTRUCT.  NEWSTRUCT may
%   be any valid QFILT filter structure.  An error is generated if the
%   conversion is not possible.
%
%   Example:
%     [b,a]=ellip(5,3,40,.7);
%     Hq = qfilt('df2t',{b,a});
%     Hq2 = convert(Hq,'statespace')
%
%   See also QFILT.

%   Thomas A. Bryan, 31 August 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/05/11 17:01:10 $

if ~ischar(newstruct)
  error('The new filter structure input must be a character string.')
end
newstruct = lower(newstruct);
oldstruct = lower(filterstructure(Hq));

% If the new filter structure is the same as the old filter structure, no
% change is needed.
if strcmpi(oldstruct,newstruct)
  return
end

oldcoeffs = referencecoefficients(Hq);

if isnumeric(oldcoeffs{1})
  oldcoeffs = {oldcoeffs};
end
newcoeffs = cell(size(oldcoeffs));

for k=1:length(oldcoeffs)
  newcoeffs{k} = convertsection(oldstruct,newstruct,oldcoeffs{k});
end

if nsections(Hq)==1,
    newcoeffs = newcoeffs{1};
end

Hq = set(Hq,newstruct,newcoeffs);

function newsection = convertsection(oldstruct,newstruct,oldsection)

% Convert the section to transfer function form.
% This function does not change the sectional scaling, and so we input
% scalevalues = 1 at this point.
[num,den] = sec2tf(oldstruct,oldsection,1);

% The common denominator between dissimilar filter structures is the transfer
% function. 
newsection = tf2other(newstruct,num,den);

function newsection = tf2other(newstruct,num,den)
%DF2OTHER  Direct form to other structure
switch newstruct
  case {'df1','df1t','df2','df2t'}
    newsection = {num,den};
  case {'fir','firt','symmetricfir','antisymmetricfir'}
    if ~isscalar(den)
      error('FIR filter structure selected, but design is not FIR.')
    end
    num = num/den;
    newsection = {num};
  case {'latticear','latcallpass','latticeallpass'}
    if ~isscalar(num)
      error(['Lattice AR filter structure selected, but design is not' ...
            ' all-pole.'])
    end
    den = den/num;
    k = tf2latc(1,den);
    newsection = {k};
  case {'latticearma'}
    [k,v] = tf2latc(num,den);
    newsection = {k,v};
  case {'latticeca','latticecapc'}
    [k1,k2,beta] = tf2cl(num,den);
    newsection = {k1,k2,beta};
  case {'latticema','latcmax','latticemaxphase'}
    if ~isscalar(den)
      error('FIR filter structure selected, but design is not FIR.')
    end
    num = num/den;
    k = tf2latc(num);
    newsection = {k};
  case {'statespace'}
    % Equalize the lengths of numerator and denominator before
    % conversion. 
    [num,den] = eqtflength(num,den);
    [A,B,C,D] = tf2ss(num,den);
    newsection = {A,B,C,D};
  otherwise
    error([newstruct,' is not a recognized filter structure.'])
end


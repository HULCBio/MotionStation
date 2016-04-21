function varargout = qfilt2tf(Hq,coeftype)
%QFILT2TF  Quantized filter to transfer function.
%   [Bq,Aq,Br,Ar] = QFILT2TF(Hq) converts the quantized filter coefficients from
%   the quantized filter Hq into transfer-function form with numerator Bq and
%   denominator Aq, and the reference coefficients into transfer-function form
%   with numerator Br and denominator Ar.  If the quantized filter Hq has more
%   than one section, then all the numerator polynomials are are convolved into
%   the numerator polynomial of a single transfer function.  Similarly, the
%   denominator polynomials are convolved into a denominator polynomial of a
%   single transfer function.
%
%   [Cq,Cr] = QFILT2TF(Hq,'sections') returns one cell per section, 
%   where Cq is the transfer-function form of the quantized coefficients and
%   Cr is the transfer-function form of the reference coefficients.
%     Cq = {{Bq1,Aq1},{Bq2,Aq2},...}
%     Cr = {{Br1,Ar1},{Br2,Ar2},...}
%
%   Example:
%     [A,B,C,D]=butter(3,.2);
%     Hq=qfilt('statespace',{A,B,C,D},'mode','double');
%     [b,a]=qfilt2tf(Hq)
%
%   See also QFILT.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.22 $  $Date: 2002/04/14 15:32:35 $

if nargin<2 | isempty(coeftype)
  coeftype = 'tf';
end

ctypes={'tf','sections'};

if ischar(coeftype)
  ind = strmatch(lower(coeftype),ctypes);
  if length(ind)==1
    coeftype = ctypes{ind};
  end
else
  error('Coefficient type must be a string.')
end
error(scalevaluescheck(Hq));

qcoefs          = get(Hq,'quantizedcoefficients');
rcoefs          = get(Hq,'referencecoefficients');
filterstructure = get(Hq,'filterstructure');
nsections       = get(Hq,'numberofsections');
scalevalues     = get(Hq,'scalevalues');

% Expand scalevalues with ones so that they can just be multiplied out if
% they are missing.
scalevalues = [scalevalues(:); ones(nsections-length(scalevalues)+1,1)];

try
  lasterr('')
  switch coeftype
    case 'sections'
      cr = cell2cell(filterstructure,rcoefs,nsections,scalevalues);
      cq = cell2cell(filterstructure,qcoefs,nsections,scalevalues);
      % Quantized might have been trimmed because of underflow.
      % Make sure they are the same length.
      [cq, cr] = zeropadquantized(cq,cr);
      varargout=cell(1,2);
      varargout{1}=cq;
      varargout{2}=cr;
    case 'tf'
      [br,ar] = cell2tf(filterstructure,rcoefs,nsections,scalevalues);
      [bq,aq] = cell2tf(filterstructure,qcoefs,nsections,scalevalues);
      % Quantized might have been trimmed because of underflow.
      % Make sure they are rows of the same length.
      ar = ar(:).';
      br = br(:).';
      bq = [bq(:).', zeros(1,length(br)-length(bq))];
      aq = [aq(:).', zeros(1,length(ar)-length(aq))];
      varargout=cell(1,4);
      varargout{1}=bq; 
      varargout{2}=aq;
      varargout{3}=br; 
      varargout{4}=ar;
    otherwise
      error('Invalid second argument.');
  end
catch
  error(qerror(lasterr))
end
  
%%%%%%%%%%%%%%%%%%%%%%%%
function c = cell2cell(filterstructure,coefs,nsections,scalevalues)
%CELL2CELL  Return sections individually.
%    C = CELL2CELL(FILTERSTRUCTURE,COEFS,NSECTIONS,SCALEVALUES) returns the
%    sections individually in the cell structure.

c = cell(size(coefs));

if isnumeric(coefs{1})
  % Single section
  [b,a] = sec2tf(filterstructure,coefs,scalevalues(1));
  b = b*scalevalues(nsections+1);
  c = {b,a};
else
  % Multiple sections, or single cell-of-cell, e.g. {{k1,v1},{k2,v2},...} or
  % {{k,v}} 
  for k=1:nsections
    [b,a] = sec2tf(filterstructure,coefs{k},scalevalues(k));
    c{k} = {b,a};
  end
  % The last section gets multiplied by the last scale value.
  c{nsections}{1} = c{nsections}{1}*scalevalues(nsections+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%
function [b,a] = cell2tf(filterstructure,coefs,nsections,scalevalues)
%CELL2TF Return in a single transfer function
%    [B,A] = CELL2TF(FILTERSTRUCTURE,COEFS,NSECTIONS,SCALEVALUES) returns a
%    single transfer function with the numerator coefficients in B and the
%    denominator coefficients in A. 

if isnumeric(coefs{1})
  % Single section
  [b,a] = sec2tf(filterstructure,coefs,scalevalues(1));
  b = b*scalevalues(nsections+1);
else
  % Multiple sections, or single cell-of-cell, e.g. {{k1,v1},{k2,v2},...} or
  % {{k,v}} 
  b=1;
  a=1;
  for k=1:nsections
    [b1,a1] = sec2tf(filterstructure,coefs{k},scalevalues(k));
    b = conv(b,b1);
    a = conv(a,a1);
  end
  % The last section gets multiplied by the last scale value.
  b = b*scalevalues(nsections+1);
end

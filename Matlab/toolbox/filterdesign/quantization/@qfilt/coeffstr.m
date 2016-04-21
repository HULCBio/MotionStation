function str = coeffstr(Hq)
%COEFFSTR  Quantized filter coefficient string.
%   STR = COEFFSTR(Hq) returns the string representation of the coefficients of
%   quantized filter object Hq.
%
%   Example:
%     Hq = qfilt;
%     str = coeffstr(Hq)
%
%   See also QFILT, QFILT/DISP, QFILT/DISPLAY.

%   Thomas A. Bryan, 31 August 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:25:04 $

cq = quantizedcoefficients(Hq);
cr = referencecoefficients(Hq);
fmt0 = get(0,'format');
q = quantizer(Hq,'coefficient');
[mn,mx] = range(q);
if isa(q,'quantum.unitquantizer')
  mx = max(1+eps(q),mx);
end

% f is the number of decimal digits to display.
f = max(min(16, max(0,ceil(-log2(realmin(q))))),0);
% w is the numeric display width in characters.
w = min(f+5,ceil(log10(realmax(q))+.5)+f+2);
% Check that the number of digits for the entire number are greater
% than the number of digits for the fraction.
if w<f
  w = f+5;
end
fmt = ['% ',num2str(w),'.',num2str(f)];
if strcmpi(fmt0,'hex')
  w = ceil(wordlength(q)/4);
end
names = structurenames(Hq);
c = {};
if isnumeric(cr{1})
  % Single section
  for i=1:length(cr)
    ntitle = sprintf('%s',names{i});
    qtitle = sprintf('QuantizedCoefficients{%d}',i);
    rtitle = sprintf('ReferenceCoefficients{%d}',i);
    sec = displaysection(q,mn,mx,fmt0,fmt,w,f,...
          ntitle,qtitle,rtitle,cq{i},cr{i});
    c = {c{:},sec};
  end
else
  % Multiple sections
  for i=1:length(cr)
    c = {c{:},sprintf('------- Section %d -------',i)};
    for j=1:length(cr{i})
      ntitle = sprintf('%s',names{j});
      qtitle = sprintf('QuantizedCoefficients{%d}{%d}',i,j);
      rtitle = sprintf('ReferenceCoefficients{%d}{%d}',i,j);
      sec = displaysection(q,mn,mx,fmt0,fmt,w,f,...
          ntitle,qtitle,rtitle,cq{i}{j},cr{i}{j});
      c = {c{:},sec};
    end
  end
end
str = char(c);

%-----------------------------------------------------------------------
function str = displaysection(q,mn,mx,fmt0,fmt,w,f,...
    ntitle,qtitle,rtitle,cq,cr)
%DISPLAYSECTION  Display coefficients of one section.
%
%   STR = DISPLAYSECTION(Q,MN,MX,FMT0,FMT,W,F,...  NTITLE,QTITLE,RTITLE,CQ,CR)
%   returns a string STR representation of the quantized coefficients CQ and the
%   reference coefficients CR.  Q is the coefficient quantizer, MN is the min
%   value before overflow, MX is the max value before overflow, FMT0 is the base
%   workspace format ('HEX' or not), FMT is the format of the quantized
%   coefficients, W is the width of the quantized coefficients, F is the number
%   of quantized decimal digits to display, NTITLE is name of this element
%   (e.g., 'Numerator'), QTITLE is 'QuantizedCoefficients{x}{x}', RTITLE is
%   'ReferenceCoefficients{x}{x}', CQ are the quantized coefficients, CR are the
%   reference coefficients.

emptycoeff = isempty(cr);
c = {};
vector = privisvector(cr);
[m,n] = size(cr);
len = max(m,n);
% Don't use format 'f' for numbers that won't fit.
if ~emptycoeff & log10(max(abs(cq(:)))+eps) > max(w-f-1,1)
  fmt  = [fmt,'g'];
else
  fmt  = [fmt,'f'];
end    
% Reference coefficients display 2 digits to the left of the decimal point in
% "f" format if it fits, or else go to "g" format.
fmtd = '%22.18';
if ~emptycoeff & log10(max(abs(cr(:)))+eps) > 2
  fmtd = [fmtd,'g'];
else
  fmtd = [fmtd,'f'];
end    

% Prepend + positive overflow, - negative overflow, 0 underflow to each line
% of the coefficient string.
reoverflow = overflowlegend(q,real(cq),real(cr),mn,mx);
imoverflow = overflowlegend(q,imag(cq),imag(cr),mn,mx);

% Convert coefficients to cell arrays of strings cq, cr.
if emptycoeff
  cq = '[]';
  cr = '[]';
elseif strcmpi(fmt0,'hex')
  cq = deblank(num2hex(q,cq(:)));
  cr = deblank(num2str(cr(:),fmtd));
  % $$$   cr = deblank(num2hex(quantizer('double'),cr(:)));
elseif strcmpi(fmt0,'rational') & ...
      strmatch(mode(q),strvcat('fixed','ufixed'))
  % format rational and fixed-point, display as an integer.
  fmtrat = ['%17.0f/2^',num2str(fractionlength(q))];
  cq = deblank(num2str(pow2(cq(:),fractionlength(q)),fmtrat));
  cr = deblank(num2str(cr(:),fmtd));
else
  cq = deblank(num2str(cq(:),fmt));
  cr = deblank(num2str(cr(:),fmtd));
end

width = max(length(qtitle),size(cq,2));
if emptycoeff
  % QuantizedCoefficients{x}
  iwidth = ceil(log10(len+1));
  titlefmt = sprintf('%%%ds    %%s',width+iwidth+4);
  fmt      = sprintf('%%%ds  %%s',width);
  c = {c{:},sprintf('%s',ntitle)};
  c = {c{:},sprintf(titlefmt,qtitle,rtitle)};
  c = {c{:},[reoverflow,imoverflow,'    ',...
            sprintf(fmt,cq,cr)]};
elseif vector
  % QuantizedCoefficients{x}
  iwidth = ceil(log10(len+1));
  titlefmt = sprintf('%%%ds    %%s',width+iwidth+4);
  fmt      = sprintf('%%%ds  %%s',width);
  c = {c{:},sprintf('%s',ntitle)};
  c = {c{:},sprintf(titlefmt,qtitle,rtitle)};
  ijfmt = sprintf('(%%%dd)',iwidth);
  for i=1:len
    ij = sprintf(ijfmt,i);
    c = {c{:},[reoverflow(i),imoverflow(i),ij,...
            sprintf(fmt,cq(i,:),cr(i,:))]};
  end
else  % Matrix
  % QuantizedCoefficients{xx}{x}
  iwidth = ceil(log10(m+1));
  jwidth = ceil(log10(n+1));
  titlefmt = sprintf('%%%ds    %%s',width+iwidth+jwidth+4);
  fmt      = sprintf('%%%ds  %%s',width);
  c = {c{:},sprintf('%s',ntitle)};
  c = {c{:},sprintf(titlefmt,qtitle,rtitle)};
  ijfmt = sprintf('(%%%dd,%%%dd)',iwidth,jwidth);
  k = 1;
  for j=1:n
    for i=1:m
      ij = sprintf(ijfmt,i,j);
      c = {c{:},[reoverflow(k),imoverflow(k),ij,...
              sprintf(fmt,cq(k,:),cr(k,:))]};
      k = k+1;
    end
  end
end

str = char(c);

%-----------------------------------------------------------------------
function names = structurenames(Hq)
%STRUCTURENAMES Name of the elements of the structure
%
%   NAMES = STRUCTURENAMES(Hq) returns a cell array of the names of the
%   elements of a section (e.g., {'Numerator','Denominator'}).
switch filterstructure(Hq)
  case {'df1','df1t','df2','df2t'}
    names = {'Numerator','Denominator'};
  case {'fir','firt','symmetricfir','antisymmetricfir'}
    names = {'Numerator'};
 case {'latticear','latticearma','latticema',...
       'latcallpass','latticeallpass','latcmax','latticemaxphase'}
    names = {'Lattice','Ladder'};
  case {'latticeca', 'latticecapc'}
    names = {'Lattice1', 'Lattice2','beta'};
  case {'statespace'}
    names = {'A','B','C','D'};
end

%-----------------------------------------------------------------------
function str = overflowlegend(q,cq,cr,mn,mx)
%OVERFLOWLEGEND Creates a column of legends for overflows.
%
%   STR = OVERFLOWLEGEND(Q,CQ,CR,MN,MX) creates a column vector of
%   strings STR that contains '+' for overflow in the positive direction, '-'
%   for overflow in the negative direction, '0' for underflow, and ' ' for no
%   overflow or underflow.  

% For empty matrices, the legend is blank, and no other processing of the
% legend needs to be done.
if isempty(cr)
  str = ' ';
  return
end

% Initialize string to all blanks.
[m,n] = size(cr);
str = repmat(' ',m*n,1);

% Put a 0 for underflows, and set the legend flag to true.
k = cr~=0 & cq==0;
str(k) = '0';

% Overflow is computed after rounding.
cr = round(q,cr);

% Put a + for overflows in the positive direction, and set the legend flag to
% true. 
k = cr>mx;
str(k) = '+';

% Put a - for overflows in the negative direction, and set the legend flag to
% true. 
k = cr<mn;
str(k) = '-';


function [] = printmat(a,name,rlab,clab)
%PRINTMAT Print matrix with labels.
%   PRINTMAT(A,NAME,RLAB,CLAB) prints the matrix A with the row labels
%   RLAB and column labels CLAB.  NAME is a string used to name the 
%   matrix.  RLAB and CLAB are string variables that contain the row
%   and column labels delimited by spaces.  For example, the string
%
%       RLAB = 'alpha beta gamma';
%
%   defines 'alpha' as the label for the first row, 'beta' for the
%   second row and 'gamma' for the third row.  RLAB and CLAB must
%   contain the same number of space delimited labels as there are 
%   rows and columns respectively.
%
%   PRINTMAT(A,NAME) prints the matrix A with numerical row and column
%   labels.  PRINTMAT(A) prints the matrix A without a name.
%
%   See also: PRINTSYS.

%   Clay M. Thompson  9-24-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:32:35 $

error(nargchk(1,4,nargin));

space = ' ';
[nrows,ncols] = size(a);

if nargin<2, name = []; end
if nargin==3, error('Wrong number of input arguments.'); end
if nargin<4,
  rlab = []; clab = [];
  for i=1:nrows, rlab = [rlab, sprintf('--%d--> ',i)]; end
  for i=1:ncols, clab = [clab, sprintf('--%d--> ',i)]; end
  rlab=rlab(1:length(rlab)-1);
  clab=clab(1:length(clab)-1);
end

col_per_scrn=5;
len=12;


if (nrows==0)|(ncols==0), 
  if ~isempty(name), disp(' '), disp(sprintf('%s = ',name)), end
  disp(' ')
  disp('     []')
  disp(' ')
  return
end

% Remove extra spaces (delimiters)
ndx1 = find(clab==' ');
ndx2 = find([ndx1,0]==[-1,ndx1+1]);
if ~isempty(clab), clab(ndx1(ndx2))=[]; end

ndx1 = find(rlab==' ');
ndx2 = find([ndx1,0]==[-1,ndx1+1]);
if ~isempty(rlab), rlab(ndx1(ndx2))=[]; end

% Determine position of delimiters
cpos = find(clab==' ');
if length(cpos)<ncols-1, error('Not enough column labels.'); end
cpos = [0,cpos,length(clab)+1];

rpos = find(rlab==' ');
if length(rpos)<nrows-1, error('Not enough row labels.'); end
rpos = [0,rpos,length(rlab)+1];

col=1;
n = min(col_per_scrn-1,ncols-1);
disp(' ')
if ~isempty(name), disp(sprintf('%s = ',name)), end  % Print name
while col<=ncols
  % Print labels
  s = space(ones(1,len+1));
  for j=0:n,
    lab = clab(cpos(col+j)+1:cpos(col+j+1)-1);
    if length(lab)>len,
      lab=lab(1:len);
    else
      lab=[space(ones(1,len-length(lab))),lab]; end
    s= [s,' ',lab];
  end
  disp(setstr(s))
  for i=1:nrows,
    s = rlab(rpos(i)+1:rpos(i+1)-1); 
    if length(s)>len, s=s(1:len); else s=[space(ones(1,len-length(s))),s]; end
    s = [' ',s];
    for j=0:n,
      element = a(i,col+j);
      if element==0,
        s=[s,'            0'];
      elseif (element>=1.e6)|(element<=-1.e5)|(abs(element)<.0001)
        s=[s,sprintf(' %12.5e',element)];
      else
        s=[s,sprintf(' %12.5f',element)];
      end
    end
    disp(s)
  end % for
  col = col+col_per_scrn;
  disp(' ')
  if (ncols-col<n), n=ncols-col; end
end % while

% end printmat

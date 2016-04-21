function [] = printsys(a,b,c,d,ulab,ylab,xlab)
%PRINTSYS Print system in pretty format.
%   PRINTSYS is used to print state space systems with labels to the
%   right and above the system matrices or to print transfer functions
%   as a ratio of two polynomials.
%
%   PRINTSYS(A,B,C,D,ULABELS,YLABELS,XLABELS) prints the state-space
%   system with the input, output and state labels contained in the
%   strings ULABELS, YLABELS, and XLABELS, respectively.  ULABELS, 
%   YLABELS, and XLABELS are string variables that contain the input,
%   output and state labels delimited by spaces.  For example the 
%   label string
%       YLABELS=['Phi Theta Psi']
%   defines 'Phi' as the label for the first output, 'Theta' as the 
%   label for the second output, and 'Psi' as the label for the third
%    output.
%   
%   PRINTSYS(A,B,C,D) prints the system with numerical labels.
%   
%   PRINTSYS(NUM,DEN,'s') or PRINTSYS(NUM,DEN,'z') prints the transfer
%   function as a ratio of two polynomials in the transform variable
%   's' or 'z'.
%
%   See also: PRINTMAT and POLY2STR.

%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:32:32 $

error(nargchk(2,7,nargin));

len = 12; % Label parameter.  Should match parameter in PRINTMAT.

% --- Determine which syntax is being used ---
if nargin==2,       % Transfer function without transform variable
  [num,den] = tfchk(a,b);
  tvar = 's';

elseif nargin==3,   % Transfer function with transform variable
  [num,den] = tfchk(a,b);
  if ~isstr(c), error('Transform variable must be a string.'); end
  tvar = c;

elseif nargin==4,   % State space system without labels
  [msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
  [nx,na] = size(a);
  if nx>0, 
    [ny,nc] = size(c);
    [nb,nu] = size(b);
  else
    [ny,nu] = size(d);
  end
  ulab = []; ylab = []; xlab = [];
  for i=1:nx, xlab = [xlab, sprintf('x%-3.0f ',i)]; end
  printmat(a,'a',xlab,xlab);
  for i=1:nu, ulab = [ulab, sprintf('u%-3.0f ',i)]; end
  printmat(b,'b',xlab,ulab);
  for i=1:ny, ylab = [ylab, sprintf('y%-3.0f ',i)]; end
  printmat(c,'c',ylab,xlab);
  printmat(d,'d',ylab,ulab);

elseif (nargin==5)|(nargin==6),
  error('Wrong number of input arguments.');

else            % State space system with labels
  [msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
  [nx,na] = size(a);
  [ny,nc] = size(c);
  [nb,nu] = size(b);
  if ~isstr(ulab), error('ULAB must be a string.'); end
  if ~isstr(ylab), error('YLAB must be a string.'); end
  if ~isstr(xlab), error('XLAB must be a string.'); end
  
  % Put labels into format for PRINTMAT
  xlab = lab2str(xlab);
  printmat(a,'a',xlab,xlab);
  ulab = lab2str(ulab);
  printmat(b,'b',xlab,ulab);
  ylab = lab2str(ylab);
  printmat(c,'c',ylab,xlab);
  printmat(d,'d',ylab,ulab);
end

if (nargin==2)|(nargin==3), % Print system as a ratio of polynomials
  [nn,mn] = size(num);

  [s,dlen] = poly2str(den,tvar);

  for i=1:nn,
    [t,nlen] = poly2str(num(i,:),tvar);

    % Now print the polynomials
    len=max([dlen,nlen])-3;
    disp(' ')
    if nn==1,
      disp('num/den = ')
    else
      disp(sprintf('num(%d)/den = ',i));
    end
    disp(' ')
    if length(t)<len+3,     % Print numerator
      disp([' '*ones(1,fix((len+4-length(t))/2)),t]),
    else
      disp(t)
    end
    disp(['   ','-'*ones(1,len)])
    if length(s)<len+3,     % Print denominator
      disp([' '*ones(1,fix((len+4-length(s))/2)),s]),
    else
      disp(s)
    end
  end

end


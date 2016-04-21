function varargout = zplane(z,p,varargin)
%ZPLANE Z-plane zero-pole plot.
%   ZPLANE(Z,P) plots the zeros Z and poles P (in column vectors) with the 
%   unit circle for reference.  Each zero is represented with a 'o' and 
%   each pole with a 'x' on the plot.  Multiple zeros and poles are 
%   indicated by the multiplicity number shown to the upper right of the 
%   zero or pole.  ZPLANE(Z,P) where Z and/or P is a matrix, plots the zeros
%   or poles in different columns using the colors specified by the axes 
%   ColorOrder property.
%
%   ZPLANE(B,A) where B and A are row vectors containing transfer function
%   polynomial coefficients plots the poles and zeros of B(z)/A(z).  Note
%   that if B and A are both scalars they will be interpreted as Z and P.
%
%   [HZ,HP,Hl] = ZPLANE(Z,P) returns vectors of handles to the lines and 
%   text objects generated.  HZ is a vector of handles to the zeros lines, 
%   HP is a vector of handles to the poles lines, and Hl is a vector of 
%   handles to the axes / unit circle line and to text objects which are 
%   present when there are multiple zeros or poles.  In case there are no 
%   zeros or no poles, HZ or HP is set to the empty matrix [].
%
%   ZPLANE(Z,P,AX) puts the plot into the axes specified by the handle AX. 
%
%   See also FREQZ, GRPDELAY, IMPZ, FVTOOL.

%   Author(s): T. Krauss, 3-19-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/15 01:18:14 $

error(nargchk(1,3,nargin))

if nargin < 2, p = []; end

[z,p,msg] = parseinput(z,p);
error(msg);

% Call the Pole/Zero plotting engine. 
[zh,ph,oh] = zplaneplot(z,p,varargin{:}); 

if (nargout==1),
   varargout = {zh};
   
elseif (nargout==2),
   varargout = {zh,ph};

elseif (nargout==3),
   varargout = {zh,ph,oh};
end


%-------------------------------------------------------------------
function [z,p,msg] = parseinput(z,p)

msg = '';

% If first arg is a row, second must be a row, empty or scalar, flag = 1
[test1flag,msg] = istf(z,p);
if ~isempty(msg),
    return
end

% If second arg is a row, first must be a row, empty or scalar, flag = 1
[test2flag,msg] = istf(p,z);
if ~isempty(msg),
    return
end

istfflag = test1flag | test2flag;
if istfflag,
    % Transfer function specified; compute the poles and zeros
    [z,p,k] = tf2zpk(z,p);
end

%-------------------------------------------------------------------
function [flag,msg] = istf(b,a)

msg = '';
flag = 0; % Flag indicating whether a transfer function was specified

if isrow(b) & ~isscalar(b),
    % If first arg is a row, second must be row or empty
    if ~(isrow(a) | is0x0(a)),
        msg = 'When specifying polynomials, both vectors must be rows.';
        return
    else
        flag = 1;
    end
end

%-------------------------------------------------------------------
function flag = isrow(vec)
% Determine if vector is row vector
flag = 0;
if size(vec,1) == 1,
    flag = 1;
end

%-------------------------------------------------------------------
function flag = is0x0(A)
% Determine if argument is a zero by zero matrix
flag = 0;
if all(size(A) == 0),
    flag = 1;
end

%-------------------------------------------------------------------
function flag = isscalar(A)
% Determine if argument is a scalar (1 by 1)
flag = 0;
if all(size(A) == 1),
    flag = 1;
end

% [EOF]

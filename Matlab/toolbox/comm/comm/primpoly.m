function pr= primpoly(m, fd_flag,disp_flag)
%PRIMPOLY Find primitive polynomials for a Galois field.
%   PR = PRIMPOLY(M) computes one degree-M primitive polynomial for GF(2^M). 
%
%   PR = PRIMPOLY(M, OPT) computes primitive polynomial(s) for GF(2^M).
%   OPT = 'min'  find one primitive polynomial of minimum weight.
%   OPT = 'max'  find one primitive polynomial of maximum weight.
%   OPT = 'all'  find all primitive polynomials. 
%   OPT = L      find all primitive polynomials of weight L.
%   
%   PR = PRIMPOLY(M, OPT, 'nodisplay') or PR = PRIMPOLY(M, 'nodisplay') disables the default 
%   display style of the primitive polynomials. The string 'nodisplay' can be given either 
%   as the second or the third argument.
%
%   The output column vector PR represents the polynomial(s) listed by its decimal equivalent.
%   If OPT = 'all' or L, and more than one primitive polynomial satisfies the
%   constraints, then each element of PR represents a different polynomial.  If no
%   primitive polynomial satisfies the constraints, then PR is empty.
%
%   See also ISPRIMITIVE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $   $Date: 2002/10/20 12:42:39 $

% Error checking.
error(nargchk(1,3,nargin));

% Error checking - M.
if ( isempty(m) | ~isreal(m) | m<1 | floor(m)~=m | prod(size(m))~=1 | m>16)
    error('M must be a real positive scalar greater than 0 and lesser than or equal to 16.');
end

% Error checking - FD_FLAG.
if nargin==1 
    fd_flag = 'one';
    disp_flag='';
elseif nargin==2
    
    if ischar(fd_flag)
        fd_flag = lower(fd_flag);
        if ~( strcmp(fd_flag,'min') | strcmp(fd_flag,'max') | strcmp(fd_flag,'all') | strcmp(fd_flag,'nodisplay') | strcmp(fd_flag,'one') )
            error('Invalid string input. Type help primpoly for more information on usage.');
        end
        
        if strcmp(fd_flag,'nodisplay')
            disp_flag='nodisplay';
            fd_flag='one';
        else
            disp_flag='';
        end
        
    elseif ( isempty(fd_flag) | floor(fd_flag)~=fd_flag | ~isreal(fd_flag) | prod(size(fd_flag))~=1 | fd_flag<2 | fd_flag>m+1 )
        error('OPT parameter must be either a string, or a real integer greater than one and less than M+1.');
    else
        disp_flag='';
        
    end
    
elseif nargin>2
    if ischar(disp_flag)
        if ~( strcmp(disp_flag,'nodisplay') )
            strr=sprintf('Invalid string input for polynomial display option.\nChoose ''nodisplay'' to turn off polynomial form of display.');
            error(strr);
        end
    else 
        error('Third parameter must be the string ''nodisplay'' to turn off the display the polynomials naturally');
    end
end
   
%Load the look up table containing the list of primitive polynomials

load gfprimpoly;
prims=gfprimpoly{m};

primsbin=de2bi(prims');

%Compute the array containing the weights of the polynomials
polyweight=sum(primsbin,2);



% Find either just the first, or all valid primitive polynomials.
if strcmp(fd_flag,'one')
    % the defaults from gf.m
    p_vec = [3 7 11 19 37 67 137 285 529 1033 2053 4179 8219 17475 32771 69643];
    pr = p_vec(m);
elseif strcmp(fd_flag,'all')
    pr = prims';
elseif strcmp(fd_flag,'min')
    pr=min(prims);
elseif strcmp(fd_flag,'max')
    pr=max(prims);
elseif isnumeric(fd_flag)
    %Error check on weight L (fd_flag)
    if ( ~isreal(fd_flag) | fd_flag<1 | floor(fd_flag)~=fd_flag | ndims(fd_flag)>2 )
    error('Weight L must be a real positive scalar.');
    end
    % Find the primitive polynomials of only certain weight L (fd_flag).
    polydec=find(polyweight==fd_flag);
    if ~isempty(polydec)
        pr=prims(polydec)';
    else
        pr=[];
    end
end


if isempty(pr)
    disp('No primitive polynomial satisfies the given constraints.');
end;

if ~isempty(pr) & ~strcmp(disp_flag,'nodisplay')
    disp(' ');
    disp('Primitive polynomial(s) = ');
    disp(' ');
    dispp(pr)
end

%-------------------------------------------------------------------
%Display function for displaying the polynomials
function dispp(pr)
pr=de2bi(pr);
for i=1:size(pr,1)
    s=find(pr(i,:));
    if s(1)==1
        init_str='1';
    else
        init_str='0';
    end
    s(1)=[];
    s=s-1;
    
    if ~isempty(s)
        s = fliplr(s);
        str1 = [sprintf('D^%d+',s) init_str ];
        if str1(end)=='0', str1(end-1:end)=[]; end;
        disp(str1);
    end
end


%--end of GFPRIMFD--



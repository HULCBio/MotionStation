function cs = cosets(m,varargin)
% COSETS Produce cyclotomic cosets for a Galois field.
%   CST = COSETS(M) produces cyclotomic cosets mod (2^M - 1). Each element of the
%   cell array CST contains one cyclotomic coset.
%
%   CST = COSETS(M,PRIMPOLY) specifies the primitive polynomial of the
%   cosets.
%
%   See also MINPOL.

%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.4.4.3 $  $Date: 2004/04/12 23:00:35 $ 

% Error checking 

if(nargin>2)
    error('Too many input arguments.');
end

if ( isempty(m) || prod(size(m))~=1 || ~isreal(m) || floor(m)~=m || m<1 || m<1 || m>16 )
    error('M must be a real positive integer between 1 and 16.');
end

if (nargin == 1 || isempty(varargin))
    prim_poly = primpoly(m);
elseif (~isscalar(varargin{1}) || ~isnumeric(varargin{1})|| ~isprimitive(double(varargin{1})))
    error('PRIMPOLY must be a scalar integer that represents a primtive polynomial.');
else
    prim_poly = varargin{1};
end
    
n = 2^m - 1;
cs = {gf(1,m,prim_poly)};            % used for the output
ind = ones(1, n - 1);      % used to register unprocessed numbers.

if (m ~= 1)
    i = 1;
    while ~isempty(i)
        
        % to process numbers that have not been done before.
        ind(i) = 0;             % mark the register
        v = i;
        pk = rem(2*i, n);       % the next candidate
        
        % build cyclotomic coset containing i
        while (pk > i)
            ind(pk) = 0;    % mark the register
            v = [v pk];     % add the element
            pk = rem(pk * 2, n);    % the next candidate
        end;
        
        % convert to polynomial form
        alph=gf(2,m,prim_poly);
        v_poly = alph.^v';
        
        % append the coset to cs
        cs{length(cs)+1} = v_poly;
        i = min(find(ind == 1));        % the next number.
        
    end;   
end;
% make cs a column vector
cs = cs';

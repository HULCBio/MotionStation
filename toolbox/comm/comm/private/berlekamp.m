function [code, cnumerr] = berlekamp(code,N,K,t,b,codeType)
%BERLEKAMP Berlekamp-Massey Algorithm for RS and BCH Decoding.  Core algorithm of RSDEC/BCHDEC.
%   [CCODE,CNUMERR] = BERLEKAMP(CODE,N,K,T,B) attempts to correct the errors in 
%   the received word CODE to form a valid Reed Solomon or BCH codeword CCODE.  CODE 
%   must be a gf object with a row vector as its x field.  T is the error-
%   correcting capability which must be a positive integer.  CNUMERR returns 
%   the number of errors corrected.  In the case of a decoding failure, which is 
%   when CODE differs for more than T symbols from any possible valid codewords, 
%   CNUMERR returns -1. codeType can be either 'rs' or 'bch'. It is used to
%   distinguish between Reed-Solomon or BCH decoding.
%   
%   See also GF, RSDEC, BCHDEC

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4.4.1 $  $Date: 2002/08/04 03:09:52 $ 
% Author : Katherine Kwong
% Reference : (1) "Error Control Systems for Digital Communication and Storage", 
%                 Wicker, Prentice Hall, 1995.  
%                 Section 9.2.2 : "The Berlekemp-Massey Algorithm"
%
%             (2) "Algebraic Coding Theory", Berlekamp, McGraw-Hill, 1968.
%                 Section 10.3 : "Alternate BCH codes and Extended BCH codes"
%
% NOTE that there is no error checking of the input arguments.  All checking
% should have been done in RSDEC/BCHDEC.

 M = code.m;
 T2 = 2*t;       % number of parity symbols

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                                         %
                %         Find error locations            %
                %                                         %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1 -- Compute Syndrome series Si=r(alpha^(b-1+i)), for i = 1 to 2*t
%           where r(x) is the received polynomial.
%           e.g. For narrow-sense codes, b=1
S = code* ((gf(2,M,code.prim_poly)).^([N-1:-1:0]'*(b-1+[1:T2])));

% If all syndromes==0, CODE is a valid codeword and there is no error to be
% corrected.  Return CODE unaltered.  Exit function.
if ~any(S)
    cnumerr = 0;
    return
end

% Step 2 -- Initializations
% Length of the linear feedback shift register (LFSR)
L = 0;

% Connection polynomial = 1.  ASCENDING order.  deg(LambdaX) = 2*t
% Define as an object here because it might never get modified in the iterations.
%   NOTE : LambdaX is the coefficients of the connection polynomial
%          in order of ASCENDING powers rather than the
%          conventional descending order.  This is such that after
%          the set of iterations, the inverse of roots of LambdaX 
%          in descending order can be obtained directly by finding
%          the roots of LambdaX in ascending order.
LambdaX = gf([1 zeros(1,T2)],M,code.prim_poly);

% Correction polynomial = x.  ASCENDING order
Tx = [0 1 zeros(1,T2-1)];

% 2*t iterations
for k = 1:T2
    
    % Temporary storage for Connection polynomial from last iteration
    LambdaXTemp = LambdaX;
    
    % Step 3 -- Discrepancy
    %           S(k) - sum of LambdaXTemp(i+1)*S(k-i)
    Delta = S(k) - LambdaXTemp(1+[1:L])*(S(k-[1:L]))';
    
    % Step 4
    if Delta.x
        
        % Step 5 -- Connection polynomial
        %           Lambda_k(x)=Lambda_(k-1)(x)-Delta_k*T(x)
        LambdaX = LambdaXTemp - Delta*Tx;
        
        % Step 6
        if 2*L < k
            
            % Step 7 -- Correction polynomial
            %           T(x) = Lambda_(k-1)(x)/Delta_k
            L = k-L;
            Tx = LambdaXTemp/Delta;      
        end
    end
    
    % Step 8 -- Correction polynomial
    %           T(x) = x * T(x)
    Tx = [0 Tx(1:T2)];
    
    % Step 9 -- Go on to next iteration
end
    

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %                                                          %
      %   Find error magnitudes at each of the error locations   %
      %                                                          %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      
% LambdaX is now the error locator polynomial.  Degree = 2*t
LambdaXValue = LambdaX.x;
% Remove trailing zeros such that no zero roots will be returned, 
% which do not exist in the inverse of the LambdaX polynomial.
LambdaX = gf(LambdaXValue(1:max(find(LambdaXValue))), M, code.prim_poly);

% Decoding failure (code has more than t errors) if one of these conditions is met:
% - degree of the error locator polynomial is not larger than t
% - the error locator polynomial is a constant, which has no roots by definition
if length(LambdaX)> t+1 | length(LambdaX)<2
    
    % Decoding failure
    cnumerr = -1;
    return
end

% LambdaX is in ascending order, but ROOTS takes a polynomial in descending order.
% So roots of LambdaX are the inversed roots of the error locator polynomial.
errLoc_int = roots(LambdaX);

% Decoding failure (code has more than t errors) if one of these conditions is met:
% - the number of roots of LambdaX does not equal deg(LambdaX),
%       including the case where there are no roots in the same field
% - the roots do not lie in the same field as CODE (indicated by an empty errLoc_int)
% - not all the roots are distinct
if ~isequal(length(errLoc_int),length(LambdaX)-1) ...
   | ~isequal(unique(errLoc_int.x),sort(errLoc_int.x))
    cnumerr = -1;
    return
end

% At this point, correctable errors are detected and will be corrected.

% Number of errors to be corrected
cnumerr = length(errLoc_int);

% Error locations are the exponent of errLoc_int in power form
errLoc = log(errLoc_int);


if( strcmp(codeType,'rs'))
    % Error magnitude polynomial -- Wicker Eq.9-31
    OmegaX = conv(LambdaX, [1 S]);
    % Throw away terms of x^(2*t+1) and higher
    % because we have no knowledge of terms of x^(2*t+1) and higher in S(x)
    OmegaX = OmegaX(1:T2+1);            
    
    % Derivative of the Error locator polynomial
    LambdaXDeriv = LambdaX(2:length(LambdaX));
    LambdaXDeriv(2:2:length(LambdaXDeriv))=0;
end

% Find Error Magnitude at each of the Error locations -- Berlekamp Eq. 10.32
for i = 1:length(errLoc)
    
    if(strcmp(codeType, 'rs'))
        errorMag = (OmegaX*errLoc_int(i).^(1-b+[1:-1:-T2+1]')) / ...
            (LambdaXDeriv*errLoc_int(i).^[0:-1:-length(LambdaXDeriv)+1]');
    else
        errorMag = 1;
    end
    % Corrected code
    code(N-errLoc(i)) = code(N-errLoc(i)) - errorMag;
    
end

% -- end of berlekamp --

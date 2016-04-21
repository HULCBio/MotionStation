%  Called by LMIINFO
%
%  [type_a,type_b,test_sym] = coeftype(lmi_t,data,type_var)
%
%  Gets the type of the coefficients A, B of the term lmi_t
%  and tests if A' = B
%
%  Input:
%    LMI_T  term from LMI_TERMS associated with A*Xk*B
%    DATA   coefficient data
%
%  Output:
%    TYPE_A, TYPE_B : type of the coefficients A and B
%                     ( 0 -> scalar, 1 -> full)
%    TEST_SYM : 1 if A' = B, 0 otherwise

% Author: A. Ignat  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [type_a,type_b,test_sym] = coeftype(lmi_t,data,type_var)

test_sym = -Inf ;
shft=lmi_t(5);        % base of data segment in DATA


ma=data(shft+1); na=data(shft+2);
type_a = (ma~=1 | na~=1);
shft=shft+2; aux=ma*na;
ca=ve2ma(data(shft+1:shft+aux),2,[ma,na]);


shft=shft+aux;
mb=data(shft+1); nb=data(shft+2);
type_b = (mb~=1 | nb~=1);
shft=shft+2;
cb=ve2ma(data(shft+1:shft+mb*nb),2,[mb,nb]);


test_sym=0;
if lmi_t(2) == lmi_t(3) & (type_var == 1 | type_var==31) ...
                                        & ma == nb & na == mb,
   [bool,test_sym] = isslfcjg(ca,cb');
   if ~bool, test_sym = -Inf; end
end


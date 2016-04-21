function display(p)
%DISPLAY Display Galois  array.
%   DISPLAY(X) is called for the object X when the semicolon is not used
%   to terminate a statement.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:15:27 $

bin=de2bi(double(p.prim_poly));
s=find(bin);
s(1)=[];
s=s-1;
if isempty(s)
    init_str = '1';
elseif s(1)==1
    init_str = 'D+1';
    s(1)=[];
else
    init_str = '1';
end
if isempty(s)
    str1 = [inputname(1) ' = GF(2) array. ' ];
else
    s = fliplr(s);
    str1 = [inputname(1) ' = GF(2^' num2str(p.m) ') array. ' ...
            'Primitive polynomial = '  sprintf('D^%d+',s) init_str ' (' ...
            num2str(double(p.prim_poly)) ' decimal)'];
end
if isequal(get(0,'FormatSpacing'),'compact')
    disp(str1);
    disp('Array elements = ')
    disp(p.x)
else
    disp(' ');
    disp(str1);
    disp(' ');
    disp('Array elements = ')
    disp(' ');
    disp(p.x)
end

%the bits of each element are coefficients in GF(2) of a polynomial
%in alpha, where alpha is a root of the primitive polynomial.


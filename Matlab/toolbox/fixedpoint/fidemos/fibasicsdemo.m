%% fi Basics
% Demonstrates the basic use of the fixed-point numeric object |fi|.

%% Notation
% The fixed-point numeric object is called *|fi|* because J.H. Wilkinson
% used *|fi|* to denote fixed-point computations in his classic texts
% Rounding Errors in Algebraic Processes (1963), and The Algebraic
% Eigenvalue Problem (1965).

%% Display options
% Before we begin, let's set some display options.  We will have
% more to say about these later. 
format loose
format long g
reset(fipref)
fipref('FiMathDisplay','none');

%% Default fi attributes
% To assign a fixed-point data type to a number or variable with the
% default fixed-point parameters, use the |fi| constructor.  
%
% For example, the following creates fixed-point variables |a| and |b| with
% attributes shown in the display, all of which we can specify when the
% variables are constructed.  Note that when the |FractionLength| property
% is not specified, it is set automatically to "best precision" for the
% given word length, keeping the most-significant bits of the value.

a = fi(pi)
%%
b = fi(0.1)

%% Specifying Signed and WordLength properties
% The second and third numeric arguments specify |Signed| (|true| or 1 =
% |signed|, |false| or 0 = |unsigned|), and |WordLength| in bits,
% respectively.

% Signed 8-bit
a = fi(pi, 1, 8)

%%

% Unsigned 20-bit
b = fi(exp(1), 0, 20)

%% Precision
% The data is stored internally with as much precision as is specified.
% However, it is important to be aware that initializing high precision
% fixed-point variables with double-precision floating-point variables may
% not give you the resolution that you might expect at first glance.  For
% example, let's initialize an unsigned 100-bit fixed-point variable with
% 0.1, and then examine its binary expansion:
a = fi(0.1, 0, 100);
%%
bin(a)

%%
% Note that the infinite repeating binary expansion of 0.1 gets cut off at
% the 52nd bit (in fact, the 53rd bit is significant and it is rounded up
% into the 52nd bit). This is because double-precision floating-point
% variables (the default MATLAB data type), are stored in 64-bit
% floating-point format, with 1 bit for the sign, 11 bits for the exponent,
% and 52 bits for the mantissa plus one "hidden" bit for an effective 53
% bits of precision.  Even though double-precision floating-point has a
% very large range, it's precision is limited to 53 bits.  For more
% information on floating-point arithmetic, refer to Chapter 1 of Cleve
% Moler's book, Numerical Computing with MATLAB.  The pdf version can be
% found here:
% <http://www.mathworks.com/company/aboutus/founders/clevemoler.html>
%
% So, why have more precision than floating-point?  Because most fixed-point
% processors have data stored in a smaller precision, and then compute with
% larger precisions.  For example, let's initialize a 40-bit unsigned |fi|
% and multiply using the default full-precision for products.
%
% Note that the full-precision product of 40-bit operands is 80 bits, which
% is greater precision than standard double-precision floating-point.
a = fi(0.1, 0, 40);
bin(a)

%%

b = a*a

%%

bin(b)

%% Data access
% The data can be accessed in a number of ways which map to built-in data
% types and binary strings.  For example, 
%% double(a)
a = fi(pi);
double(a)
%% 
% returns the double-precision floating-point "real-world" value of |a|,
% quantized to the precision of |a|.
%% a.double = ...
% We can also set the real-world value in a double.
a.double = exp(1)
%%
% sets the real-world value of |a| to |e|, quantized to |a|'s numeric type.
%% int(a), a.int = ...
int(a)
%%
% returns the "stored integer" in the smallest built-in integer type
% available, up to 32 bits.
% 
% Conversely, |a.int = ...| sets the stored integer.
a.int = 25736

%% Relationship between stored integer value and real-world value
% In |BinaryPoint| scaling, the relationship between the stored integer
% value and the real-world value is
%
% $$ \mbox{Real-world value} = (\mbox{Stored integer})\cdot
% 2^{-\mbox{Fraction length}}.$$
%
% There is also |SlopeBias| scaling, which has the relationship
%
% $$ \mbox{Real-world value} = (\mbox{Stored integer})\cdot
% \mbox{Slope}+ \mbox{Bias}$$
%
% where
%
% $$ \mbox{Slope} = (\mbox{Slope adjustment factor})\cdot
% 2^{\mbox{Fixed exponent}}.$$
%
% and
%
% $$\mbox{Fixed exponent} = -\mbox{Fraction length}.$$
%
% The math operators of |fi| work with |BinaryPoint| scaling, but not with
% |SlopeBias| scaling.

%%
%% bin(a), oct(a), dec(a), hex(a)
% return the stored integer in binary, octal, unsigned decimal, and
% hexidecimal strings, respectively.
bin(a)
%%
oct(a)
%%
dec(a)
%%
hex(a)

%% a.bin = ..., a.oct = ..., a.dec = ..., a.hex = ...
% set the stored integer from  binary, octal, unsigned decimal, and
% hexidecimal strings, respectively.
%%
% $$\mbox{\texttt{fi}}(\pi)$$
a.bin = '0110010010001000'
%%
% $$\mbox{\texttt{fi}}(\phi)$$
a.oct = '031707'
%%
% $$\mbox{\texttt{fi}}(e)$$
a.dec = '22268'
%%
% $$\mbox{\texttt{fi}}(0.1)$$
a.hex = '0333'

%% Specifying FractionLength 
% When the |FractionLength| property is not specifyed, it is computed to be
% the best precision for the magnitude of the value and given word length.
% You may also specify the fraction length directly as the fourth numeric
% argument.  In the following, compare the fraction length of |a|, which
% was explicitly set to 0, to the fraction length of |b|, which was set to
% best precision for the magnitude of the value.
a = fi(10,1,16,0)
%%
b = fi(10,1,16)

%%
% Note that the stored integer values of |a| and |b| are different, even
% though their real-world values are the same.  This is because the
% real-world value of |a| is the stored integer scaled by 2^0 = 1, while
% the real-world value of |b| is the stored integer scaled by 2^-11 =
% 0.00048828125.
%%
int(a)
%%
int(b)

%% A(:) = B vs. A = B
% There is a difference between
%
%   A = B
%
% and
%
%   A(:) = B
% 
% In the first case, |A = B| replaces A with B, and A assumes B's numeric
% type.
%
% In the second case, |A(:) = B| assigns the value of B into A, while
% keeping A's numeric type.  This is very handy for casting one numeric
% type into another.
%
% For example, to cast a 16-bit number into an 8-bit number, let
A = fi(0,1,8,7)
%%
B = fi(pi/4,1,16,15)
%%
% Cast B's 16-bit number into A's 8-bit number.
A(:) = B

%% Specifying properties with parameter/value pairs
% Thus far, we have been specifying the numeric type properties by passing
% numeric arguments to the |fi| constructor.  We can also specify
% properties by giving the name of the property as a string followed by the
% value of the property:
a = fi(pi,'WordLength',20)
%%
% For more information on |fi| properties, type
%
%   help fi
%
% or
%
%   doc fi
%
% at the MATLAB command line.

%% Numeric type properties
% All of the numeric type properties of |fi| are encapsulated in an object
% named |numerictype|:
T = numerictype
%%
% The numeric type properties can be modified either when the object is
% created by passing in parameter/value arguments
T = numerictype('WordLength',40,'FractionLength',37)
%%
% or they may be assigned by using the dot notation
T.Signed = false
%%
% All of the numeric type properties of a |fi| may be set at once by
% passing in the |numerictype| object.  This is handy, for example, when
% creating more than one |fi| object that share the same numeric type.
a = fi(pi,'numerictype',T)
%%
b = fi(exp(1),'numerictype',T)
%%
% For more information on |numerictype| properties, type
%
%   help numerictype
%
% or
%
%   doc numerictype
%
% at the MATLAB command line.

%% Display preferences
% The display preferences for |fi| can be set with the |fipref| object.
% They can be saved between MATLAB sessions with the |savefipref| command.

%% Display of real-world values
%
% When displaying real-world values, the closest double-precision
% floating-point value is displayed.  As we have seen, double-precision
% floating-point may not always be able to represent the exact value of
% high-precision fixed-point number.  For example, an 8-bit fractional
% number can be represented exactly in doubles
a = fi(1,1,8,7)
%%
bin(a)
%%
% while a 100-bit fractional number cannot (1 is displayed, when
% the exact value is 1 - 2^-99):
b = fi(1,1,100,99)
%%
% Note, however, that the full precision is preserved in the internal
% representation of |fi|
bin(b)
%%
% The display of the |fi| object is also affected by MATLAB's |format|
% command.  In particular, when displaying real-world values, it is
% handy to use
%
%   format long g
%
% so that as much precision as is possible will be displayed.

%% Display of fi math properties
% Thus far, we have been hiding the display of the properties that control
% math operations, which was the effect of the
%
%   fipref('FiMathDisplay','none')
%
% command at the beginning, and we have been using the default
% full-precision arithmetic.
%
% Now we are ready to explore other math options, so we turn the |fi| math
% display property to |full| so we can monitor the changes in the
% properties.  Note that even when the math properties are not displayed,
% they are still in effect.
fipref('FiMathDisplay','full')
%%
% There are also other display options to make a more shorthand display of
% the numeric type properties, and options to control the display of the
% value (as real-world value, binary, octal, decimal integer, or hex).
%
% For more information on display preferences, type
%
%   help fipref
%   help savefipref
%   help format
%
% or
%
%   doc fipref
%   doc savefipref
%   doc format
%
% at the MATLAB command line.

%% fi math properties
% Similar to the way the |numerictype| object encapsulate the numeric type
% properties of |fi|, the properties that control |fi| math operations are
% encapsulated in an object named |fimath|:
F = fimath
%%
% All of the properties may be modified.
%%
% The |fi| math properties may be modified either when the object is
% created by passing in parameter/value arguments

F = fimath('RoundMode','floor')

%%
% or they may be assigned by using the dot notation

F.OverflowMode = 'wrap'

%%
% All of the |fi| math properties may be set at once at object creation.
% The round mode and the overflow mode are used to quantize the initial
% value, and for all other math operations where rounding and overflow
% apply.

a = fi(pi,'fimath',F)

%% FullPrecision math
% The default is for all math operations to be executed in full precision,
% growing bits in the result as necessary.

%% Full Precision Product Mode
% A full precision product requires a word length equal to the sum of
% the word lengths of the operands.  In the following, note that the
% word length of the product |c| is equal to the word length of |a| plus
% the word length of |b|.  The fraction length of |c| is also equal to
% the fraction length of |a| plus the fraction length of |b|.
a = fi(pi,1,20);
b = fi(exp(1),1,16);
c = a * b

%% MaxProductWordLength
% Even though the maximum word length allowable in |fi| is 65535, it is
% easy to let the precision get away from you, especially in loops, so we
% have the |MaxProductWordLength| property so that you can catch yourself.
% The default value is 128, but you can modify this value for your own
% situation.  In this way, you can ensure that your calculations are never
% being carried out in a higher precision than your hardware allows.  For
% example, if you want all calculations done in full precision, but want to
% ensure that nothing is ever caculated to more precision than your
% hardware is capable of, say 40 bits, then set the maximum product and sum
% word lengths to 40.
%
% For an example of how it is easy to let the word length grow, consider
% the following loop.  The product word length will double each time
% through the loop, so the final product word length will be 16*2^5 = 512.
% In the event that this is not what you intended, an error will be thrown
% when the product word length exceeds the default value of 128. Our code
% has been written to catch and display the error.  If you wish to let the
% word length continue to grow, just set |MaxProductWordLength| to
% something larger than 512.

try
  a = fi(pi);
  for k=1:5
    a = a*a;
  end
catch
  disp(lasterr)
end

%% Full Precision Sum Mode
% A full precision sum requires a word length that grows |log2(n)| bits,
% where |n| is the number of summands.  
%
% For example, if there are |n=2| summands, then |log2(2)=1|, and so the
% sum must grow by one bit.  In this example, the word length of the
% summands |a| and |b| are each 24 bits, and the sum |c| is 25 bits.
a = fi(pi,1,24);
b = fi(exp(1),1,24);
c = a + b

%%
% In this example, we create a random matrix with 8 rows and 2 columns with
% a word length of 20 bits (after first resetting the random number
% generator state for repeatability of the example).
randn('state',0);
A = fi(randn(8,2),1,20)
%%
% The |sum| function sums the 8 elements in each column, so the sum needs
% to grow by |log2(8) = 3| bits to give a sum with a 23 bit word length.
sum(A)

%%
% Note that the + operator can't tell if there are more coming, so that 
%   
%    a+a+a+a
% 
% is different from
%
%    sum([a a a a])
%
% The latter is preferred, because |sum([a a a a])| knows that there are
% four summands, and will only grow log2(4) = 2 bits, while |a+a+a+a|
% will grow 3 bits, one for each +.  The difference is much greater for
% larger n.  The sum of 64 numbers computed as a+a+a+...+a will grow 63
% bits, while sum([a a ... a]) will only grow log2(64) = 6 bits.
%
% For example:
a = fi(pi)
%%
% Note that this sum grows three bits
a+a+a+a
%%
% while this sum can be smarter, and only grows two (and still guarantees
% no overflow)
sum([a a a a])

%% MaxSumWordLength
% Similar to |MaxProductWordLength|, you can also set the maximum value for
% the sum word length so that the precision never exceeds, say, the size of
% the accumulator in your hardware.

%% KeepLSB math
% When the sum or product mode is set to |KeepLSB|, then the
% least-significant bits of the sum or product are
% kept.  If the word length of the result is sufficient to store the full
% precision value, then the value is positioned in the least-significant
% bits of the result.  If the word length is smaller than is necessary to
% store the full precision value, then overflow occurs.  
%
% For example, to simulate arithmetic as it happens in C integers, set the
% product and sum modes to keep the least-significant bits, and the
% overflow mode to wrap.  Even though the ANSI C standard only defines the
% overflow characteristics of unsigned integers (wrap), and does not define
% the behavior of overflow for signed integers, most C implementations use
% wrap (modulo) two's-complement overflow for signed integers.
%
% In this example, we simulate 8-bit signed C integers. 
S8 = numerictype('Signed',1,'WordLength',8,'FractionLength',0)
%%
C8 = fimath('RoundMode','floor','OverflowMode','wrap',...
            'ProductMode','KeepLSB','ProductWordLength',8,...
            'SumMode','KeepLSB','SumWordLength',8)
%% fi(v, T, F)
% Since the numeric type and fi math parameters are commonly passed to
% the |fi| constructor, there is a signature that allows the (value,
% numerictype, fimath) triple to be entered.
%
% Let |a| be an 8-bit signed integer with the math defined like C and an
% initial value of 64.
a = fi(64,S8,C8)
%%
% In full precision math a+a=128, but in wrap two's-complement
% arithmetic, +128 is congruent to -128, as it would be in C:
a+a

%% KeepMSB math
% When the sum or product mode is set to |KeepMSB|, then the
% most-significant bits of the sum or product are
% kept.  If the word length of the result is sufficient to store the full
% precision value, then the value is positioned in the most-significant
% bits of the result.  If the word length is smaller than is necessary to
% store the full precision value, then rounding occurs.  
%
% Most fixed-point processors produce a product that has twice as many bits
% as its operands so that no quantization occurs during the computation of
% the product. However, some do not, such as the Zilog Z893xx, which
% accepts 16-bit operands, but produces a 24-bit result rather than the
% 32-bit result required for full precision.  To simulate this processor,
% we would set the |ProductMode| to |KeepMSB|, and the |ProductWordLength|
% to 24:
Z893math = fimath('ProductMode','KeepMSB','ProductWordLength',24);
a = fi(0.1,1,16,16,'fimath',Z893math)
%%
% Note that the quantized product is the 24 most-significant bits of the
% product.
a*a

%% 
% Also, many textbooks do roundoff error analysis for "single-precision"
% fixed-point products and sums with fractional numbers. In this example, we
% simulate 8-bit unsigned fractional numbers (all values between 0 and 1).
U8 = numerictype('Signed',0,'WordLength',8,'FractionLength',8)
%%
F8 = fimath('ProductMode','KeepMSB','ProductWordLength',8,...
            'SumMode','KeepMSB','SumWordLength',8)
%%
% Let |a| be an 8-bit unsigned fractional number with fractional arithmetic
% that quantizes products and sums to keep the most-significant bits.
a = fi(0.1, U8, F8)
%%
% In the following, note that a product that is also a fractional number
% has been produced, and the 8 most-significant bits have been retained.
a*a

%% SpecifyPrecision math
% When we want full control over the math operations, we set the product or
% sum mode to SpecifyPrecision, and then fully specify the word length and
% fraction length of the result.
F = fimath('ProductMode','SpecifyPrecision',...
           'ProductWordLength',24,...
           'ProductFractionLength',23,...
           'SumMode','SpecifyPrecision',...
           'SumWordLength',40,...
           'SumFractionLength',23)
%%
a = fi(pi/4,'fimath',F)
%%
b = fi(exp(1)/4,'fimath',F)
%%
% Then the products will always be 24,23
a*b
%%
% And the sums will always be 40,23
a+b

%% CastBeforeSum
% Unfortunately, there is no += operator in MATLAB, so in order to simulate
% the accumulation of sums, such as might be done in this code snippet from
% C, we have the |CastBeforeSum| parameter.
%
%   acc  = a;
%   acc += b;
% 
% When |CastBeforeSum| is true (1), then the operands are cast to the
% numeric type of the sum before the addition takes place.  This behavior
% models most DSP chips.
%
% When |CastBeforeSum| is false (0), then the operands are added in full
% precision, and then cast to the numeric type of the sum.  This behavior
% models many ASIC or FPGA implementations.
%
% The difference only matters when the numeric type of the sum has less
% precision or range than the numeric types of the operands.
%
% Here is a simple example.  Let the numeric type of the sum be an integer
% (the fraction length is zero), and let the operands have one fractional
% bit that would sum to be an integer.  If the operands were cast to the
% numeric type of the sum before addition, then the fractional bit would be
% lost before the addition.  If the operands were added and then cast to
% the numeric type of the sum, then the fractional bits would be
% significant.
F = fimath('RoundMode','floor',...
            'SumMode','SpecifyPrecision',...
           'SumWordLength',16,'SumFractionLength',0,...
           'CastBeforeSum',true)
%%
a = fi(0.5,'fimath',F)
%%
% In the following, the 0.5 gets quantized to 0 before the addition
% takes place, and so the sum is 0
a + a

%%
% Now, set |CastBeforeSum| to true and repeat the experiment.  Note that
% the |fi| math parameters can be changed on a |fi| variable at any time
a.CastBeforeSum = false
%%
% Now the sum 0.5+0.5 = 1 gets done first, and then is
% cast to an integer, so the sum is 1.
a + a

%% Math with other built-in data types.
%% fi * double
% When doing arithmetic between |fi| and |double|, the double is cast to a
% |fi| with the same word length and signedness of the |fi|, and
% best-precision fraction length.  The result of the operation is a |fi|.
a = fi(pi);
b = 0.5 * a

%% Some differences between fi and C
% Note that in C, the result of an operation between a integer data type
% with a double data type will promote to a double.  
%
% However, in MATLAB, the result of an operation between a built-in
% integer data type with a double data type will be an integer.  In this
% respect, the |fi| object behaves like the built-in integer data types
% in MATLAB: the result of an operation between a |fi| and a double is a
% |fi|.

%% fi * int8
% When doing arithmetic between fi and one of the built-in integer data
% types [u]int[8,16,32], then the word length and signedness of the the
% integer are preserved.  The result of the operation is a fi.
a = fi(pi);
b = int8(2) * a


%%
% Copyright 2004 The MathWorks, Inc.

%%
% $Revision: 1.1.6.1 $

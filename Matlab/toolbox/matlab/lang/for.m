%FOR    Repeat statements a specific number of times.
%   The general form of a FOR statement is:
% 
%      FOR variable = expr, statement, ..., statement END
% 
%   The columns of the expression are stored one at a time in
%   the variable and then the following statements, up to the
%   END, are executed. The expression is often of the form X:Y,
%   in which case its columns are simply scalars. Some examples
%   (assume N has already been assigned a value).
% 
%        FOR I = 1:N,
%            FOR J = 1:N,
%                A(I,J) = 1/(I+J-1);
%            END
%        END
% 
%   FOR S = 1.0: -0.1: 0.0, END steps S with increments of -0.1
%   FOR E = EYE(N), ... END  sets E to the unit N-vectors.
%
%   Long loops are more memory efficient when the colon expression appears
%   in the FOR statement since the index vector is never created.
%
%   The BREAK statement can be used to terminate the loop prematurely.
%
%   See also IF, WHILE, SWITCH, BREAK, CONTINUE, END.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:16:36 $
%   Built-in function.

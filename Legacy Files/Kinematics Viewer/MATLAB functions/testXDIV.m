function testXDIV
% TESTXDIV  Testing function CROSSDIV
%    Example:
%    To perform a series of tests of function CROSSDIV, use
%    TESTXDIV (without arguments)

format compact;

A1 = rand(0, 3);
B1 = rand(0, 3);

A2 = [1 0 0];
B2 = [0 1 0];

A3 = [1 0 0]';
B3 = [0 1 0]';

A4 = rand(2,3);
B4 = rand(2,3);

A5 = rand(3,2);
B5 = rand(3,2);

A6 = rand(1,1,3);
B6 = rand(1,1,3);

A7 = rand(1,3,1,3);
B7 = rand(1,3,1,3);

for i=1:7
    NameA = ['A' int2str(i)];
    NameB = ['B' int2str(i)];
    eval(['test(' NameA ',' NameB ')']);
end
for i=1:7
    NameA = ['A' int2str(i)];
    NameB = ['B' int2str(i)];
    eval(['testDIM(' NameA ',' NameB ')']);
end

function test(A,B)
disp ' '
disp '----------------------------------------------------------------'
disp '                   TESTING FUNCTION CROSSDIV                    '
disp '                   SizeA: size of A, B and C                    '
disp '----------------------------------------------------------------'
disp ' '
C = cross(A, B);
A = cross(B, C); % a and b are now orthogonal
C = cross(A, B);
A
disp ' '
B
disp ' '
SizeA = size(A)
Anorm = crossdiv(C, B);
disp ' '
if any( (abs(Anorm-A)) > 2*eps)
    disp ':-('
    disp ':-(   CROSSDIV(C, B) includes some vector not equal to Anorm'
    disp ':-('    
else
    disp ':-)'    
    disp ':-)   all vectors in CROSSDIV(C, B) are equal to Anorm (or NaN)'
    disp ':-)'    
end
pause
disp ' '
disp ' '

function testDIM(A,B)
disp ' '
disp '****************************************************************'
disp '                   TESTING FUNCTION CROSSDIV                    '
disp '                   SizeA: size of A, B and C                    '
disp '****************************************************************'
disp ' '
SizeA = size(A);
dims = find(SizeA==3);
for d = 1 : length(dims)
    DIM = dims(d);
    disp ' '
    disp '--------------------'
    DIM
    disp '--------------------'
    C = cross(A, B, DIM);
    A = cross(B, C, DIM); % a and b are now orthogonal
    C = cross(A, B, DIM);
    A
    disp ' '
    B
    disp ' '
    SizeA
    Anorm = crossdiv(C, B, DIM);
    disp ' '
    if any( (abs(Anorm-A)) > 2*eps)
        disp ':-('
        disp ':-(   CROSSDIV(C, B) includes some vector not equal to Anorm'
        disp ':-('
    else
        disp ':-)'
        disp ':-)   all vectors in CROSSDIV(C, B) are equal to Anorm (or NaN)'
        disp ':-)'
    end
    pause
end
disp ' '
disp ' '

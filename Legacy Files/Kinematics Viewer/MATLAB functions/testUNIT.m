function testUNIT
% TESTUNIT  Testing function UNIT
%    Example:
%    To perform a series of tests of function UNIT, use
%    TESTUNIT (without arguments)

format compact;

% Empty arrays
A1=[];            
A2=rand(3,0);     
A3=A2';
A4=rand(5,0,0,0); 
A5=rand(0,0,0,5); 

% Matrices (2D arrays)
A6=0;                
A7=[0 0 0];           
A8=A7';
A9=[0 0 3];           
A10=A9';
A11=[0 0 3
     0 0 4
     0 0 5];           
A12=A11';
A13=[0 0 3
     0 0 0
     0 0 0];           
A14=A13';
A15=[4 0 3
     0 0 0
     3 0 4];           
A16=rand(3,3)* 1e15;   
A17=rand(1,6)* 1e-15;  
A18=A17';
A19=rand(6,6)* 1e15;   

% Multidimensional arrays
A20=rand(1,1,6);         
A21=rand(1,1,1,6,1,4);  
A22=rand(3,1,1,6,1,2);  

for i=1:22
    eval(['test(A' int2str(i) ')']);
end
for i=1:22
    eval(['testDIM(A' int2str(i) ')']);
end

function test(A)
disp ' '
disp '----------------------------------------------------------------'
disp '                   TESTING FUNCTION UNIT                        '
disp 'SizeA: size of A, UnitA: normalized A, MagnU: magnitude of UnitA'
disp '----------------------------------------------------------------'
disp ' '
A
SizeA = size(A)
UnitA = unit(A)
MagnU = magn(UnitA)
disp ' '
if any( (abs(MagnU(:)-1)) > 2*eps)
    disp ':-('
    disp ':-(   There''s some vector in UnitA with magnitude not equal to 1'
    disp ':-('    
else
    disp ':-)'    
    disp ':-)   All vectors in UnitA have magnitude 1 (or NaN)'
    disp ':-)'    
end
pause
disp ' '
disp ' '

function testDIM(A)
disp ' '
disp '****************************************************************'
disp '                   TESTING FUNCTION UNIT                        '
disp '                          PHASE 2                               '
disp '           ------> (USING PARAMETER DIM) <------                '
disp 'SizeA: size of A, UnitA: normalized A, MagnU: magnitude of UnitA'
disp '****************************************************************'
disp ' '

for DIM = 1 : ndims(A)+1
    disp ' '
    disp '--------------------'
    DIM
    disp '--------------------'
    A
    SizeA = size(A)
    UnitA = unit(A, DIM)
    MagnU = magn(UnitA, DIM)
    disp ' '
    if any( (abs(MagnU(:)-1)) > 2*eps)
        disp ':-('
        disp ':-(   There''s some vector in UnitA with magnitude not equal to 1'
        disp ':-('
    else
        disp ':-)'
        disp ':-)   All vectors in UnitA have magnitude 1 (or NaN)'
        disp ':-)'
    end
pause
end
disp ' '
disp ' '

        
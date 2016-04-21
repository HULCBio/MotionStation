%COMPUTER Computer type.
%   C = COMPUTER returns string C denoting the type of computer
%   on which MATLAB is executing. Possibilities are:
%
%                                               ISPC       ISUNIX       
%   PCWIN       - MS-Windows                      1           0
%   SOL2        - Sun Sparc  (Solaris 2)          0           1 
%   HPUX        - HP PA-RISC (HP-UX 11.00)        0           1
%   GLNX86      - Linux on PC compatible          0           1
%   GLNXI64     - Linux on Intel Itanium2         0           1
%   MAC         - Macintosh OS X                  0           1
% 
%   [C,MAXSIZE] = COMPUTER also returns integer MAXSIZE which 
%   contains the maximum number of elements allowed in a matrix
%   on this version of MATLAB.
%
%   [C,MAXSIZE,ENDIAN] = COMPUTER also returns either 'L' for
%   little endian byte ordering or 'B' for big endian byte ordering.
%
%   HP700, ALPHA, IBM_RS and SGI are no longer supported as of R14.

%   See also ISPC, ISUNIX.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/01/08 19:16:48 $
%   Built-in function.


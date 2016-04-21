function mapleinit(arg)
%MAPLEINIT MEX file initialization of the Maple Kernel.
%   MAPLEINIT is called by MAPLEMEX to initialize the Maple Kernel. 
%   It should never be run directly by itself.
%
%   MAPLEINIT determines the path to the directory containing the Maple
%   Library, loads the linear algebra package, initializes Digits,
%   and establishes several aliases. 
%
%   This M-file, "symbolic/mapleinit.m", may be modified to access
%   a previously installed copy of the Maple 8 Library.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.39.4.2 $  $Date: 2004/04/16 22:23:26 $

%   If you have a copy of the Library for Maple 8 and wish to save
%   disk space by linking to it instead of the libraries we provide,
%   you can try the following:
%
%   1)  Modify the following code to set "maplelib" to the full
%       path name of that library, e.g. maplelib = '/usr/local/Maple/lib',
%       or maplelib = 'C:MAPLE\LIB', or maplelib = 'MyDisk:Maple:Lib'.
%   2)  If the Symbolic Toolbox seems to work properly, you can 
%       delete the copy of the Maple Library that is distributed with MATLAB.
%
%   Also note that this version of MATLAB has been qualified for use with
%   Maple 8, modifying the code to use a different version of the Maple
%   libraries may prevent the Symbolic Toolbox from functioning properly.
%
%   EDIT the following three lines if you already have a copy of the Library.

already_have_Maple = 0;
if (already_have_Maple)
   maplelib = '.....';
else
%  Set library path to the Maple library
   maplelib = which('mapleinit');
   maplelib = [maplelib(1:findstr(maplelib,'mapleinit')-1) '@symlibs'];
end

% Must be called by maplemex.
if (nargin < 1) | ~strcmp(arg,'maplemex')
   error('symbolic:mapleinit:errmsg1','mapleinit must be called by maplemex')
end

% Inform Maple of path to its library.
maplemex(maplelib,0);

% Load libraries, set digits.
maplemex('with(linalg):');
maplemex('readlib(ifactor):');
maplemex('with(inttrans):');
maplemex('readlib(ztrans):');
maplemex('readlib(hypergeom):');
maplemex('with(codegen):');
maplemex('Digits := 32;');

% Establish aliases.
maplemex('interface(imaginaryunit=i);');
maplemex('alias(pi=Pi, eye=&*());');
maplemex('alias(log=ln, fix=trunc);');
maplemex('alias(asin=arcsin, acos=arccos, atan=arctan);');
maplemex('alias(asinh=arcsinh, acosh=arccosh, atanh=arctanh);');
maplemex('alias(acsc=arccsc, asec=arcsec, acot=arccot);');
maplemex('alias(acsch=arccsch, asech=arcsech, acoth=arccoth);');
maplemex('alias(besselj=BesselJ, bessely=BesselY);');
maplemex('alias(besseli=BesselI, besselk=BesselK);');
maplemex('alias(sinint=Si, cosint=Ci, lambertw=LambertW, zeta=Zeta);');
maplemex('alias(gamma=GAMMA, eulergamma=gamma, conj=conjugate);');
maplemex('alias(dirac=Dirac, heaviside=Heaviside, array=ARRAY);');

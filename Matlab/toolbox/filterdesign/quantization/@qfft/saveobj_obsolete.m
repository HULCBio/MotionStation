function F = saveobj(F)
%SAVEOBJ Save filter for objects.
%
%   Obsolete.  

%   B = SAVEOBJ(A) is called by SAVE when an object is saved to a .MAT
%   file. The return value B is subsequently used by SAVE to populate the
%   .MAT file.  SAVEOBJ can be used to convert an object that maintains 
%   informaton outside the object array into saveable form (so that a
%   subsequent LOADOBJ call to recreate it).
%
%   SAVEOBJ will be separately invoked for each object to be saved.
%
%   See also SAVE, LOADOBJ.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:27:19 $

% Replace each Java quantizer with a structure that contains the states of the
% Java quantizer.  We are not saving the Java object directly because if the
% Java object changes after it is saved, it is very difficult to reconstruct
% a new one.  The QUANTIZER/SAVEOBJ method is used to convert the quantizers
% to saveable form.
F.coefficientformat = saveobj(F.coefficientformat);
F.inputformat = saveobj(F.inputformat);
F.outputformat = saveobj(F.outputformat);
F.multiplicandformat = saveobj(F.multiplicandformat);
F.productformat = saveobj(F.productformat);
F.sumformat = saveobj(F.sumformat);

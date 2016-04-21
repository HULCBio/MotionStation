function h = saveobj(h)
%SAVEOBJ Save filter for objects.
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
%   $Revision: 1.7 $  $Date: 2002/04/14 15:31:30 $

% Replace each UDD quantizer with a structure that contains the states of the
% quantizer.  We are not saving the UDD object directly because if the
% Java object changes after it is saved, it is very difficult to reconstruct
% a new one.  The QUANTIZER/SAVEOBJ method is used to convert the quantizers
% to saveable form.
% $$$ h.coefficientformat = saveobj(h.coefficientformat);
% $$$ h.inputformat = saveobj(h.inputformat);
% $$$ h.outputformat = saveobj(h.outputformat);
% $$$ h.multiplicandformat = saveobj(h.multiplicandformat);
% $$$ h.productformat = saveobj(h.productformat);
% $$$ h.sumformat = saveobj(h.sumformat);

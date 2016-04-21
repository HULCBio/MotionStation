function t=isthss(th)
%ISTHSS Tests if the model structure is of state-space type.
%   OBSOLETE function use isa(TH,'idss') or isa(TH,'idgrey') instead.
%
%   t = isthss(TH)
%
%   TH: The model structure in the THETA-format (See help theta)
%   t is true if TH is of state-space type, else false

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:39 $

t = (isa(th,'idss')|isa(th,'idarx')|isa(th,'idgrey'));



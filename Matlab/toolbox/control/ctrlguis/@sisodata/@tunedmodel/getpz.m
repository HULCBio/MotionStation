function [Zeros,Poles] = getpz(CompData)
%GETPZ  Returns vectors of poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 04:54:34 $

if isempty(CompData.PZGroup)
    Zeros = zeros(0,1);
    Poles = zeros(0,1);
else
    Zeros = get(CompData.PZGroup,{'Zero'});
    Zeros = cat(1,Zeros{:});
    Poles = get(CompData.PZGroup,{'Pole'});    
    Poles = cat(1,Poles{:});
end

function updateABCD(this,ind) 
% GETABCD - Get the state matricies of a linearization

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:09:30 $

% Allow the inspector data to be updated.
this.DiscardUpdate = false;
if ~isempty(this.allA)
    this.A = this.allA(:,:,ind);
end
if ~isempty(this.allB)
    this.B = this.allB(:,:,ind);
end
if ~isempty(this.allC)
    this.C = this.allC(:,:,ind);
end
if ~isempty(this.allD)
    this.D = this.allD(:,:,ind);
end
this.DiscardUpdate = true;
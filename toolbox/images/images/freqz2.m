function [Hout,Fx,Fy] = freqz2(varargin)
%FREQZ2 Compute two-dimensional frequency response.
%   [H,Fx,Fy] = FREQZ2(h,Nx,Ny) returns H, the Ny-by-Nx frequency response
%   of h, and the frequency vectors Fx (of length Nx) and Fy (of length
%   Ny). h is a two-dimensional FIR filter, in the form of a computational
%   molecule. Fx and Fy are returned as normalized frequencies in the range
%   -1.0 to 1.0, where 1.0 corresponds to half the sampling frequency, or pi
%   radians.
%
%   [H,Fx,Fy] = FREQZ2(h,[Ny Nx]) returns the same result as [H,Fx,Fy] =
%   FREQZ2(h,Nx,Ny).
%
%   [H,Fx,Fy] = FREQZ2(h,N) uses [Ny Nx] = [N N].
%
%   [H,Fx,Fy] = FREQZ2(h) uses [Ny Nx] = [64 64].
%
%   [H,Fx,Fy] = FREQZ2(h,[Ny Nx],[Dx Dy]) or FREQZ2(h,Nx,Ny,[Dx Dy]) uses
%   [Dx Dy] to specify the intersample spacing in h. Dx is the spacing in
%   the X (or column) dimension, and Dy is the spacing in the Y (or row)
%   dimension.  The default value for Dx and Dy is 0.5.  Changing Dx and Dy
%   has the effect of changing the spread of values in Fx and Fy.  For
%   example, setting Dx to 0.25 instead of 0.5 causes the values in Fx to
%   range from -2.0 to 2.0 instead of -1.0 to 1.0.  Setting Dy to 1.0
%   instead of 0.5 causes Fy to range from -0.5 to 0.5 instead of -1.0 to
%   1.0.
%
%   FREQZ2(h,[Ny Nx],D) and FREQZ2(h,Nx,Ny,D) use [Dx Dy] = [D D].
%
%   H = FREQZ2(h,Fx,Fy) returns the frequency response for the FIR filter h
%   at frequency values in Fx and Fy. These frequency values should be in
%   the range -1.0 to 1.0, where 1.0 corresponds to half the sampling
%   frequency, or pi radians.
%
%   When used with no output arguments, FREQZ2(...) produces a mesh plot of
%   the two-dimensional frequency response.
%
%   Class Support
%   -------------
%   The input matrix h can be of class double or of any numeric class. All
%   other inputs to freqz2 must be of class double. All outputs are of class
%   double.
%
%   Example
%   -------
%   Use the window method to create a 16-by-16 filter, then view its
%   frequency response using FREQZ2.
%
%       Hd = zeros(16,16);
%       Hd(5:12,5:12) = 1;
%       Hd(7:10,7:10) = 0;
%       h = fwind1(Hd,bartlett(16));
%       freqz2(h,[32 32]); axis([-1 1 -1 1 0 1]); colormap(jet(64))
%
%   See also FREQZ.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.20.4.1 $  $Date: 2003/01/26 05:55:22 $

[a,Nx,Ny,Dx,Dy,Fx,Fy,spacing] = ParseInputs(varargin{:});

post_scale_frequencies = 0;
% If equal spacing is specified, but a is too small, switch to the meshgrid
% frequency method.
if any(size(a) > [Ny Nx])
    spacing = 'meshgrid';
    Fx = 2*((0:Nx-1)-floor(Nx/2))/Nx;
    Fy = 2*(((0:Ny-1)-floor(Ny/2))/Ny)';
    post_scale_frequencies = 1;
end

a = rot90(a,-2); % Unrotate filter since FIR filters are rotated.

switch spacing
  case 'equal'
    % What is the "center" element of a?  Use ceil here instead of the
    % usual floor because a has already been rotated.
    center_a = ceil((size(a) + 1)/2);
    
    % Pad A if necessary
    if any(size(a) < [Ny Nx])
        a(Ny,Nx) = 0.0;
    end
    
    % Now circularly shift a to put the center element at the upper left
    % corner.
    row_indices = [center_a(1):Ny, 1:(center_a(1)-1)]';
    col_indices = [center_a(2):Nx, 1:(center_a(2)-1)]';
    a = a(row_indices, col_indices);
    
    Fx =  ((0:Nx-1)-floor(Nx/2))/(Nx*Dx);
    Fy = (((0:Ny-1)-floor(Ny/2))/(Ny*Dy))';
    H = fftshift(fft2(a));
    
  case 'meshgrid'
    % Expand Fx and Fy if they are vectors
    if (min(size(Fx)) == 1) | (min(size(Fy)) == 1)
        [Fx,Fy] = meshgrid(Fx,Fy);
    end
    
    [t1,t2] = freqspace(size(a)); 
    t1 = t1*size(a,2)/2; 
    t2 = t2*size(a,1)/2;
    [t1,t2] = meshgrid(t1,t2);

    H = zeros(size(Fx));
    j = sqrt(-1);
    % In previous versions of this function this next computation was
    % fully vectorized, but it used far too much memory even for modest
    % size problems.
    for p = 1:size(H,1)
        for q = 1:size(H,2)
            H(p,q) = sum(sum(exp(-j*pi*(Fx(p,q)*t1 + Fy(p,q)*t2)) .* a));
        end
    end
    
end

% Convert to real if possible
if all(max(abs(imag(H)))<sqrt(eps)) 
    H = real(H); 
end

% Also check if the response is all imaginary
if all(max(abs(real(H)))<sqrt(eps))
    H = complex(0,imag(H));
end

if nargout==0, % Plot data
    mesh(Fx,Fy,abs(H))
    xlabel('F_x'), ylabel('F_y'), zlabel('Magnitude')
    return
end
Hout = H;
Fx = Fx(1,:)';
Fy = Fy(:,1);
if post_scale_frequencies
    Fx = Fx / 2 / Dx;
    Fy = Fy / 2 / Dy;
end

function [a,Nx,Ny,Dx,Dy,Fx,Fy,spacing] = ParseInputs(varargin)

% Set up defaults;
a = [];
Nx = 64;
Ny = 64;
Dx = 0.5;
Dy = 0.5;
Fx = [];
Fy = [];
spacing = '';

checknargin(1,4,nargin,mfilename);

a = varargin{1};
checkinput(a,{'numeric'},{},mfilename,'h',1);
% Allow other numeric types for first input argument
if ~isa(a,'double')
    a = double(a);
end

switch nargin
  case 1
    % FREQZ2(H)
    spacing = 'equal';
    
  case 2
    % FREQZ2(H,N)  or FREQZ2(H,[Nx Ny])
    spacing = 'equal';
    switch prod(size(varargin{2}))
      case 1
        % FREQZ2(H,N)
        Nx = varargin{2};
        Ny = Nx;
        
      case 2
        % FREQZ2(H,[Ny Nx])
        Nx = varargin{2}(2);
        Ny = varargin{2}(1);
        
      otherwise
        msg = sprintf('%s: With two input arguments, the second input must be a scalar or two-element vector.',...
                      upper(mfilename));
        eid = sprintf('Images:%s:with2Inputs2ndMustBe2ElemVectOrScalar',mfilename);
        error(eid, msg);          
    end
    
  case 3
    % FREQZ2(H,Nx,Ny) or FREQZ2(H,Fx,Fy)
    if (prod(size(varargin{2})) == 1) & (prod(size(varargin{3})) == 1)
        % FREQZ2(H,Nx,Ny)
        spacing = 'equal';
        Nx = varargin{2};
        Ny = varargin{3};
        
    else
        % FREQZ2(H,Fx,Fy)
        spacing = 'meshgrid';
        Fx = varargin{2};
        Fy = varargin{3};
    end
    
  case 4
    % FREQZ2(H,Nx,Ny,Dx)
    if (prod(size(varargin{2})) == 1) & (prod(size(varargin{3})) == 1)
        spacing = 'equal';
        Nx = varargin{2};
        Ny = varargin{3};
        
        switch prod(size(varargin{4}))
          case 1
            Dx = varargin{4};
            Dy = Dx;
            
          case 2
            Dx = varargin{4}(1);
            Dy = varargin{4}(2);
            
          otherwise
            msg = sprintf('%s: The fourth input argument must be a scalar or a two-element vector.',...
                          upper(mfilename));
            eid = sprintf('Images:%s:fourthInputMustBe2ElemVectOrScalar',mfilename);
            error(eid, msg);          
        end

    else
        % The old input parsing for this function allowed the user to
        % call with this syntax: FREQZ2(H,Fx,Fy,Dx), but Dx was ignored
        % in this case.  Allow this usage but issue a warning message.
        msg = sprintf('%s: Dx has no effect when you pass in Fx and Fy.',...
                       upper(mfilename));
        wid = sprintf('Images:%s:dxNotNeededWhenFxFyAreThere',mfilename);
        warning(wid, msg);          
        Fx = varargin{2};
        Fy = varargin{3};
        spacing = 'meshgrid';
    end
end

% Additional error checking
if (Dx <= 0) | (Dy <= 0)
    msg = sprintf('%s: Dx and Dy must be positive scalars.',...
                  upper(mfilename));
    eid = sprintf('Images:%s:DxDyMustBePositiveScalars',mfilename);
    error(eid, msg);          
end

switch spacing
  case 'equal'
    if (Nx <= 0) | (Ny <= 0) | (floor(Nx) ~= Nx) | (floor(Ny) ~= Ny)
        msg = sprintf('%s: Nx and Ny must be positive integers.',...
                      upper(mfilename));
        eid = sprintf('Images:%s:NxNyMustBePositiveIntegers',mfilename);
        error(eid, msg);          
    end
    
  case 'meshgrid'
    if (min(prod(size(Fx))) ~= 1) | (min(prod(size(Fy))) ~= 1)
        if ~isequal(size(Fx), size(Fy))
            msg = sprintf('%s: If Fx and Fy are not vectors, they must be the same size.',...
                          upper(mfilename));
            eid = sprintf('Images:%s:ifFxFyNotVectorsThenMustBeSameSize',mfilename);
            error(eid, msg);          
        end
    end
            
  otherwise
      msg = sprintf('%s: Internal problem: spacing not set in ParseInputs.',...
                    upper(mfilename));
      eid = sprintf('Images:%s:internalProblemSpacingNotSet',mfilename);
      error(eid, msg);          
end

        

        
    
function x = wextend(type,mode,x,lf,location)
%WEXTEND Extend a Vector or a Matrix.
%
%   Y = WEXTEND(TYPE,MODE,X,L,LOC) or
%   Y = WEXTEND(TYPE,MODE,X,L)
%
%   The valid extension types (TYPE) are:
%     1,'1','1d' or '1D'    : 1-D extension
%     2,'2','2d' or '2D'    : 2-D extension 
%     'ar' or 'addrow'      : add rows  
%     'ac' or 'addcol       : add columns   
%
%   The valid extension modes (MODE) are:
%     'zpd' zero extension.
%     'sp0' smooth extension of order 0.
%     'spd' (or 'sp1') smooth extension of order 1.
%     'sym' (or 'symh') symmetric extension (half-point).
%     'symw' symmetric extension (whole-point).
%     'asym' (or 'asymh') antisymmetric extension (half-point).
%     'asymw' antisymmetric extension (whole-point).
%     'ppd' periodized extension (1).
%     'per' periodized extension (2):
%        If the signal length is odd, WEXTEND adds an extra-sample
%        equal to the last value on the right and performs extension
%        using the 'ppd' mode. Otherwise, 'per' reduces to 'ppd'.
%        The same kind of rule stands for images.
%
%   With TYPE = {1,'1','1d' or '1D'}: 
%     LOC = 'l' (or 'u') for left (up) extension.
%     LOC = 'r' (or 'd') for right (down) extension.
%     LOC = 'b' for extension on both sides.
%     LOC = 'n' nul extension
%     The default is LOC = 'b'.
%     L is the length of the extension.
%
%   With TYPE = {'ar','addrow'}
%     LOC is a 1D extension location.
%     The default is LOC = 'b'.
%     L is the number of rows to add.
%
%   With TYPE = {'ac','addcol'}
%     LOC is a 1D extension location.
%     The default is LOC = 'b'.
%     L is the number of columns to add.
%
%   With TYPE = {2,'2','2d' or '2D'}:
%     LOC = [locrow,loccol] where locrow and loccol are 1D
%     extension locations or 'n' (none).
%     The default is LOC = 'bb'.
%     L = [lrow,lcol] where lrow is the number of rows 
%     to add and lcol is the number of columns to add.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Nov-97.
%   Last Revision: 14-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/03/15 22:42:42 $

type = lower(type);

switch type
  case {1,'1','1d'}
      if nargin<5 , loc = 'b'; else , loc = testLoc(location); end
      if isequal(loc,'n') , return; end
      isROW = (size(x,1)<2);
      x  = x(:)';
      sx = length(x);
      switch mode
        case 'zpd'            % Zero Padding.
          [ext_L,ext_R] = getZPD_ext(1,lf,loc);
          x = [ext_L x ext_R];

        case {'sym','symh'}   % Half-point Symmetrization .
          I = getSymIndices(sx,lf,loc);
          x  = x(I);

        case {'symw'}         % Whole-point Symmetrization.
          x = WP_SymExt(x,lf,loc);
          
        case {'asym','asymh'} % Half-point Anti-Symmetrization.
          x = HP_AntiSymExt(x,lf,loc);  

        case {'asymw'}        % Whole-point Anti-Symmetrization.
          x = WP_AntiSymExt(x,lf,loc);  

        case 'sp0'            % Smooth padding of order 0.
          [ext_L,ext_R] = getSP0_ext('row',x(1),x(sx),lf,loc);
          x = [ext_L x ext_R];

        case {'spd','sp1'}    % Smooth padding of order 1.
          if sx<2 , d = 0; else , d = 1; end
          d_L = x(1)-x(1+d);
          d_R = x(sx)-x(sx-d);
          [ext_L,ext_R] = getSP1_ext('row',x(1),x(sx),d_L,d_R,lf,loc);                  
          x = [ext_L x ext_R];

        case {'ppd'}          % Periodization.
          I = getPerIndices(sx,lf,loc);
          x = x(I);

        case {'per'}          % Periodization.
          if rem(sx,2) , x(sx+1) = x(sx); sx = sx+1; end
          I = getPerIndices(sx,lf,loc);
          x = x(I);

        otherwise
          errargt(mfilename,'Invalid Extension Mode for DWT!','msg');
          error('*')
      end
      if ~isROW , x = x'; end

  case {2,'2','2d'}
      if nargin<5
          locRow = 'b'; locCol = 'b';
      else
          if length(location)<2 , location(2) = location(1); end
          locRow = testLoc(location(1)); 
          locCol = testLoc(location(2));
      end
      if length(lf)<2 , lf = [lf , lf]; end
      [rx,cx] = size(x); 
      switch mode
        case 'zpd'            % Zero Padding.
            if ~isequal(locCol,'n') ,
                [ext_L,ext_R] = getZPD_ext(rx,lf(2),locCol);
                x  = [ext_L x ext_R];
            end
            if ~isequal(locRow,'n') ,
                cx = size(x,2);
                [ext_L,ext_R] = getZPD_ext(lf(1),cx,locRow);
                x = [ext_L ; x ; ext_R];
            end

        case {'sym','symh'}   % Symmetrization half-point.
            if ~isequal(locCol,'n') ,
                I = getSymIndices(cx,lf(2),locCol); x = x(:,I);
            end
            if ~isequal(locRow,'n') ,
                I = getSymIndices(rx,lf(1),locRow); x = x(I,:);
            end

        case {'symw'}         % Symmetrization whole-point.
            if ~isequal(locCol,'n') ,
                x = WP_SymExt(x,lf(2),locCol);
            end
            if ~isequal(locRow,'n') ,
                x = WP_SymExt(x',lf(1),locRow); x = x';
            end
          
        case {'asym','asymh'} % Half-point Anti-Symmetrization.
          if ~isequal(locCol,'n') , 
              x = HP_AntiSymExt(x,lf(2),locCol);
          end
          if ~isequal(locRow,'n') , 
              x = HP_AntiSymExt(x',lf(1),locRow); x = x';
          end

        case {'asymw'}        % Whole-point Anti-Symmetrization.
            if ~isequal(locCol,'n') , 
                x = WP_AntiSymExt(x,lf(2),locCol);
            end
            if ~isequal(locRow,'n') , 
                x = WP_AntiSymExt(x',lf(1),locRow); x = x';
            end

        case 'sp0'            % Smooth padding of order 0.
            if ~isequal(locCol,'n') ,   
                [ext_L,ext_R] = getSP0_ext('row',x(:,1),x(:,cx),lf(2),locCol);
                x = [ext_L x ext_R];
            end
            if ~isequal(locRow,'n') , 
                [ext_L,ext_R] = getSP0_ext('col',x(1,:),x(rx,:),lf(1),locRow);
                x = [ext_L ; x ; ext_R];
            end

        case {'spd','sp1'}    % Smooth padding of order 1.
            if ~isequal(locCol,'n') ,   
                if cx<2 , d = 0; else , d = 1; end
                d_L = x(:,1) - x(:,1+d);
                d_R = x(:,cx)- x(:,cx-d);
                [ext_L,ext_R] = getSP1_ext('row',x(:,1),x(:,cx),d_L,d_R,lf(2),locCol);
                x = [ext_L x ext_R];
            end
            if ~isequal(locRow,'n') , 
                if rx<2 , d = 0; else , d = 1; end          
                d_L = x(1,:) - x(1+d,:);
                d_R = x(rx,:)- x(rx-d,:);        
                [ext_L,ext_R] = getSP1_ext('col',x(1,:),x(rx,:),d_L,d_R,lf(1),locRow);
                x = [ext_L ; x ; ext_R];
            end

        case 'ppd'            % Periodization.
            if ~isequal(locCol,'n') ,   
                I = getPerIndices(cx,lf(2),locCol); x = x(:,I);
            end
            if ~isequal(locRow,'n') , 
                I = getPerIndices(rx,lf(1),locRow); x = x(I,:);
            end

        case 'per'            % Periodization.
            if ~isequal(locCol,'n') ,   
                if rem(cx,2) , x(:,cx+1) = x(:,cx); cx = cx+1; end
                I = getPerIndices(cx,lf(2),locCol); x = x(:,I);
            end
            if ~isequal(locRow,'n') , 
                if rem(rx,2) , x(rx+1,:) = x(rx,:); rx = rx+1; end
                I = getPerIndices(rx,lf(1),locRow); x = x(I,:);
            end

        otherwise
            errargt(mfilename,'Invalid Extension Mode!','msg');
            error('*')
      end
 
   case {'ar','addrow'}
      if nargin<5, loc = 'b'; else , loc = testLoc(location(1)); end
      location = [loc , 'n'];
      x = wextend('2D',mode,x,lf,location);

   case {'ac','addcol'}      
      if nargin<5, loc = 'b'; else , loc = testLoc(location(1)); end
      location = ['n' , loc];
      x = wextend('2D',mode,x,lf,location);
end

%-------------------------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------------------------%
function location = testLoc(location)

if ~ischar(location) , location = 'b'; return; end
switch location
   case {'n','l','u','b','r','d'}
   otherwise , location = 'b';
end
%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getZPD_ext(nbr,nbc,location)

switch location
  case {'n'}     , ext_L = [];             ext_R = [];
  case {'l','u'} , ext_L = zeros(nbr,nbc); ext_R = [];
  case {'b'}     , ext_L = zeros(nbr,nbc); ext_R = zeros(nbr,nbc);
  case {'r','d'} , ext_L = [];             ext_R = zeros(nbr,nbc);
end
%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getSP0_ext(type,x_L,x_R,lf,location)

switch type(1)
  case 'r' , ext_V = ones(1,lf);
  case 'c' , ext_V = ones(lf,1);
end
switch location
  case {'n'}     , ext_L = [];              ext_R = [];
  case {'l','u'} , ext_L = kron(ext_V,x_L); ext_R = [];
  case {'b'}     , ext_L = kron(ext_V,x_L); ext_R = kron(ext_V,x_R);
  case {'r','d'} , ext_L = [];              ext_R = kron(ext_V,x_R);
end
%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getSP1_ext(type,x_L,x_R,d_L,d_R,lf,location)

switch type(1)
  case 'r' , ext_V0 = ones(1,lf); ext_VL = [lf:-1:1];  ext_VR = [1:lf];
  case 'c' , ext_V0 = ones(lf,1); ext_VL = [lf:-1:1]'; ext_VR = [1:lf]';
end
switch location
  case {'n'}
    ext_L = [];
    ext_R = [];
  case {'l','u'}
    ext_L = kron(ext_V0,x_L) + kron(ext_VL,d_L);
    ext_R = [];
  case {'b'}
    ext_L = kron(ext_V0,x_L) + kron(ext_VL,d_L);
    ext_R = kron(ext_V0,x_R) + kron(ext_VR,d_R);
  case {'r','d'}
    ext_L = [];
    ext_R = kron(ext_V0,x_R) + kron(ext_VR,d_R);
end
%-------------------------------------------------------------------------%
function I = getPerIndices(lx,lf,location)

switch location
    case {'n'}     , I = [1:lx];
    case {'l','u'} , I = [lx-lf+1:lx , 1:lx];
    case {'b'}     , I = [lx-lf+1:lx , 1:lx , 1:lf];
    case {'r','d'} , I = [1:lx , 1:lf];
end
if lx<lf
    I = mod(I,lx);
    I(I==0) = lx;
end
%-------------------------------------------------------------------------%
function I = getSymIndices(lx,lf,location)

switch location
    case {'n'}     , I = [1:lx];
    case {'l','u'} , I = [lf:-1:1 , 1:lx];
    case {'b'}     , I = [lf:-1:1 , 1:lx , lx:-1:lx-lf+1];
    case {'r','d'} , I = [1:lx , lx:-1:lx-lf+1];
end
if lx<lf
    K = (I<1);
    I(K) = 1-I(K);
    J = (I>lx);
    while any(J)
        I(J) = 2*lx+1-I(J);
        K = (I<1);
        I(K) = 1-I(K);
        J = (I>lx);
    end
end
%-------------------------------------------------------------------------%
function Y = HP_SymExt(X,N,LOC) % Half-point Symmetrization.

C = size(X,2);
switch LOC
    case {'n'}     , I = [1:C];
    case {'l','u'} , I = [N:-1:1 , 1:C];
    case {'b'}     , I = [N:-1:1 , 1:C , C:-1:C-N+1];
    case {'r','d'} , I = [1:C , C:-1:C-N+1];
end
if C<N
    K = (I<1);
    I(K) = 1-I(K);
    J = (I>C);
    while any(J)
        I(J) = 2*C+1-I(J);
        K = (I<1);
        I(K) = 1-I(K);
        J = (I>C);
    end
end
Y = X(:,I);
%-------------------------------------------------------------------------%
function Y = WP_SymExt(X,N,LOC) % Whole-point Symmetrization.

[r,c] = size(X);
while (N+1)>c
    N = N-(c-1);
    X = WP_SymExt(X,c-1,LOC);
    [r,c] = size(X);
end

switch LOC
  case {'l','u'} , I = [N+1:-1:2 , 1:c];
  case {'b'}     , I = [N+1:-1:2 , 1:c , c-1:-1:c-N];
  case {'r','d'} , I = [1:c , c-1:-1:c-N];
end
Y = X(:,I);
%-------------------------------------------------------------------------%
function Y = HP_AntiSymExt(X,N,LOC) % Half-point Anti-Symmetrization.

[r,c] = size(X);
while N>c
    N = N-c;
    X = HP_AntiSymExt(X,c,LOC);
    [r,c] = size(X);
end

switch LOC
    case {'l','u'}
        Y = [fliplr(-X(:,1:N)), X];
    case {'r','d'}
        Y = [X , fliplr(-X(:,end-N+1:end))];
    case 'b'
        Y = [fliplr(-X(:,1:N)), X];
        Y = [Y , fliplr(-X(:,end-N+1:end))];
end
%-------------------------------------------------------------------------%
function Y = WP_AntiSymExt(X,N,LOC) % Whole-point Anti-Symmetrization.

[r,c] = size(X);
while (N+1)>c
    N = N-(c-1);
    X = WP_AntiSymExt(X,c-1,LOC);
    [r,c] = size(X);
end

N = N+1;
switch LOC
    case {'l','u'}
        Y = [fliplr(-X(:,2:N)+ 2*X(:,ones(1,N-1))) , X];
    case {'r','d'}
        Y = [X , fliplr(-X(:,end-N+1:end-1)+ 2*X(:,c*ones(1,N-1)))];
    case 'b'
        Y = [fliplr(-X(:,2:N)+ 2*X(:,ones(1,N-1))) , X];
        Y = [Y , fliplr(-X(:,end-N+1:end-1)+ 2*X(:,c*ones(1,N-1)))];
end
%-------------------------------------------------------------------------%

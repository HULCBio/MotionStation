function [X,Y,IntVAL] = make_pattern(numEX,NBpts)
%MAKE_PATTERN Make patterns for New Wavelet Tool.
%
%   [X,Y,IntVAL] = MAKE_PATTERN(numEX,NBpts)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:41:14 $ 

if nargin < 1 , numEX =   1; end
if nargin < 2 , NBpts = 256; end
X = linspace(-1,1,NBpts);
switch numEX
    case 1
        C1 = 1; C2 = 0.5;
        Y = (C1*(X>0) + C2*(X<0)).*sin(pi*X);

    case 2
        C1 = 1; C2 = 0.9;
        Y = (C1*(X>0) + C2*(X<0)).*sin(pi*X);
        
    case 3
        C1 = 1; C2 = 1;
        Y = (C1*(X>0) + C2*(X<0)).*sin(pi*X);
        
    case 4
        C1 = 1; C2 = 0.3;
        Y = (C1*(X>0) + C2*(X<0)).*sin(pi*X) + 0.25*sin(4*pi*X);
        
    case 5
        Y = sin(pi*X)+ 0.5*(1-abs(X).^2);
        
    case 6
        Y = sin(2*pi*X)+ 0.5*(1-abs(X).^2);
        
    case 7
        Y = (X>0).*min(X,1-X) + (X<0).*max(X,-(X+1));
        
    case 8
        Y = sign(X);
        
    otherwise   % For test: odd expansion
        numNEXT = round(10*(numEX-fix(numEX)));
        switch numNEXT
            case 0 , V = min([X;1-X;1/4*ones(size(X))]);
            case 1 , V = ((1-abs(X)).*X).^4;
        end
        Maxi = 0.5;
        Y = odd_EXTENT(X,V,Maxi);
end
IntVAL = 0.5*(2/(NBpts-1))*sum(Y(1:end-1)+Y(2:end));

% Make Pattern on [0 1].
X = 0.5*(X+1);
IntVAL = 0.5*IntVAL;

%----------------------------------
function Y = odd_EXTENT(X,V,Maxi)

if nargin<3 , Maxi = 1; end
V = V.*(X > 0);
V = (V + V(end:-1:1));
Y = V.*sign(X);
Y = Maxi*Y/max(abs(Y));
%----------------------------------

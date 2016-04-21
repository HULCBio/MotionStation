function list = cflibhelp(group)
%CFLIBHELP  Help on fit type objects in the Curve Fitting Library.
%   CFLIBHELP gives general information about models available in the Curve
%   Fitting Library. 
%
%   CFLIBHELP('GROUP') gives additional details about models in a specific
%   GROUP in the Curve Fitting Library.
%   GROUP can be 
%     distribution - distribution models such as Weibull
%     exponential  - exponential function and sum of two exponential functions
%     fourier      - up to eight terms of fourier series
%     gaussian     - sum of up to eight gaussian models
%     interpolant  - interpolants
%     polynomial   - polynomial models up to ninth degree
%     power        - power function and sum of two power functions
%     rational     - rational equation models, up to 5th degree / 5th degree
%     sin          - sum of up to eight sin functions
%     spline       - splines
%
%   Note that you can type 
%     cflibhelp polynomial
%   as shorthand for 
%     cflibhelp('polynomial')
%
%   See also FIT, FITTYPE, FITOPTIONS.

%   LIBLIST=CFLIBHELP(SUBLIBRARY) returns a cell array list of the model
%   names in LIBRARY.
%
%   list = CFLIBHELP (with no inputs) returns a cell array list of the 
%   libraries.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.14.2.2 $  $Date: 2004/02/01 21:41:58 $

matchedstring = 0;

if (nargin == 0) && (nargout == 0)
    group = [];
    DisplayStr = {...
            ' The Curve Fitting Library is a library of models for data fitting'...
            ' with the FIT function.'...
            ' These models are divided into groups according to the type of'...
            ' equations being modeled.'...
            ' ' ...
            ' The groups are'...
            '    GROUP           DESCRIPTION'...
            '    distribution  : distribution models such as Weibull'...
            '    exponential   : models involving exponential terms'...
            '    fourier       : initial terms of fourier series up to eighth order'...
            '    gaussian      : sum of gaussian models up to eighth order'...
            '    interpolant   : interpolants'...
            '    polynomial    : polynomial models up to ninth order'...
            '    power         : power function and sum of two power functions'...
            '    rational      : rational equation models'...
            '    sin           : sum of sin functions up to eighth order'...
            '    spline        : splines'...
            ' '...
            ' To list only the model equations for a group, type CFLIBHELP'...
            ' followed by the group name.'...
            ' Example:'...
            '   cflibhelp polynomial'...
            ' '...
            ' All models in the Curve Fitting Library:'...
            ' '...
        };
    
    disp(' ')
    disp(char(DisplayStr))
end
if nargout==0
    if isequal(group,'distribution') || (nargin == 0)
        matchedstring = 1;
        fprintf('  DISTRIBUTION MODELS\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('         weibull               Y = a*b*x^(b-1)*exp(-a*x^b)\n');
        fprintf('\n');
    end
    if isequal(group,'exponential') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  EXPONENTIAL MODELS\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('          exp1                 Y = a*exp(b*x)\n');
        fprintf('          exp2                 Y = a*exp(b*x)+c*exp(d*x)\n');
        fprintf('\n');
    end
    if isequal(group,'fourier') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  FOURIER SERIES\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('        fourier1               Y = a0+a1*cos(x*p)+b1*sin(x*p)\n');
        fprintf('        fourier2               Y = a0+a1*cos(x*p)+b1*sin(x*p)+a2*cos(2*x*p)+b2*sin(2*x*p)\n');
        fprintf('        fourier3               Y = a0+a1*cos(x*p)+b1*sin(x*p)+...+a3*cos(3*x*p)+b3*sin(3*x*p)\n');
        fprintf('         ...\n');
        fprintf('        fourier8               Y = a0+a1*cos(x*p)+b1*sin(x*p)+...+a8*cos(8*x*p)+b8*sin(8*x*p)\n');
        fprintf('\n      where p = 2*pi/(max(xdata)-min(xdata)).\n');
        fprintf('\n');
    end
    if isequal(group,'gaussian') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  GAUSSIAN SUMS (Peak fitting)\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('         gauss1                Y = a1*exp(-((x-b1)/c1)^2)\n');
        fprintf('         gauss2                Y = a1*exp(-((x-b1)/c1)^2)+a2*exp(-((x-b2)/c2)^2)\n');
        fprintf('         gauss3                Y = a1*exp(-((x-b1)/c1)^2)+...+a3*exp(-((x-b3)/c3)^2)\n');
        fprintf('         ...\n');
        fprintf('         gauss8                Y = a1*exp(-((x-b1)/c1)^2)+...+a8*exp(-((x-b8)/c8)^2)\n');
        fprintf('\n');
    end
    if isequal(group,'interpolant') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  INTERPOLANT\n\n');
        fprintf('        INTERPTYPE            DESCRIPTION\n\n');
        fprintf('        linearinterp           linear interpolation\n');
        fprintf('        nearestinterp          nearest neighbor interpolation\n');
        fprintf('        splineinterp           cubic spline interpolation\n');
        fprintf('        pchipinterp            shape-preserving (pchip) interpolation\n');
        fprintf('\n');
    end
    if isequal(group,'polynomial') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  POLYNOMIAL MODELS\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('          poly1                Y = p1*x+p2\n');
        fprintf('          poly2                Y = p1*x^2+p2*x+p3\n');
        fprintf('          poly3                Y = p1*x^3+p2*x^2+...+p4\n');
        fprintf('          ...\n');
        fprintf('          poly9                Y = p1*x^9+p2*x^8+...+p10\n');
        fprintf('\n');
    end
    if isequal(group,'power') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  POWER MODELS\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('         power1                Y = a*x^b\n');
        fprintf('         power2                Y = a*x^b+c\n');
        fprintf('\n');
    end
    if isequal(group,'rational') || (nargin == 0)
       matchedstring = 1;
       fprintf('\n  RATIONAL MODELS\n\n');
       fprintf('     Rational Models are polynomials over polynomials');
       fprintf(' with the leading coefficient\n');
       fprintf('     of the denominator set to 1. Model names are ratij,');
       fprintf(' where i is the order of the\n');
       fprintf('     numerator and j is the order of the denominator.');
       fprintf(' The orders go up to five for\n');
       fprintf('     both the numerator and the denominator. For example:\n\n');
       fprintf('        MODELNAME             EQUATION\n\n');
       fprintf('          rat02                Y = (p1)/(x^2+q1*x+q2)\n');
       fprintf('          rat21                Y = (p1*x^2+p2*x+p3)/(x+q1)\n');
       fprintf('          rat55                Y = (p1*x^5+...+p6)/(x^5+...+q5)\n');
       fprintf('\n');
    end
    if isequal(group,'sin') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  SUM OF SIN FUNCTIONS\n\n');
        fprintf('        MODELNAME             EQUATION\n\n');
        fprintf('          sin1                 Y = a1*sin(b1*x+c1)\n');
        fprintf('          sin2                 Y = a1*sin(b1*x+c1)+a2*sin(b2*x+c2)\n');
        fprintf('          sin3                 Y = a1*sin(b1*x+c1)+...+a3*sin(b3*x+c3)\n');
        fprintf('          ...\n');
        fprintf('          sin8                 Y = a1*sin(b1*x+c1)+...+a8*sin(b8*x+c8)\n');
        fprintf('\n');
    end
    if isequal(group,'spline') || (nargin == 0)
        matchedstring = 1;
        fprintf('\n  SPLINES\n\n');
        fprintf('        SPLINETYPE             DESCRIPTION\n\n');
        fprintf('        cubicspline             cubic interpolating spline\n');
        fprintf('        smoothingspline         smoothing spline\n');
        fprintf('\n');
    end
    if nargin==1 && ~matchedstring
        error('curvefit:cflibhelp:unknownName', ...
              'Unknown library name. Use ''cflibhelp'' for list of all names.')
    end
elseif (nargin == 1) && (nargout == 1) 
    if isequal(group,'polynomial')
        list = {'poly1';'poly2';'poly3';'poly4';'poly5';'poly6';'poly7';'poly8';'poly9';};
    elseif isequal(group,'exponential')
        list = {'exp1';'exp2'};
    elseif isequal(group,'power')
        list = {'power1';'power2'};
    elseif isequal(group,'distribution')
        list = {'weibull'};
    elseif isequal(group,'gaussian')
        list = {'gauss1','gauss2','gauss3','gauss4','gauss4','gauss5','gauss6','gauss7','gauss8'};
    elseif isequal(group,'fourier')
        list = {'fourier1','fourier2','fourier3','fourier4','fourier4','fourier5','fourier6','fourier7','fourier8'};
    elseif isequal(group,'sin')
        list = {'sin1','sin2','sin3','sin4','sin4','sin5','sin6','sin7','sin8'};
    elseif isequal(group,'rational')
        list = {'rat01','rat02','rat03','rat04','rat05','rat11','rat12','rat13','rat14','rat15','rat21','rat22','rat23','rat24','rat25','rat31','rat32','rat33','rat34','rat35','rat41','rat42','rat43','rat44','rat45','rat51','rat52','rat53','rat54','rat55'};
    elseif isequal(group,'spline')
        list = {'cubicspline';'smoothingspline'};
    elseif isequal(group,'interpolant')
        list = {'linearinterp';'nearestinterp';'splineinterp';'pchipinterp'};
    else
        error('curvefit:cflibhelp:unknownLibName', ...
              'Unknown library name. Use ''cflibhelp'' for list of library names.')
    end
elseif (nargout == 1)
    % put list in a cellarray
    list = {'polynomial';'exponential';'distribution';'gaussian';'power';'rational';'fourier';'sin';'spline';'interpolant'};
    
else
    error('curvefit:cflibhelp:incorrectSyntax', ...
          'Syntax for CFLIBHELP command is incorrect.')
end


function obj = liblookup(libname,obj)
% LIBLOOKUP set up a library function.
% OBJ_OUT = LIBLOOKUP(FUNNAME, OBJ) initializes OBJ to be the
% library function FUNNAME and returns the result OBJ_OUT.
%
% Note: .expr, .derexpr, .intexpr functions may assume X is a column vector.


%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.30.2.2 $  $Date: 2004/02/01 21:42:51 $

switch libname(1:3)
case 'exp'  % exp1 and exp2
    obj.feval = 1;
    n = str2double(libname(end))+length(libname)-4;
    obj.coeff = char((0:2*n-1)'+'a');
    obj.numCoeffs = size(obj.coeff,1);
    if n == 1
        obj.defn = 'a*exp(b*x)';
        obj.nonlinearcoeffs = 2; % b
    elseif n == 2
        obj.defn = 'a*exp(b*x) + c*exp(d*x)';
        obj.nonlinearcoeffs = [2,4]; % b and d
    else
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on');
case 'pow' % power1,power2
    obj.feval = 1;
    n = str2double(libname(end))+length(libname)-6;
    if n == 1
        obj.coeff = strvcat('a','b');
        obj.defn = 'a*x^b';
        obj.nonlinearcoeffs = 2; % b
    elseif n == 2;
        obj.coeff = strvcat('a','b','c');
        obj.defn = 'a*x^b+c';
        obj.nonlinearcoeffs = 2; % b
    end
    obj.numCoeffs = size(obj.coeff,1);
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on');
case 'gau'
    obj.feval = 1;
    n = str2double(libname(end))+length(libname)-6;
    if n < 1 || n > 8
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    obj.coeff = [repmat(['a';'b';'c';],n,1) ...
            reshape(repmat(num2str((1:n)'),1,3)',3*n,1)];
    obj.numCoeffs = size(obj.coeff,1);
    obj.nonlinearcoeffs = reshape([2:3:3*n; 3:3:3*n],1,2*n);
    if n > 2
        pstr = sprintf('\n              ');
    else
        pstr = ' ';
    end
    for i = 1:n
        si = num2str(i);
        pstr = sprintf('%sa%s*exp(-((x-b%s)/c%s)^2) + ',pstr,si,si,si);
        if mod(i,2) == 0 && i ~= n
            pstr = sprintf('%s\n              ',pstr);
        end
    end
    pstr(end-2:end)=[];
    obj.defn = pstr;
    obj.constants = {n};
    lowerbnds = repmat([-inf;-inf;0],n,1);
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on','lower',lowerbnds);
case 'sin'
    obj.feval = 1;
    n = str2double(libname(end))+length(libname)-4;
    if n < 1 || n > 9
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    obj.coeff = [repmat(['a';'b';'c';],n,1) ...
            reshape(repmat(num2str((1:n)'),1,3)',3*n,1)];
    obj.numCoeffs = size(obj.coeff,1);
    % obj.nonlinearcoeffs = reshape([2:3:3*n; 3:3:3*n],1,2*n);  
    obj.nonlinearcoeffs = []; % Seems to work better as not separable
    if n > 3 
        k = 2; 
    else 
        k = 2-n; 
    end
    pstr = ' ';
    for i = 1:n
        if mod(k+i,3) == 0
            pstr = sprintf('%s\n                    ',pstr);
        end
        si = num2str(i);
        pstr = sprintf('%sa%s*sin(b%s*x+c%s) + ',pstr,si,si,si);
    end
    obj.defn = pstr(1:end-3);
    obj.constants = {n};
    lowerbnds = repmat([-inf;0;-inf],n,1);
    upperbnds = repmat([inf; inf; inf],n,1);
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on',...
        'lower',lowerbnds,'upper',upperbnds);
case 'rat'
    m = str2num(libname(end));
    n = str2num(libname(end-1));
    if m > 5 || n > 5 || length(libname) ~= 5
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    obj.feval = 1;
    obj.coeff = [repmat('p',n+1,1) num2str((1:n+1)');...
            repmat('q',m,1) num2str((1:m)')]; % n&m < 10;
    obj.numCoeffs = size(obj.coeff,1);
    % obj.nonlinearcoeffs = [n+2:n+2+m-1];
    obj.nonlinearcoeffs = []; % Seems to work better as not separable
    if n == 5
        pstr = sprintf('\n               (');
    else
        pstr = '(';
    end
    if (n == 0)
        pstr = sprintf('%sp1)',pstr);
    else % n > 1
        for i = 1 : n-1
            pstr = sprintf('%sp%s*x^%s + ',pstr,num2str(i),num2str(n-i+1));
        end
        pstr = sprintf('%sp%s*x + p%s)',pstr,num2str(n),num2str(n+1));
    end
    if (m == 1)
        qstr = sprintf('(x + q1)');
    else
        qstr = sprintf('(x^%s + ',num2str(m));
        for i = 2 : m-1
            qstr = sprintf('%sq%s*x^%s + ',qstr,num2str(i-1),num2str(m-i+1));
        end
        qstr = sprintf('%sq%s*x + q%s)',qstr,num2str(m-1),num2str(m));
    end
    if (m+n > 4)
        nl = sprintf(' /\n               ');
    else
        nl = sprintf(' / ');
    end
    obj.defn = sprintf('%s%s%s', pstr, nl, qstr);
    obj.constants = {n,m};
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on');
case 'wei' % weibull a*b*x^(b-1)*e^(-a*x^b)
    obj.feval = 1;
    obj.coeff = ['a';'b'];
    obj.numCoeffs = size(obj.coeff,1);
    obj.defn = 'a*b*x^(b-1)*exp(-a*x^b)';
    lowerbnds = [0; 0];
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on','lower',lowerbnds);
case 'pol'     % Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
    obj.linear = 1;
    obj.feval = 1;
    N = str2num(libname(end))+length(libname)-5;
    if N < 1 || N > 9
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    pstr = 'p1 ';
    for i = 2:N+1
        numstr = num2str(i);
        if i <= 9
            pstr(i,:) = sprintf('p%s ',numstr);
        else
            pstr(i,:) = sprintf('p%s',numstr);
        end
    end
    obj.coeff = pstr;  % this should actually be p1,p2, etc
    obj.numCoeffs = N+1;
    k = floor(N/4);
    pstr = '';
    for i = 1:N-1
        pstr = sprintf('%sp%s*x^%s + ',pstr,num2str(i),num2str(N-i+1));
        if i+k==6
            pstr = sprintf('%s\n                    ',pstr);
        end
    end
    obj.defn = sprintf('%sp%s*x + p%s',pstr, num2str(N), num2str(N+1));
    obj.fitoptions = fitoptions('method','linearleastsquares');
case 'fou'  % Fourier terms
    % Y = A0 + A(1)*cos(x*w)   + B(1)*sin(x*w)+...
    %        ...
    %        + A(n)*cos(n*x*w) + B(n)*sin(n*x*w)
    % where w is the nonlinear parameter to be fitted. Other
    % parameters will be fitted linearly using backslash.

    obj.feval = 1;
    n = str2num(libname(end))+length(libname)-8;
    if n < 1 || n > 9
        error('curvefit:fittype:liblookup:nameNotFound', ...
              'Library name %s not found.',libname);
    end
    pstr = strvcat('a0','a1','b1');
    for i = 2:n
        numstr = num2str(i);
        pstr = strvcat(pstr, sprintf('a%s', numstr), sprintf('b%s', numstr));
    end
    pstr = strvcat(pstr, 'w ');
    obj.coeff = pstr; 
    obj.numCoeffs = size(obj.coeff,1);
    obj.nonlinearcoeffs = obj.numCoeffs;
    if n > 5, 
        pstr = sprintf('\n              ');
    else
        pstr = '';
    end
    pstr = sprintf('%s a0 + a1*cos(x*w) + b1*sin(x*w) + ',pstr);
    if n > 1
      pstr = sprintf('%s\n               ', pstr);
    end
    for i = 2:n
        si = num2str(i);
        pstr = sprintf('%sa%s*cos(%s*x*w) + b%s*sin(%s*x*w) + ',pstr,si,si,si,si);
        if mod(i,2)==1 && i ~= n
            pstr = sprintf('%s\n               ', pstr);
        end
    end
    pstr(end-2:end) = [];

    obj.defn = pstr;
    obj.constants = {n};
    obj.fitoptions = fitoptions('method','nonlinearleastsquares','Jacobian','on');
case {'smo','cub','nea','spl','lin','pch'}
    obj.feval = 1;
    obj.coeff = 'p';
    obj.numCoeffs = [];
    obj.defn = 'piecewise polynomial';
    switch libname(1:3)
    case 'smo'
        obj.fitoptions = fitoptions('method','smoothing');
    case 'cub'
        obj.fitoptions = fitoptions('method','cubicsplinei');
    case 'nea'
        obj.fitoptions = fitoptions('method','nearesti');
    case 'spl'
        obj.fitoptions = fitoptions('method','cubicsplinei');
    case 'lin'
        obj.fitoptions = fitoptions('method','lineari');
    case 'pch'
        obj.fitoptions = fitoptions('method','pchipi');
    end
otherwise
    error('curvefit:fittype:liblookup:nameNotFound', ...
          'Library name %s not found.',libname);
end


% Now define function handle fields
obj = sethandles(libname,obj);

function display(sys, varargin)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%       Author(s): A. Potvin, 3-1-94
%       Revised: P. Gahinet, 4-1-96
%       Copyright 1986-2004 The MathWorks, Inc.
%       $Revision: 1.29.4.2 $  $Date: 2004/04/10 23:13:49 $

%*******************************************************************************
% Default plot type is pole-zero (p). Other options are time-constant (t) and frequency (f) 

if nargin>=2
    dispType = varargin{1}; %keep for backward compatibility
else
    dispType = sys.DisplayFormat;
end

CWS = get(0,'CommandWindowSize');      % max number of char. per line
LineMax = round(.8*CWS(1));

Ts = getst(sys.lti);  % sampling time
Inames = get(sys.lti,'InputName');
Onames = get(sys.lti,'OutputName');
AllDelays = totaldelay(sys);
StaticFlag = isstatic(sys);

% Get system name
SysName = inputname(1);
if isempty(SysName),
    SysName = 'ans';
end

% Get number of models in array
sizes = size(sys.k);
asizes = [sizes(3:end) , ones(1,length(sizes)==3)];
nsys = prod(asizes);
if nsys>1,
    % Construct sequence of indexing coordinates
    indices = zeros(nsys,length(asizes));
    for k=1:length(asizes),
        range = 1:asizes(k);
        base = repmat(range,[prod(asizes(1:k-1)) 1]);
        indices(:,k) = repmat(base(:),[nsys/prod(size(base)) 1]);
    end
end

%Convert variable z to w if we are using the t or f plot types
if strcmpi(sys.Variable,'z') & ~isempty(dispType) & (strcmpi(dispType(1),'t') | strcmpi(dispType(1),'f'))
    varType = 'w';
else
    varType = sys.Variable;
end

% Handle various cases
if any(sizes==0),
    disp('Empty zero-pole-gain model.')
    return
    
elseif length(sizes)==2,
    % Single ZPK model
    %****************************************************************
    
    %Need to pass plot type to SingleModelDisplay
    SingleModelDisplay(sys.z,sys.p,sys.k,Inames,Onames,Ts,...
        AllDelays,varType,LineMax,'',dispType);
    % display definition of w if it is used as a surrogate for 'z' (i.e., when DisplayFormat is 't' or 'f')
    
    if strcmpi(varType,'w')
        if Ts>0
            disp('with w = (z-1)/Ts');
        elseif Ts==-1
            disp('with w = (z-1)');
        end
        disp(' ');
    end
    
    % Display LTI properties (I/O groups, sample times)
    dispprop(sys.lti,StaticFlag);  
else
    % TF array
    Marker = '=';
    for k=1:nsys,
        coord = sprintf('%d,',indices(k,:));
        Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
        disp(sprintf('\n%s',Model))
        disp(Marker(1,ones(1,length(Model))))
        %****************************************************************
        %Need to pass plot type to SingleModelDisplay     
        SingleModelDisplay(sys.z(:,:,k),sys.p(:,:,k),sys.k(:,:,k),...
            Inames,Onames,Ts,AllDelays(:,:,min(k,end)),varType,LineMax,'  ',dispType)
    end
    
    % display definition of w if it is used as a surrogate for 'z' (i.e., when DisplayFormat is 't' or 'f')
    
    if strcmpi(varType,'w')
        if Ts>0
            disp('w = (z-1)/Ts');
        elseif Ts==-1
            disp('w = (z-1)');
        end
        disp(' ');
    end
    
    % Display LTI properties (I/O groups and sample time)
    disp(' ')
    dispprop(sys.lti,StaticFlag);
    
    % Last line
    ArrayDims = sprintf('%dx',asizes);
    if StaticFlag,
        disp(sprintf('%s array of static gains.',ArrayDims(1:end-1)))
    elseif Ts==0,
        disp(sprintf('%s array of continuous-time zero-pole-gain models.',...
            ArrayDims(1:end-1)))
    else
        disp(sprintf('%s array of discrete-time zero-pole-gain models.',...
            ArrayDims(1:end-1)))
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SingleModelDisplay(Zero,Pole,Gain,Inames,Onames,Ts,Td,ch,LineMax,offset,dispType)
% Displays a single ZPK model

[p,m] = size(Gain);
offset = reshape(offset,[1 length(offset)]);
relprec = 0.0005;  % 1+relprec displays as 1

Istr = '';  Ostr = ''; Ending = ':';
NoInames = isequal('','',Inames{:});
NoOnames = isequal('','',Onames{:});

if m==1 & NoInames,
    % Single input and no name
    if p>1 | ~NoOnames,
        Istr = ' from input';
    end
else
    for i=1:m, 
        if isempty(Inames{i}),
            Inames{i} = int2str(i); 
        else
            Inames{i} = ['"' Inames{i} '"'];
        end
    end
    Istr = ' from input ';
end

if p>1,
    for i=1:p, 
        if isempty(Onames{i}), Onames{i} = ['#' int2str(i)]; end
    end
    Ostr = ' to output...';
    Ending = '';
elseif ~NoOnames,
    % Single output with name
    Ostr = ' to output ';
    Onames{1} = ['"' Onames{1} '"'];
else
    % Single unnamed output, but several inputs
    Onames = {''};
    if ~isempty(Istr),  
        Ostr = ' to output';  
    end
end


% REVISIT: Possibly make a matrix gain display as a simple matrix
i = 1; j = 1;
while j<=m,
    disp(' ');
    
    % Display header for each new input
    if i==1,
        str = [xlate('Zero/pole/gain') Istr Inames{j} Ostr];
        if p==1,  str = [str Onames{1}];  end
        disp([offset str Ending])
    end
    
    % Set output label
    if p==1,
        OutputName = offset;
    else
        OutputName = sprintf('%s %s:  ',offset,Onames{i});
    end
    
    kij = Gain(i,j);
    if kij~=0,
        
        %Note pole2str returns a gainScale to account for changes in the gain
        %scale factor that occur when the DisplayFormat is not in 'roots' (roots) form
        [s1 gainScaleZ] = pole2str(Zero{i,j},ch,dispType, Ts);
        [s2 gainScaleP] = pole2str(Pole{i,j},ch,dispType, Ts);
        %No need to worry about gainScaleP==0, by design its >eps*1e4   
        kij = kij*gainScaleZ/gainScaleP;
        GainStr = num2str(kij);
        if ~isreal(kij)
            GainStr = sprintf('(%s)',GainStr);
        end
        
        if strcmp(ch,'z^-1') | strcmp(ch,'q'),
            % Add appropriate power of 1/z or q 
            reldeg = length(Zero{i,j})-length(Pole{i,j});
            absr = abs(reldeg);
            if absr==1,
                str = [ch ' '];
            elseif absr & strcmp(ch,'q'),
                str = ['q^' int2str(absr) ' '];
            elseif absr,
                str = ['z^-' int2str(absr) ' '];
            end
            if reldeg<0,
                s1 = [str s1];
            elseif reldeg>0,
                s2 = [str s2];
            end
        end
        
        % Add delay time
        if Td(i,j),
            if Ts==0,
                OutputName = [OutputName , sprintf('exp(-%.2g*%s) * ',Td(i,j),ch)];
            elseif strcmp(ch,'q'),
                OutputName = [OutputName , sprintf('q^%d * ',Td(i,j))];
            else 
                OutputName = [OutputName , sprintf('z^(-%d) * ',Td(i,j))];
            end
        end
        loutname = length(OutputName);
        
        % Handle long lines and case |kij|=1
        maxchars = max(LineMax/2,LineMax-loutname);
        if isempty(s1)
            s1 = GainStr;
        elseif abs(kij-1)<relprec,
            s1 = sformat(s1,'(',maxchars); 
        elseif abs(kij+1)<relprec,
            s1 = sformat(['- ' s1],'(',maxchars); 
        else
            s1 = sformat([GainStr ' ' s1],'(',maxchars); 
        end
        s2 = sformat(s2,'(',maxchars);  
        
        [m1,l1] = size(s1);
        b = ' ';
        if isempty(s2);
            disp([[OutputName ; b(ones(m1-1,loutname))],s1])
        else
            [m2,l2] = size(s2);
            if m1>1 | m2>1, disp(' '); end
            sep = '-';
            extra = fix((l2-l1)/2);
            disp([b(ones(m1,loutname+max(0,extra))) s1]);
            disp([OutputName sep(ones(1,max(l1,l2)))]);
            disp([b(ones(m2,loutname+max(0,-extra))) s2]);
        end
    else
        disp([OutputName '0']);
    end
    
    i = i+1;  
    if i>p,  
        i = 1;  j = j+1; 
    end
end

disp(' ');

function [s, gainScale] = pole2str(p,ch,varargin)
%POLE2STR Return polynomial as string.
%       S = POLE2STR(P,'s') or S=POLE2STR(P,'z') returns a string S
%       consisting of the poles in the vector P subtracted from the
%       transform variable 's' or 'z' and then multiplied out.
%
%       Example: POLE2STR([1 0 2],'s') returns the string  's^2 + 2'. 

%       Author(s): A. Potvin, 3-1-94, P. Gahinet 5-96

s = '';
gainScale = 1;

polyType = 'roots';
if nargin>=3 & ~isempty(varargin{1})
    polyType = varargin{1};
    if nargin>3 & ~isempty(varargin{2})
        Ts = abs(varargin{2}); % use abs to convert -1 to 1
    end
end
if isempty(p),
    return
else
    p = mroots(p,'roots',1e-6);  % Denoise multiple roots for nicer display
end

% Formats for num to char conversion
[formatString, dispTol, relTol, absTol] = deltaParameters;

zinv = 0;
if strcmp(ch,'z^-1'),
    ch = 'q';
    zinv = 1;
end

% Put real roots first
[trash,ind] = sort(abs(imag(p)));
p = -p(ind);



%recognise cts time integrators and discrete time delays
Izero = find(abs(p) < absTol);
p(Izero) = 0;
%recognise dist time integrators
if ~(strcmp(ch,'s') || strcmp(ch,'p'))
   Ione = find(abs(p-1) < absTol);
   p(Ione) = 1;
end


while ~isempty(p),
    p1 = p(1);
    cmplxpair = false;
    if isreal(p1)
        ind = find(abs(p-p1) <= relTol*abs(p1));   
        pow = length(ind);      
    else
        sgn = sign(imag(p1));
        ind = find(sgn*imag(p)>0 & abs(p-p1)<absTol);
        indcjg = find(sgn*imag(p)<0 & abs(p-conj(p1)) < absTol);
        pow = length(ind);
        if abs(imag(p1)) < relTol * abs(p1),
            % Display as real
            p1 = real(p1);
            ind = [ind indcjg];
            pow = pow + length(indcjg);
        elseif length(ind)>=1 & length(indcjg)>=1    
            pow = min(length(ind),length(indcjg));
            cmplxpair = true;
            ind = [ind(1:pow) indcjg(1:pow)];
        end
    end
    p(ind) = [];
    switch [ch polyType(1)]
    case {'qr','qt','qf'} %variable q or z^-1
        [tmp,thisFactorGainScale] = qsRoots2str(p1, ch, cmplxpair);
    case 'wt' %variable w 
        [tmp,thisFactorGainScale] = twRoots2str(p1, ch, Ts, cmplxpair);
    case 'wf'
        [tmp,thisFactorGainScale] = fwRoots2str(p1, ch, Ts, cmplxpair);
    case {'pt','st'} %variable s or p
        [tmp,thisFactorGainScale] = tsRoots2str(p1, ch, cmplxpair);
    case {'sf','pf'}
        [tmp,thisFactorGainScale] = fsRoots2str(p1, ch, cmplxpair);
    case {'sr','pr','zr'}
        [tmp,thisFactorGainScale] = rsRoots2str(p1, ch, cmplxpair);
    end    
    
    % Raise tmp to right power
    if pow~=1 & ~isempty(tmp),
        tmp = [tmp '^' int2str(pow)];
    end
    
    % Add to s and remove elements from p
    if isempty(s),
        s = tmp;
    elseif p1==0,
        s = [tmp  ' ' s];
    else
        s = [s  ' ' tmp];
    end
    gainScale = gainScale*thisFactorGainScale^pow;
end

% Take care of ch='z^-1'
if zinv,
    s = strrep(s,'q^','z^-');
    s = strrep(s,'q','z^-1');
end

% end pole2str


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signx,valx] = xprint(x,form)
%NICEDISP  Returns sign and value of real or complex number coefficient x 
%          as strings

[formatString, dispTol, relativeTol, integratorTol] = deltaParameters;

if abs(abs(x)-1) > dispTol 
	if isreal(x),
        if sign(x)>=0,  signx = '+';   else  signx = '-';   end
        valx = sprintf(form,abs(x));
	elseif real(x)>=0
        signx = '+';
        valx = ['(' num2str(x,form) ')'];
	else
        signx = '-';
        valx = ['(' num2str(-x,form) ')'];
	end
else
    valx = '';
    if sign(real(x)) > 0
        signx = '+';
    else
        signx = '-';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signx,valx] = rprint(x,form)
%NICEDISP  Returns sign and recipricol value of a real or complex number x 
%          as strings

[formatString, dispTol, relativeTol, integratorTol] = deltaParameters;


if isreal(x),
    if sign(x)>=0,  signx = '+';   else  signx = '-';   end
    if abs(abs(x)-1) < dispTol
        valx = ''; % don't display /1
    else
        valx = ['/' sprintf(form,abs(x))];
    end      
elseif real(x)>=0
    signx = '+';
    valx = ['/(' num2str(x,form) ')'];
else
    signx = '-';
    valx = ['/(' num2str(-x,form) ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signz,valz] = fracprint(x,y,form)
%NICEDISP  Returns sign and string value for x/y for real or complex numbers x,y 

[formatString, dispTol, relTol, absTol] = deltaParameters;

if isreal(x) & isreal(y)
    if (sign(x)>=0 & sign(y)>0) | (sign(x)<0 & sign(y)<0) 
        signz = '+'; 
    else 
        signz = '-';
    end
    if abs(abs(y)-1) > dispTol
        valz = ['(' sprintf(form,abs(x)) '/' sprintf(form,abs(y)) ')'];
    else
        valz = ['(' sprintf(form,abs(x)) ')']; % don't display x/1
    end
elseif real(x)>=0
    signz = '+';
    valz = ['(' num2str(x,form) ')/(' num2str(y,form) ')'];
else
    signz = '-';
    valz = ['(' num2str(-x,form) ')/(' num2str(y,form) ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp, gainScale] = qsRoots2str(p1, ch , cmplxpair)

%case {'qr','qt','qf'}

gainScale = 1;

[formatString, dispTol, relTol, absTol] = deltaParameters;

if p1==0
    tmp = '';
    return
end
if isreal(p1),    % string of the form (1 +/- p * ch)   
    [sp1,val1] = xprint(p1,formatString);
    tmp = ['(1' sp1 val1 ch ')']; 
elseif cmplxpair,      % string (1+2*real(p1)*ch+abs(p1)^2*ch^2)
    rp1 = 2*real(p1);
    tmp = '(1 ';
    
    if abs(rp1)>absTol
        [srp1,val1] = xprint(rp1,formatString);
        if abs(abs(rp1)-1) > dispTol
            tmp = [tmp ' ' srp1 ' ' val1 ch ]; %' '
        else
            tmp = [tmp ' ' srp1 ' ' ch];
        end
    end

    if abs(abs(p1*p1')-1) < dispTol
        tmp = [tmp ' + ' ch '^2)'];
    else
        tmp = [tmp ' + ' sprintf(formatString,p1*p1') ch '^2)'];
    end
else
    [sgn1,val1] = xprint(p1,formatString);
    tmp = ['(1 ' sgn1 ' ' val1 ch ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [tmp,thisFactorGainScale] = fwRoots2str(p1, ch, Ts,cmplxpair)  

%case 'wf'

[formatString, dispTol, relTol, absTol] = deltaParameters;
thisFactorGainScale = 1;
if ~cmplxpair 
    if abs(p1+1)/Ts > absTol %Handle p1=-1 separatly
        thisFactorGainScale = 1+p1;
        [sgn, val] = rprint((1+p1)/Ts,formatString);
        tmp = ['(1' sgn ch  val ')']; %tmp = '(1 + w/k)' 
    else
        thisFactorGainScale = Ts;
        tmp = ch; %if p1-=1, tmp='w'
    end
else
    if abs(p1+1)/Ts > absTol %Handle p1=-1 separately
        
        %find coeffcients k1,k2
        alpha = 2*real(p1);
        beta = abs(p1)^2;
        phi = alpha+beta+1; %Note, phi = |1+p1|^2
        k1 = (alpha+2)/sqrt(abs(phi)); %=2(re(p1)+1)/|p1+1|
        k2 = sqrt(phi)/Ts; %=|1+p1|/Ts > absTol
        thisFactorGainScale = phi;
        tmp = '(1';
        
        %find k1/k2 w middle term
        [srp1,val1] = fracprint(k1,k2,formatString); %val1 is k1/k2
        if abs(k1/k2) > absTol
            if abs(abs(k1/k2)-1) < dispTol %(1 + val1 ch or (1 + ch
                tmp = [tmp ' ' srp1 ' ' ch];
            else
                tmp = [tmp ' ' srp1 ' ' val1  ch];
            end
        end
        %add (w/k2)^2 end term
        [srp2,val2] = rprint(k2,formatString); %Note k2>tol
        if abs(k2-1) > dispTol %note K2 > absTol
            tmp = [tmp ' + (' ch val2 ')^2'];
        else
            tmp = [tmp ' + ' ch '^2'];
        end
        tmp = [tmp ')'];
    else %p1=-1 => tmp=w^2
        thisFactorGainScale = Ts^2;
        tmp = [ch '^2'];
    end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp,thisFactorGainScale] = fsRoots2str(p1, ch, cmplxpair)  

%case {'sf','pf'}

[formatString, dispTol, relTol, absTol] = deltaParameters;
thisFactorGainScale = 1;

if p1==0
    tmp = ch;
    return
end
if ~cmplxpair 
    if abs(abs(p1)-1) > dispTol
        [sgn,val] = rprint(p1,formatString);
        tmp = ['(1' sgn ch val ')']; %tmp='1+s/k'
        thisFactorGainScale = p1;
    else %|p1|=1 => tmp='1+s' or '1-s'
        [sgn,val] = xprint(p1,formatString);
        tmp = ['(1' sgn ch ')'];
    end 
else
        %calculate coefficients 
        k2 = abs(p1); 
        k1 = 2*real(p1)/k2;
        
        %1st term 1
        tmp = '(1';
        
        %Middle term 'k1/k2 s' 
        if abs(k1/k2) > absTol %middle term of the quadratic is significant
            [srp1,val1] = fracprint(k1,k2,formatString);
            if abs(abs(k1/k2)-1) >= dispTol
                srp1 = [srp1 ' ' val1 ch];
            else
                srp1 =  [srp1 ' ' ch];
            end                  
            tmp = [tmp ' ' srp1];
        end 
        
        %End term (s/k2)^2
        if abs(1/k2-1) < dispTol %Note k2>tol 
            tmp = [tmp ' + ' ch '^2)'];
        else
            tmp = [tmp ' + (' ch '/' sprintf(formatString,k2) ')^2'  ') '];
        end
        thisFactorGainScale = p1*conj(p1);      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp,thisFactorGainScale] = twRoots2str(p1, ch, Ts,cmplxpair)  

% case 'wt'

[formatString, dispTol, relTol, absTol] = deltaParameters;
thisFactorGainScale = 1;

if ~cmplxpair 
    if abs(1+p1) > absTol %p1=-1 is a special case and is handled seperately
        k1 = Ts/(1+p1);
        thisFactorGainScale = 1+p1; 
        [sgn,val] = xprint(k1,formatString); 
        tmp = ['(1' sgn  val ch ')'];
    else %p1=-1 => w
        thisFactorGainScale = Ts;
        tmp = ch;
    end
else
    if abs(p1+1) > absTol %if pole p1=-1 handle seperately
        
        %compute coefficients
        alpha = 2*real(p1);
        beta = abs(p1)^2;
        phi = alpha+beta+1; %note phi>0 unless p1=-1 which is excluded. phi>=abs(abs(p)-1)>=tol
        k1 = (alpha+2)*Ts/phi;
        k2 = Ts/sqrt(abs(phi)); %=Ts/|1+p1|
        thisFactorGainScale = phi;
        
        %first term is 1
        tmp = '(1';
        
        %compute second term k1 w
        if abs(k1)>absTol
            [srp1,val1] = xprint(k1,formatString);  
            if abs(abs(k1)-1) < dispTol %set tmp ='(1+val1 ch' or '(1 + ch'
                tmp = [tmp ' ' srp1 ' ' ch];  
            else
                tmp = [tmp ' ' srp1 ' ' val1 ch];                           
            end % now tmp = '(1 + k1 w'
        end
        %add last term (w/k2)^2
        if abs(k2) > absTol %add either '(k2 w)^2' or 'w^2'
            [srp1,val1] = xprint(k2,formatString);
            if abs(abs(k2)-1) > dispTol
                tmp = [tmp ' + (' val1 ch ')^2'];
            else
                tmp = [tmp ' + '  ch '^2'];
            end    
        end 
        tmp = [tmp ')']; %Now have tmp = '(1 + k1 w + (k2 w)^2)'
    else %Handle p1=-1
        thisFactorGainScale = Ts^2;
        tmp = [ch '^2'];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [tmp,thisFactorGainScale] = tsRoots2str(p1, ch, cmplxpair)  

%case {'pt','st'}

[formatString, dispTol, relTol, absTol] = deltaParameters;
thisFactorGainScale = 1;

if p1==0
    tmp = ch;
    return
end
if ~cmplxpair 
        if abs(abs(1/p1)-1) > dispTol
            [sgn,val] = xprint(1/p1,formatString);
            tmp = ['(1' sgn val ch ')'];
            thisFactorGainScale = p1;
        else
            [sgn,val] = xprint(1/p1,formatString);
            tmp = ['(1' sgn ch ')'];
        end
else
        rp1 = 2*real(p1)/abs(p1)^2;
   
        %first term is 1
        tmp = '(1';
        
        %compute middle term 'k1 s'
        if abs(rp1)>absTol
            [srp1,val1] = xprint(rp1,formatString);
            if abs(abs(rp1)-1) > dispTol
                tmp = [tmp ' ' srp1 ' ' val1 ch ]; %' '
            else
                tmp = [tmp ' ' srp1 ' ' ch]; 
            end
        end
        %end term (k2 s)^2
        if abs(1/(p1*p1')-1) <= dispTol
            tmp = [tmp ' + ' ch '^2)'];
        else
            tmp = [tmp ' + (' sprintf(formatString,1/abs(p1)) ch ')^2)'];
        end
        thisFactorGainScale = p1*conj(p1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp, gainScale] = rsRoots2str(p1, ch, cmplxpair)  


%case {'sr','pr','zr'}

[formatString, dispTol, relTol, absTol] = deltaParameters;

gainScale = 1;

if p1==0
    tmp = ch;
    return
end
if ~cmplxpair                 % string of the form (ch +/- p) 
        [sgn,val] = xprint(p1,formatString);
        if abs(abs(p1)-1) > dispTol
            tmp = ['(' ch  sgn val  ')'];
        else
            tmp = ['(' ch sgn '1)'];
        end
else              % string (ch^2+2*real(p1)*ch+abs(p1)^2)
        rp1 = 2*real(p1);
        tmp = ['(' ch '^2 '];
        
        %middle term
        if abs(rp1)>absTol
            [srp1,val1] = xprint(rp1,formatString);
            if abs(abs(rp1)-1) > dispTol
                tmp = [tmp ' ' srp1 ' ' val1 ch ]; %' '
            else
                tmp = [tmp ' ' srp1 ' ' ch]; 
            end
        end
        
        %last term
        tmp = [tmp ' + ' sprintf(formatString,p1*p1') ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [formatString, displayPrecision, relativeTol, integratorTol] = deltaParameters

formatString = '%.4g';
displayPrecision = 0.0005;   % 1+displayPrecision displays as nothing
relativeTol = eps^0.4;      % tolerance for relaitve comparisons
integratorTol = 1000*eps;    % tolerance for detecting integrators


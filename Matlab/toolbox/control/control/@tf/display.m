function display(sys)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 06:08:31 $


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
sizes = size(sys.num);
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

% Handle various cases
if any(sizes==0),
   disp('Empty transfer function.')
   return
   
elseif length(sizes)==2,
   % Single TF model
   SingleModelDisplay(sys.num,sys.den,Inames,Onames,Ts,...
      AllDelays,sys.Variable,LineMax,'');
   
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
      
      SingleModelDisplay(sys.num(:,:,k),sys.den(:,:,k),Inames,Onames,Ts,...
         AllDelays(:,:,min(k,end)),sys.Variable,LineMax,'  ');
      
   end
   
   % Display LTI properties (I/O groups and sample time)
   disp(' ')
   dispprop(sys.lti,StaticFlag);
   
   % Last line
   ArrayDims = sprintf('%dx',asizes);
   if StaticFlag,
      disp(sprintf('%s array of static gains.',ArrayDims(1:end-1)))
   elseif Ts==0,
      disp(sprintf('%s array of continuous-time transfer functions.',...
         ArrayDims(1:end-1)))
   else
      disp(sprintf('%s array of discrete-time transfer functions.',...
         ArrayDims(1:end-1)))
   end
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SingleModelDisplay(Num,Den,Inames,Onames,Ts,Td,ch,LineMax,offset)
% Displays a single TF model

[p,m] = size(Num);
Istr = '';  Ostr = '';  Ending = ':';
offset = reshape(offset,[1 length(offset)]);
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
   num = Num{i,j};
   den = Den{i,j};
   % Make DEN(1) positive
   ind = find(den);  ind = ind(1);
   if length(num)==1 & length(den)==1
       num = num/den;   den = 1;
   elseif isreal(den(ind)) & den(ind)<0,  
      num = -num;  den = -den;  
   end
   
   disp(' ');
   % Display header for each new input
   if i==1,
      str = [xlate('Transfer function') Istr Inames{j} Ostr];
      if p==1,  str = [str Onames{1}];  end
      disp([offset str Ending])
   end
   
   % Set output label
   if p==1,
      OutputName = offset;
   else
      OutputName = sprintf('%s %s:  ',offset,Onames{i});
   end
   
   % Add delay time
   if any(num) & Td(i,j),
      if Ts==0,
         OutputName = [OutputName , sprintf('exp(-%.3g*%s) * ',Td(i,j),ch)];
      elseif strcmp(ch,'q'),
         OutputName = [OutputName , sprintf('q^%d * ',Td(i,j))];
      else 
         OutputName = [OutputName , sprintf('z^(-%d) * ',Td(i,j))];
      end
   end
   loutname = length(OutputName);
   
   % Generate data display
   maxchars = max(LineMax/2,LineMax-loutname);
   s1 = poly2str(num,ch);
   s1 = sformat(s1,'+-',maxchars);  % Handle long lines
   
   if ~strcmp(s1,'0'),
      s2 = poly2str(den,ch);
      s2 = sformat(s2,'+-',maxchars); 
   end
   
   [m1,l1] = size(s1);
   b = ' ';
   if strcmp(s1,'0') | strcmp(s2,'1'),
      disp([[OutputName ; b(ones(m1-1,loutname))],s1])
   else
      % Generate display
      [m2,l2] = size(s2);
      if m1>1 | m2>1, disp(' '); end
      sep = '-';
      extra = fix((l2-l1)/2);
      disp([b(ones(m1,loutname+max(0,extra))) s1]);
      disp([OutputName sep(ones(1,max(l1,l2)))]);
      disp([b(ones(m2,loutname+max(0,-extra))) s2]);
   end
   
   i = i+1;  
   if i>p,  
      i = 1;  j = j+1;
   end
end

disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = poly2str(p,ch)
%POLY2STR Return polynomial as string.
%       S = POLY2STR(P,ch) where ch is 's', 'z', 'z^-1', or 'q'
%       returns a string S consisting of the polynomial coefficients 
%       in the vector P multiplied by powers of the transform variable 
%       's', 'z', 'z^-1', or 'q'.  Quite similar to old poly2str.
%
%       Example: POLY2STR([1 0 2],'s') returns the string  's^2 + 2'. 

form = '%.4g';
relprec = 0.0005;   % 1+relprec displays as 1


ind = find(p);
if isempty(ind),
   s = '0';
   return
elseif length(p)==1,
   % Quick exit if constant gain
   s = LocalDisplayDouble(p,form);
   return
end

zinv = 0;
if strcmp(ch,'z^-1'),
   ch = 'q';
   zinv = 1;
end

if strcmp(ch,'q'),
   % Ascending powers
   pow = 0:length(p)-1;
else
   % Descending power
   pow = length(p)-1:-1:0;
end
pow = pow(ind); 
s = '';
% For each non-zero element of the polynomial ...
for i=1:length(ind),
   pi = pow(i);
   el = p(ind(i));
   % ... if it's not the first non-zero element of the polynomial ...
   if real(el)<0
       el = -el;
       % Add a minus sign if the element is negative
       if i==1
           s = [s '-'];
       else
           
           s = [s ' - '];  
       end
   elseif i~=1,
       % Add a plus sign if the element has positive real part
       s = [s ' + '];
   end
   % If the element isn't 1 or power is zero
   if abs(el-1)>relprec | (pi==0),
      % Add element value
      s = [s LocalDisplayDouble(el,form) blanks(pi~=0)];
   end
   % Note: in following clause, never print "ch" to 0th power
   if pi==1,
      % Positive powers don't need exponents if to the 1st power
      s = [s ch];
   elseif pi~=0,
      % As long as the power is non-zero add "ch" raised to power
      s = [s ch '^' int2str(pi)];
   end
end

% Take care of ch='z^-1'
if zinv,
  s = strrep(s,'q^','z^-');
  s = strrep(s,'q','z^-1');
end

% end poly2str


function s = LocalDisplayDouble(el,form)
% Display double number with positive real part
if ~isreal(el)
    if imag(el)>0
        form = sprintf('(%s+%si)',form,form);
    else
        form = sprintf('(%s-%si)',form,form);
    end
    s = sprintf(form,real(el),abs(imag(el)));
elseif el==round(el) & el < 1e6,
    s = int2str(el);
else
    s = sprintf(form,el);
end


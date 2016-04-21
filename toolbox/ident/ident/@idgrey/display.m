function tex2 = display(sys,conf)
%DISPLAY   Pretty-print for IDGREY models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.   .
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:16:57 $

% Extract state-space data and sampling/delay times

if nargin <2
   conf = 0;
end
if isempty(sys.MfileName)
   if nargout
      tex2 = 'Empty IDGREY model.';
   else
      disp('Empty IDGREY model.')
   end
   return
end

Ts = pvget(sys,'Ts');
if nargout
   txt1 = size(sys,0);
else
   if conf&isreal(sys)
      [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0] = ssdata(sys);
   else
      [a,b,c,d,k,x0] = ssdata(sys);
      da =[]; db=[];dc=[];dd=[];dk=[];dx0=[];
   end
   
   nu = size(b,2); 
   Ts = pvget(sys.idmodel,'Ts');  % sampling time
   disp(['IDGREY model defined by the mfile ',pvget(sys,'MfileName'),'.'])
   disp(' ')
   Ts = pvget(sys.idmodel,'Ts');  % sampling time
   
   if Ts==0
      dx='  dx/dt';
   else
      dx='x(t+Ts)';
   end
   nv = pvget(sys,'NoiseVariance');
   if isempty(nv) | norm(nv) == 0
      noisetxt1 = '';
      noisetxt2 = '';
      k = [];
   else
      noisetxt1 = ' + K e(t)';
      noisetxt2 = ' + e(t)';
   end
   
   if nu>0
      disp(['State-space model:  ',dx,' = A x(t) + B u(t)',noisetxt1])
      disp(['                       y(t) = C x(t) + D u(t)',noisetxt2])
   else
      disp(['State-space model:  ',dx,' = A x(t) + K e(t)'])
      disp('                       y(t) = C x(t) + e(t)')
   end
   
   Inames = pvget(sys.idmodel,'InputName');
   Onames = pvget(sys.idmodel,'OutputName');
   Snames = sys.StateName;
   %StaticFlag = isstatic(sys);
   
   % Get system name
   SysName = inputname(1);
   if isempty(SysName),
      SysName = 'ans';
   end
   
   if isempty(a) & isempty(d),
      disp('Empty state-space model.')
      return
      
   else%if length(sizes)==2,
      % Single SS model
      printsys(a,b,c,d,k,x0,da,db,dc,dd,dk,dx0,Inames,Onames,Snames,'');
   end
end

estim = pvget(sys,'EstimationInfo');
switch lower(estim.Status(1:3))
case 'est'
    DN = estim.DataName;
   if ~isempty(DN)
   str = sprintf('Estimated using %s from data set %s\nLoss function %g and FPE %g',...
      estim.Method, estim.DataName,estim.LossFcn, estim.FPE);
   else
   str = sprintf('Estimated using %s\nLoss function %g and FPE %g',...
      estim.Method,estim.LossFcn, estim.FPE);
   end
case 'mod'
   str = sprintf('Originally estimated using %s (later modified).',...
      estim.Method);
case 'not'
   str = sprintf('This model was not estimated from data.');
case 'tra'
   str = sprintf('Model translated from the old Theta-format.');
otherwise
   str = [];
end
txt = str;

if Ts~=0,
   txt = str2mat(txt,sprintf('Sampling interval: %g %s', Ts,pvget(sys,'TimeUnit')));
end
id = pvget(sys,'InputDelay');
if any(id),
   txt = str2mat(txt,[sprintf('Input delays (listed by channel): ')...
           sprintf('%0.3g  ',id')]);
end

if conf
   txt=str2mat(txt,timestamp(sys));
end
txt = str2mat(txt,' ');
if ~nargout
   disp(txt)
else
   tex2 = str2mat(txt1,txt);
end 
return%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = printsys(a,b,c,d,k,x0,da,db,dc,dd,dk,dx0,...
   ulabels,ylabels,xlabels,offset)
%PRINTSYS  Print system in pretty format.
% 
%   PRINTSYS is used to print state space systems with labels to the
%   right and above the system matrices.
%
%   PRINTSYS(A,B,C,D,E,ULABELS,YLABELS,XLABELS) prints the state-space
%   system with the input, output and state labels contained in the
%   cellarrays ULABELS, YLABELS, and XLABELS, respectively.  
%   
%   PRINTSYS(A,B,C,D) prints the system with numerical labels.
%
%   See also: PRINTMAT

%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet, 4-1-96

nx = size(a,1);
[ny,nu] = size(d);


if isempty(ulabels) | isequal('',ulabels{:}),
   for i=1:nu, 
      ulabels{i} = sprintf('u%d',i);
   end
else
   for i=1:nu,
      if isempty(ulabels{i}),  ulabels{i} = '?';  end
   end
end


if isempty(ylabels) | isequal('',ylabels{:}) | length(ylabels)<ny,
   for i=1:ny, 
      ylabels{i} = sprintf('y%d',i);
   end
else
   for i=1:ny,
      if isempty(ylabels{i}),  ylabels{i} = '?';  end
   end
   end
   if isempty(xlabels) | isequal('',xlabels{:}) | length(xlabels) < nx,
   for i=1:nx, 
      xlabels{i} = sprintf('x%d',i);
   end
else
   for i=1:nx,
      if isempty(xlabels{i}),  xlabels{i} = '?';  end
   end
end


if isempty(a),
   % Gain matrix
   printmat(d,dd,[offset 'd'],ylabels,ulabels);
else
   printmat(a,da,[offset 'A'],xlabels,xlabels);
   if ~isempty(b)
      printmat(b,db,[offset 'B'],xlabels,ulabels);
   end
   printmat(c,dc,[offset 'C'],ylabels,xlabels);
   if ~isempty(d)
      printmat(d,dd,[offset 'D'],ylabels,ulabels);
   end
   if ~isempty(k)
      printmat(k,dk,[offset 'K'],xlabels,ylabels);
   end
   printmat(x0,dx0,[offset 'x(0)'],xlabels,{''});
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = printmat(a,da,name,rlab,clab)
%PRINTMAT Print matrix with labels.
%   PRINTMAT(A,NAME,RLAB,CLAB) prints the matrix A with the row labels
%   RLAB and column labels CLAB.  NAME is a string used to name the 
%   matrix.  RLAB and CLAB are cell vectors of strings.
%
%   See also  PRINTSYS.

%   Clay M. Thompson  9-24-90
%   Revised  P.Gahinet  8-12-96


space = ' ';
[nrows,ncols] = size(a);
if (isempty(da)|norm(da)==0)&isreal(a)
   col_per_scrn = 5;
   sd = 0;
else
   col_per_scrn = 3;
   sd = 1;
end

len = 12;
if sd
   len2 = 22;
else
   len2 = 12;
end
% Max length of labels


if (nrows==0)|(ncols==0), 
   if ~isempty(name), disp(' '), disp([name,' = ']), end
   disp(' ')
   if (nrows==0)&(ncols==0), 
      disp('     []')
   else
      disp(sprintf('     Empty matrix: %d-by-%d',nrows,ncols));
   end
   disp(' ')
   return
end


col=1;
n = min(col_per_scrn,ncols)-1;
disp(' ')
% Print name
if ~isempty(name), disp([name,' = ']), end  

while col<=ncols
   % Print labels
   s = space(ones(1,len+1-sd*10));
   for j=0:n,
      lab = clab{col+j};
      llab = length(lab);
      lab = [space(ones(1,len2-llab)) , lab(1:min(len2,llab))];
      s = [s,' ',lab];
   end
   disp(setstr(s))
   for i=1:nrows,
      s = rlab{i};
      ls = length(s);
      s = [' ' space(ones(1,len-ls)) s(1:min(len,ls)) ];
      for j=0:n,
         element = a(i,col+j);
         if isempty(da)
            stdev = 0;
         else
            stdev = da(i,col+j);
         end
         
         if stdev ~=0
            stdev = [' +-',sprintf('%-7.2g',stdev) ];
         elseif sd
            stdev = blanks(10);
         else stdev = '';
         end
         if element==0,
            s=[s, blanks(12), '0',stdev];
         elseif element==1
            s=[s, blanks(12), '1',stdev];
         elseif isreal(element)
            s=[s, sprintf(' %12.5g',element), stdev];
         else
            if imag(element)>0
               pm = '+ ';
            else
               pm = '- ';
            end
            s =[s, sprintf(' %12.5g %s%5.5gi',real(element),pm,abs(imag(element)))];
         end                    
      end
     disp(s)
end % for
col = col+col_per_scrn;
disp(' ')
if (ncols-col<n), n=ncols-col; end
end % while


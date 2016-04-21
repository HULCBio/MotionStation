function display(sys)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet, 4-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.25 $  $Date: 2002/04/10 06:01:58 $

% Extract state-space data and sampling/delay times
a = sys.a;   b = sys.b;   c = sys.c;   d = sys.d;   e = sys.e;
Ts = getst(sys.lti);  % sampling time
Inames = get(sys.lti,'InputName');
Onames = get(sys.lti,'OutputName');
StaticFlag = isstatic(sys);

% Get system name
SysName = inputname(1);
if isempty(SysName),
   SysName = 'ans';
end

% Get number of models in array
sizes = size(d);
ArraySizes = size(a);
nsys = prod(ArraySizes);
if nsys>1,
   % Construct sequence of indexing coordinates
   indices = zeros(nsys,length(ArraySizes));
   for k=1:length(ArraySizes),
      range = 1:ArraySizes(k);
      base = repmat(range,[prod(ArraySizes(1:k-1)) 1]);
      indices(:,k) = repmat(base(:),[nsys/prod(size(base)) 1]);
   end
end

% Handle various types
if any(ArraySizes==0) | (any(sizes==0) & isempty(a{1})),
   disp('Empty state-space model.')
   return
   
elseif nsys==1,
   % Single SS model
   printsys(a{1},b{1},c{1},d,e{1},Inames,Onames,sys.StateName,'');
   
   % Display delay info
   dispdelay(sys.lti,1,'');
   
   % Display LTI properties (I/O groups and sample times)
   dispprop(sys.lti,StaticFlag);
   
   % Last line
   if StaticFlag,
      disp('Static gain.')
   elseif Ts==0,
      disp('Continuous-time model.')
   else
      disp('Discrete-time model.');
   end
   
else
   % SS array
   Marker = '=';
   
   for k=1:nsys,
      coord = sprintf('%d,',indices(k,:));
      Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
      disp(sprintf('\n%s',Model))
      disp(Marker(1,ones(1,length(Model))))
      
      printsys(a{k},b{k},c{k},d(:,:,k),e{k},...
                               Inames,Onames,sys.StateName,'  ');
      
      dispdelay(sys.lti,k,'  ');
  end
   
   % Display LTI properties (I/O groups and sample times)
   disp(' ')
   dispprop(sys.lti,StaticFlag);
   
   % Last line
   ArrayDims = sprintf('%dx',ArraySizes);
   if StaticFlag,
      disp(sprintf('%s array of static gains.',ArrayDims(1:end-1)))
   elseif Ts==0,
      disp(sprintf('%s array of continuous-time state-space models.',...
         ArrayDims(1:end-1)))
   else
      disp(sprintf('%s array of discrete-time state-space models.',...
         ArrayDims(1:end-1)))
   end
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = printsys(a,b,c,d,e,ulabels,ylabels,xlabels,offset)
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


if isempty(ylabels) | isequal('',ylabels{:}),
   for i=1:ny, 
      ylabels{i} = sprintf('y%d',i);
   end
else
   for i=1:ny,
      if isempty(ylabels{i}),  ylabels{i} = '?';  end
   end
end


if isempty(xlabels) | isequal('',xlabels{:}),
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
  printmat(d,[offset 'd'],ylabels,ulabels);
else
  printmat(a,[offset 'a'],xlabels,xlabels);
  printmat(b,[offset 'b'],xlabels,ulabels);
  printmat(c,[offset 'c'],ylabels,xlabels);
  printmat(d,[offset 'd'],ylabels,ulabels);
  if ~isempty(e),
     printmat(e,[offset 'e'],xlabels,xlabels);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = printmat(a,name,rlab,clab)
%PRINTMAT Print matrix with labels.
%   PRINTMAT(A,NAME,RLAB,CLAB) prints the matrix A with the row labels
%   RLAB and column labels CLAB.  NAME is a string used to name the 
%   matrix.  RLAB and CLAB are cell vectors of strings.
%
%   See also  PRINTSYS.

%   Clay M. Thompson  9-24-90
%   Revised  P.Gahinet  8-12-96

CWS = get(0,'CommandWindowSize');      % max number of char. per line
MaxLength = round(.9*CWS(1));

[nrows,ncols] = size(a);
len = 12;    % Max length of labels
Space = ' ';

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

% Print name
disp(' ')
if ~isempty(name), 
    disp([name,' = ']), 
end  

% Row labels
RowLabels = strjust(strvcat(' ',rlab{:}),'left');
RowLabels = RowLabels(:,1:min(len,end));
RowLabels = [Space(ones(nrows+1,1),ones(3,1)),RowLabels];

% Construct matrix display
Columns = cell(1,ncols);
prec = 3 + isreal(a);
for ct=1:ncols,
    clab{ct} = clab{ct}(:,1:min(end,len));
    col = [clab(ct); cellstr(deblank(num2str(a(:,ct),prec)))];
    col = strrep(col,'+0i','');  % xx+0i->xx
    Columns{ct} = strjust(strvcat(col{:}),'right');
end

% Equalize column width
lc = cellfun('size',Columns,2);
lcmax = max(lc)+2;
for ct=1:ncols,
    Columns{ct} = [Space(ones(nrows+1,1),ones(lcmax-lc(ct),1)) , Columns{ct}];
end

% Display MAXCOL columns at a time
maxcol = max(1,round((MaxLength-size(RowLabels,2))/lcmax));
for ct=1:ceil(ncols/maxcol)
    disp([RowLabels Columns{(ct-1)*maxcol+1:min(ct*maxcol,ncols)}]);
    disp(' ');
end

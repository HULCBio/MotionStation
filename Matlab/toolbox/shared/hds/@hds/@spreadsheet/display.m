function display(this)
%DISPLAY  Display method for @speadsheet class.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:34 $
if isempty(this.Grid_)
   Ns = 0;
else
   Ns = this.Grid_.Length;
end
vars = getvars(this);
Nv = length(vars);

% Build display for each column
if Ns>0
   Disp = cell(Ns,Nv);
   for ct=1:length(vars)
      % Extract data
      c = this.Data_(ct);
      Data = getArray(c);
      if ~isequal(c.SampleSize,[1 1])
         Data = c.utArray2Cell(Data);
      end

      % Create display
      if ~isa(Data,'cell')
         % Vector of scalar values
         % REVISIT: assumes double
         Disp(:,ct) = printvec(Data);
      elseif iscellstr(Data)
         % cell array of strings
         Disp(:,ct) = Data;
      else
         Disp(:,ct) = {''};
      end
   end

   % Add headers
   Disp = [get(vars,{'Name'}).' ; cell(1,Nv) ; Disp];
   Disp(2,:) = {''};

   % Limits and padding
   CWS = get(0,'CommandWindowSize');      % max number of char. per line
   MaxLength = round(.9*CWS(1));
   Space = repmat(' ',Ns+2,4);
   Count = num2str((1:Ns)');
   Count = [repmat(' ',2,size(Count,2)) ; Count];
   
   % Format display
   disp(' ')
   PrintOut = Count;
   for ct=1:Nv
      NextCol = strjust(char(Disp(:,ct)));
      if size(PrintOut,2) + size(Space,2) + size(NextCol,2)>MaxLength
         disp(PrintOut), disp(' ')
         PrintOut = Count;
      else
         PrintOut = [PrintOut Space NextCol];
      end
   end
   if size(PrintOut,2)>size(Count,2)
      disp(PrintOut), disp(' ')
   end
end

disp(sprintf('Spreadsheet with %d data points and %d variables.',Ns,Nv))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c = printvec(a)
%PRINTVEC Prints vector of doubles
nrows = length(a);
prec = 3 + isreal(a);
c = cellstr(deblank(num2str(a,prec)));
c = strrep(c,'+0i','');  % xx+0i->xx

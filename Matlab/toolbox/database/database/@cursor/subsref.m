function B = subsref(A,S)
%SUBSREF Reference a value for a Database Cursor object.
%  SUBSREF is currently only implemented for dot reference.
%  For example:
%    VALUE=H.PROPERTY
%
%  See also: GET.

% Author(s): C.F.Garvin, 10-09-00
% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/06/17 12:01:52 $

tmpcomm = ['B = A'];

for idx = 1:length(S)
    
  %Build eval command
  switch S(idx).type
      
    case '.'   %Fieldname requested
        
      %Make field name requests not case sensititive
      flds = fieldnames(A);
      uflds = upper(flds);
      i = find(strcmp(uflds,upper(S(idx).subs)));
      if ~isempty(i)
        S(idx).subs = flds{i};   
      else
        S(idx).subs = S(idx).subs;   %Substructure field names are case sensitive
      end
      tmpcomm = [tmpcomm S(idx).type S(idx).subs];
        
    case {'{}','()'}   %Index requested
        
      tmpcomm = [tmpcomm S(idx).type(1)];
      for jdx = 1:length(S(idx).subs) 
          
        if length(S(idx).subs{jdx}) > 1  %Vector passed as index value
          tmp = S(idx).subs{jdx};
          tmp = tmp(:)';
          tmpcomm = [tmpcomm '['  num2str(tmp) '],'];
          
        elseif length(S(idx).subs{jdx}) == 0   %Empty index value
          tmpcomm = [tmpcomm '[],']; 
          
        else    %Scalar or : passed as index value
          tmpcomm = [tmpcomm num2str(S(idx).subs{jdx}) ','];
        end
        
      end
      tmpcomm(end) = [];                   %Strip trailing ','
      tmpcomm = [tmpcomm S(idx).type(2)];  %Add } or )
         
  end
  
end

%Evaluate the command
try
  eval([tmpcomm ';'])
catch  
  %Catch case where {} is used as index and would return multiple outputs
  %For consistency with last release
  tmpcomm(1:3) = [];
  tmpcomm = ['B = [' tmpcomm ']'';'];
  eval(tmpcomm)
end

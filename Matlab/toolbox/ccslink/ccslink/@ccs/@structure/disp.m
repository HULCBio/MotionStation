function dummy = disp(mm)
% DISP Display object properties.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:13:37 $

fprintf('\nSTRUCTURE Object stored in memory: \n');
fprintf('  Symbol name             : %s\n',  mm.name );
fprintf('  Address                 : [ %.0f %1.0f]\n', mm.address(1), mm.address(2) );
fprintf('  Address units per value : %d au\n',mm.storageunitspervalue );
fprintf('  Size                    : [ ');
for i=1:length(mm.size),    fprintf('%d ',mm.size(i));
end;
fprintf(']\n');

fprintf('  Total Address Units     : %d au\n', mm.numberofstorageunits);
fprintf('  Array ordering          : %s \n', mm.arrayorder);

fprintf('  Members                 : ');
membnum = length(mm.membname);
if membnum==0
fprintf('None');
else
maxnum = 7;
if membnum>maxnum,  len = maxnum;
else                len = membnum;
end
for i=1:len-1,  fprintf('''%s'', ',mm.membname{i});
end
fprintf('''%s''',mm.membname{end});
if membnum>maxnum,  fprintf(', ... ');
end
end
fprintf('\n\n');

%[EOF] fprintf.m
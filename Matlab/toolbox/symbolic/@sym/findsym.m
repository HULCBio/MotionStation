function v = findsym(S,n)
%FINDSYM Finds the symbolic variables in a symbolic expression or matrix.
%   FINDSYM(S), where S is a scalar or matrix sym, returns a string 
%   containing all of the symbolic variables appearing in S. The 
%   variables are returned in alphabetical order and are separated by
%   commas. If no symbolic variables are found, FINDSYM returns the
%   empty string.  The constants pi, i and j are not considered variables.
%
%   FINDSYM(S,N) returns the N symbolic variables closest to 'x'. 
%
%   Examples:
%      findsym(alpha+a+b) returns
%       a, alpha, b
%
%      findsym(cos(alpha)*b*x1 + 14*y,2) returns
%       x1,y
%
%      findsym(y*(4+3*i) + 6*j) returns
%       y

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/15 03:08:51 $

% Convert array to scalar.
if any(size(S) > 1)
   sc = char(S(:).');
   sc(1:5) = [];
else
   sc = char(S);
end

% Get the sorted list of all symbolic variables from Maple
v = maple('indets', sc ,'symbol');

% Remove pi
if length(v) > 3 & ~isempty(findstr(v,'pi'))
   v = strrep(v,'{pi}','{}');
   v = strrep(v,', pi}','}');
   v = strrep(v,'{pi, ','{');
   v = strrep(v,',pi ,',',');
end

% Return empty string if no symbolic variables found
if strcmp(v,'{}')
    v = '';
    return;
end;

% convert v from a "set" type to a "list" type
v(1) = '[';
v(end) = ']';

v = maple(['sort(',v,',lexorder)']);

% Parse the nargin == 2 case
if nargin == 2
    commas = find(v==',');
    if (length(commas) + 1) < n
    v = v(2:end-1); 
    elseif (length(commas) + 1) >= n
    v = pickvar(v,n);
    end;

else
    v = v(2:end-1);
end;



function out = pickvar(S,n)
%PICKVAR Choose variables from an alphabetical list.
%   R = PICKVAR(S,N) takes S, a text string representing output from 
%   Maple's LEXSORT function. PICKVAR performs an additional sort on 
%   S so that the variables alphabetically closest to "x" are at the 
%   top of the list. The first N variables are then chosen and 
%   returned as R. R is a text string containing the comma-separated 
%   list of variables.
%   
%   The ordering scheme:
%      Look at the first letter in each of the variable names. Choose
%      the variable whose first letter is closest to "x", with "y"
%      having precedence over "w" and "z" over "v". The same scheme
%      holds for uppercase letters as well. To summarize, the ordering
%      is: x y w z v u ... a X Y W Z V U ... A
%   
%      For all subsequent letters, the ordering is alphabetical, with
%      all uppercase letters having precedence over lowercase.
%      ie, A B ... Z a b ...z
%
%   Examples:
%       pickvar('[alpha, underdog, x2, y, zebra]',3); --> x2, y, zebra
%       pickvar('[alpha,beta,theta,v,w,y,z]',3) --> y,w,z
%       pickvar('[x,x1,x2,y,y2]',2) --> x, x1
%       pickvar('[X,x,xY,xy]',3) --> x, xY, xy
%       pickvar('[APPLE, Apple, X, X1, apple, x]',3) --> x,apple,X
%       pickvar('[V, W, X, Y, Z, x, xY, xy]',7) --> x,xY,xy,X,Y,W,Z 

% Remove all blanks and replace brackets with commas
k = find(S==' ');
S(k) = '';
S(1) = ','; S(end) = ',';

commas = find(S==',');
size_list = length(commas)-1;

% Create VARS, a matrix of strings
vars = S(commas(1)+1:commas(2)-1);
maxlen = length(vars);
for k = 2: size_list 
    element = S(commas(k)+1:commas(k+1)-1);
    len = length(element);
    if len > maxlen
        vars = [vars setstr(abs(' ')*ones(size(vars,1),len-maxlen)); element];
        maxlen = len; 
    else
        vars = [vars; element setstr(abs(' ')*ones(1,maxlen-len))];
    end
end;

% Create a mapping from an alphabetic character to a number.
% This is used on the first letter of each variable.
% Note that uppercase is converted to lowercase prior to mapping.
first_let = vars(1:size_list,1);
map = 'x' - lower(first_let);

% Bias toward y and z by adding +0.5 to each of their maps
k = find(map<0);
map(k) = map(k) + 0.5;
% Bias toward Y and Z by adding 27 to each of their maps
k = find( (first_let >= 'A') & (first_let <= 'Z'));
map(k) = abs(map(k)) + 27;

[dummy,indx] = sort(abs(map));

% Create string of variables
out = vars(indx(1),:);
for k = 2:n
    out = [out ',' vars(indx(k),:)];
end;
% Remove all blanks
k = find(out==' ');
out(k) = '';

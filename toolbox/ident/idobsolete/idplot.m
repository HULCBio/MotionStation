function idplot(z,int,T,ny,PC)
%IDPLOT Plots input - output data. 
%   Obsolete function: use PLOT for IDDATA objects,
%
%   IDPLOT(Data)   or   IDPLOT(Data,INT)
%
%   For an IDDATA data object this is the same as PLOT(Data(INT)).
%
%   Data is the input - output data [y u]. This is plotted with output over
%   input. The data points specified in the row vector INT are selected.
%   The default value is all data.
%   If the sampling interval is T, correct time axes are obtained by
%
%   IDPLOT(Data,INT,T)
%
%   If the data is multi-output, appropriate plots are obtained by
%
%   IDPLOT(Data,INT,T,NY)
%
%   where NY is the number of outputs, i.e the ny first columns of Z.
%
%   It is assumed that the input is piecewise constant between sampling
%   instants, and it is plotted accordingly. If linear interpolation
%   between input data points is preferred, use
%   
%   IDPLOT(Z,INT,T,NY,'LI')

%   L. Ljung 87-7-8, 93-9-25
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2001/04/06 14:21:44 $

if nargin < 1
   disp('Usage: IDPLOT(DATA)')
   disp('       IDPLOT(DATA,INTERVAL,T,No_OF-OUTPUTS,STAIRS)')
   disp('       STAIRS is one of ''PC'', ''LP''.')
   return
end
if nargin<5, PC='PC';end, if isempty(PC),PC='PC';end
if nargin<4, ny=1;end,if isempty(ny),ny=1;end
if nargin<3, T=1;end,if isempty(T),T=1;end,if T<0,T=1;end
if ~isa(z,'iddata')
    if nargin<2, int=1:length(z(:,1));end
    if isempty(int),int=1:length(z(:,1));end
     z = iddata(z(int,1:ny),z(int,ny+1:end),T);
 elseif nargin >1
    z = z(int);
end
if ~strcmp(lower(PC),'pc')
    [N,ny,nu,Ne] = size(z,'nu');
    int = cell(nu,Ne);
    for ku = 1:nu
        for kexp = 1:Ne
            int{ku,kexp} = 'foh';
        end
    end
    z = pvset(z,'InterSample',int);
end

plot(z)


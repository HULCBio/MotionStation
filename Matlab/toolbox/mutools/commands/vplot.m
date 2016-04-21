function q=vplot(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,...
    a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,...
    a31,a32,a33)

% function vplot([plot_type],vmat1,vmat2,vmat3, ...)
% function vplot([plot_type],vmat1,'linetype1',vmat2,'linetype2',...)
% function vplot('bode_l',toplimits,bottomlimits,vmat1,vmat2,vmat3, ...)
%
%
%   Plot one or more varying matrices.  The syntax is
%   the same as the MATLAB plot command except that all data
%   is contained in VMATi, and the axes are specified by PLOT_TYPE.
%
%   The (optional) plot_type argument must be one of:
%
%      'iv,d'       matin .vs. independent variable (default option)
%      'iv,m'       magnitude .vs. independent variable
%      'iv,lm'      log(magnitude) .vs. independent variable
%      'iv,p'       phase .vs. independent variable
%      'liv,d'      matin .vs. log(independent variable)
%      'liv,m'      magnitude .vs. log(independent variable)
%      'liv,lm'     log(magnitude) .vs. log(independent variable)
%      'liv,p'      phase .vs. log(independent variable)
%      'ri'         real .vs. imaginary  (parametrized by indep variable)
%      'nyq'        real .vs. imaginary  (parametrized by indep variable)
%      'nic'        Nichols chart
%      'bode'       Bode magnitude and phase plots
%      'bode_g'     Bode magnitude and phase plots with grids
%      'bode_l'     Bode magnitude and phase plots with axis limits
%      'bode_gl'    Bode magnitude and phase plots with axis limits
%                   and grids
%
%   In th 'bode_l' and 'bode_gl' plot types the 2nd and 3rd arguments
%   are the top and bottom axis limit vectors.  For example:
%
%             vplot('bode_gl',[-1,1,-3,1],[-1,1,-180,0],...
%
%    See also: PLOT

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

%====================================================================
%
%       MAGNITUDE/PHASE/FREQUENCY UNIT DEFINITION
%
%       Choose only one of these commands to set up the
%       phase units.  The others must be commented out.

phasefunc = '180/pi*unwrap(angle(';         % unwrapped phase, degrees
%phasefunc = '180/pi*(angle(';      % degrees (-180 to 180)
%phasefunc = 'unwrap(angle(';               % unwrapped phase,  radians
%phasefunc = '(angle(';             % radians (-pi to pi)
%phasefunc = '180/pi*(negangle(';    % degrees (-360 to 0)
%phasefunc = '(negangle(';          % radians (-2pi to 0)

%       Choose the appropriate set of commands to setup the
%       magnitude scaling for log magnitude commands.

%magfunc = '(20*log10(';                % Scale in dB
%mplt1 = 'semilogx(';           % You must select all 3
%mplt2 = 'plot(';               % commands here.

magfunc = '(abs(';              % Scale in log magnitude
mplt1 = 'aa = loglog(';         % Again all 3 commands are
mplt2 = 'aa = semilogy(';               % required.

%       Note that 20*log10(x) gives a complex result when x is
%       complex.  The real part is equal to 20*log10(abs(x)) and
%       the MATLAB plot function plots only the real part.
%
%       The following section customizes the 'liv,..' plots.
%       In almost all cases a logarithmic independent variable
%       refers to frequency -- this section chooses between displaying
%       in radians/second and Hertz.  If you intend to use log independent
%       variable plots for something other than frequency then you should
%       select the default scaling of 1.  Note that the output
%       from frsp is in radians/second.  Choosing this throughout is
%       very strongly encouraged.

ivscale = 1;                    % frequency in radians/sec
%ivscale = 1/(2*pi);            % frequency in Hertz
%ivscale = 1/pi;                % discrete normalized frequency

%       The following section customizes the Bode plot labels.
%       Make sure that they agree with your choices for the
%       log magnitude, phase, and frequency units.

toplabel = 'Log Magnitude';
%toplabel = 'Magnitude (dB)';

bottomlabel = 'Phase (degrees)';
%bottomlabel = 'Phase (radians)';

ivlabel = 'Frequency (radians/sec)';
%ivlabel = 'Frequency (Hertz)';
%ivlabel = 'Normalized Frequency';
%====================================================================
%       END OF MAGNITUDE/PHASE/FREQUENCY UNIT DEFINITION
%===================================================================

matlab_ver = version;

str = []; str1 = []; str2 = [];

n = nargin;
if n == 0,
    disp('usage: vplot([plot_type],vmat1,vmat2,...)')
    disp('       vplot([plot_type],vmat1,linetype1,...)')
    disp('       vplot([bode_l,toplimits,bottomlimits],vmat1,vmat2,...)')
    return
end

if n > 33,
    disp('    Sorry, vplot is limited to 33 arguments')
    return
end

%==========================================================================
% Figure out which are not mu-Tools GUIs, add to top one, or create if none
%==========================================================================
eval(['typoplot = strcmp(''gui'',a' int2str(nargin) ');']);
if typoplot==1
    n = n-1;
    pltfig = gcf;
else
    go = 1;
    cc = get(0,'children');
    if ~isempty(cc)
        [mw,sw,notours] = findmuw;
        if isempty(notours)
            pltfig = figure;
        else
	    pltfig = notours(1);
            figure(pltfig);
        end
    else
	pltfig = figure;
    end;
end

pltcols(pltfig);

%       Attempt to see if the first argument is the plot_type string.
%       If it isn't use the default plot_type setting.  argstart denotes
%       the start of the data arguments.

if isstr(a1),
    argstart = 2;
    plot_type = a1;
else
    plot_type = 'iv,d';
    argstart = 1;
end

%       Determine the required plot type and what functions have
%       to be applied to the data.  Three types of plot are
%       distinguished by the variable plttype:
%
%               1:      function(data) vs. independent variable
%               2:      function(data) vs. function(data)
%               3:      customized double plot (each of type 1)
%

if strcmp(plot_type,'iv,d'),
    func = '((';
    ivscale = 1;
    pltfunc = 'aa = plot(';
    plttype = 1;
elseif strcmp(plot_type,'iv,lm'),
    func = magfunc;
    ivscale = 1;
    pltfunc = mplt2;
    plttype = 1;
elseif strcmp(plot_type,'iv,m'),
    func = '(abs(';
    ivscale = 1;
    pltfunc = 'aa = plot(';
    plttype = 1;
elseif strcmp(plot_type,'iv,p'),
    func = phasefunc;
    ivscale = 1;
    pltfunc = 'aa = plot(';
    plttype = 1;
elseif strcmp(plot_type,'liv,d'),
    func = '((';
    pltfunc = 'aa = semilogx(';
    plttype = 1;
elseif strcmp(plot_type,'liv,lm'),
    func = magfunc;
    pltfunc = mplt1;
    plttype = 1;
elseif strcmp(plot_type,'liv,m'),
    func = '(abs(';
    pltfunc = 'aa = semilogx(';
    plttype = 1;
elseif strcmp(plot_type,'liv,p'),
    func = phasefunc;
    pltfunc = 'aa = semilogx(';
    plttype = 1;
elseif strcmp(plot_type,'ri');
    func1 = 'imag(';
    func2 = 'real(';
    pltfunc = 'aa = plot(';
    plttype = 2;
elseif strcmp(plot_type,'nyq');
    func1 = 'imag(';
    func2 = 'real(';
    pltfunc = 'aa = plot(';
    plttype = 2;
elseif strcmp(plot_type,'nic');
    func1 = '20*log10(';
    func2 = '360/(2*pi)*negangle(';
    pltfunc = 'aa = plot(';
    plttype = 2;
elseif strcmp(plot_type,'bode') | strcmp(plot_type,'bode_g'),
    tfunc = magfunc;
    bfunc = phasefunc;
    tpltfunc = mplt1;
    bpltfunc = 'aaa = semilogx(';
    plttype = 3;
elseif strcmp(plot_type,'bode_l') | strcmp(plot_type,'bode_gl'),
    if nargin>=3
	tfunc = magfunc;
	bfunc = phasefunc;
	tpltfunc = mplt1;
	bpltfunc = 'aaa = semilogx(';
	plttype = 3;
	topaxis = a2;
	botaxis = a3;
	argstart = 4;
    else
	error('bode_l and bode_gl require 3 arguments');
	return
    end
else
    errstr = ['    unrecognized plot_type specification: ',plot_type];
    error(errstr)
end

%       For the particular plttype parse the argument list and
%       create the string to pass as an argument list to a standard
%       MATLAB plot routine.  The functions determined above (eg,
%       abs, angle, etc) are applied to the appropriate data.
%       If a string is found it is assumed to specify a line type
%       and is included directly in the argument list.  Constant
%       matrices are assumed to be constant over independent variables.
%       The minimum and maximum independent variables are tracked so
%       that constants can be plotted out over the full range of the
%       graph.

if plttype == 1,
    ivc = [];
    str=[];             % GJW 09/10/96
    i = argstart;
    while i <= n,
        eval(['strtest=isstr(a',num2str(i),');'])
        if strtest,
            str = [str,',a',num2str(i)];
        else
            eval(['a = a',num2str(i),';']);
            [nt,nr,nc,npts] = minfo(a);
            if nt == 'vary',
                [dat,ptr,iv] = vunpck(a);
                dat = dat.';
                dat = reshape(dat,nr*nc,npts).';
                if npts == 1,
                    dat = [dat;dat];
                    iv = [iv;iv];
                end
                eval(['dat',num2str(i),' = ',func,'dat));']);
                eval(['iv',num2str(i),' = ivscale*iv;']);
                if isempty(ivc),
                    ivc = [max(ivscale*iv); min(ivscale*iv)];
                else
                    ivc = [max(ivc(1),max(ivscale*iv)); ...
                        min(ivc(2),min(ivscale*iv))];
                end
                str = [str,',iv',num2str(i),',dat',num2str(i)];
            elseif nt == 'syst',
                error('cannot plot system matrix')
                break
            elseif nt == 'cons',
                dat = a.';
                dat = reshape(dat,nr*nc,1).';
                dat = [dat; dat];
                eval(['dat',num2str(i),' = ',func,'dat));']);
                str = [str,',ivc,dat',num2str(i)];
            else                % empty matrix so ignore and
                if i ~= n,      % discard next variable if string
                    eval(['strtest=isstr(a',num2str(i+1),');'])
                    if strtest,
                        i = i+1;
                    end
                end
            end
        end
        i = i+1;
    end

    str = str(2:length(str));
    str = [pltfunc, str, ');'];
    eval(str)
elseif plttype == 2,
    i = argstart;
    while i <= n,
        eval(['strtest=isstr(a',num2str(i),');'])
        if strtest,
            str = [str,',a',num2str(i)];
        else
            eval(['a = a',num2str(i),';']);
            [nt,nr,nc,npts] = minfo(a);
            if nt == 'vary' | nt == 'cons',
                [dat,ptr,iv] = vunpck(a);
                dat = dat.';
                if npts == 0,
                    npts = 1;
                end
                dat = reshape(dat,nr*nc,npts).';
                if npts == 1,
                    dat = [dat;dat];
                    iv = [iv;iv];
                end
                eval(['dat',num2str(i),' = ',func1,'dat);']);
                eval(['iv',num2str(i),' = ',func2,'dat);']);
                str = [str,',iv',num2str(i),',dat',num2str(i)];
            elseif nt == 'syst',
                error('cannot plot system matrix')
                break
            else                % empty matrix so ignore and
                if i ~= n,      % discard next variable if string
                    eval(['strtest=isstr(a',num2str(i+1),');'])
                    if strtest,
                        i = i+1;
                    end
                end
            end
        end
        i = i+1;
    end % while

    str = str(2:length(str));
    str = [pltfunc, str, ');'];
    eval(str)
else, %plttype == 3
    ivc = [];
    i = argstart;
    while i <= n,
        eval(['strtest=isstr(a',num2str(i),');'])
        if strtest,
            str1 = [str1,',a',num2str(i)];
            str2 = [str2,',a',num2str(i)];
        else
            eval(['a = a',num2str(i),';']);
            [nt,nr,nc,npts] = minfo(a);
            if nt == 'vary',
                [dat,ptr,iv] = vunpck(a);
                dat = dat.';
                dat = reshape(dat,nr*nc,npts).';
                if npts == 1,
                    dat = [dat;dat];
                    iv = [iv;iv];
                end
                eval(['tdat',num2str(i),' = ',tfunc,'dat));']);
                eval(['bdat',num2str(i),' = ',bfunc,'dat));']);
                eval(['iv',num2str(i),' = ivscale*iv;']);
                if isempty(ivc),
                    ivc = [max(ivscale*iv); min(ivscale*iv)];
                else
                    ivc = [max(ivc(1),max(ivscale*iv)); ...
                    min(ivc(2),min(ivscale*iv))];
                end
                str1 = [str1,',iv',num2str(i),',tdat',num2str(i)];
                str2 = [str2,',iv',num2str(i),',bdat',num2str(i)];
            elseif nt == 'syst',
                error('cannot plot system matrix')
                break
            elseif nt == 'cons',
                dat = a.';
                [nr,nc] = size(a);
                dat = reshape(dat,nr*nc,1).';
                dat = [dat; dat];
                eval(['tdat',num2str(i),' = ',tfunc,'dat));']);
                eval(['bdat',num2str(i),' = ',bfunc,'dat));']);
                str1 = [str1,',ivc,tdat',num2str(i)];
                str2 = [str2,',ivc,bdat',num2str(i)];
            else                % empty matrix so ignore and
                if i ~= n,      % discard next variable if string
                    eval(['strtest=isstr(a',num2str(i+1),');'])
                    if strtest,
                        i = i+1;
                    end
                end
            end
        end
        i = i+1;
    end

    str1 = str1(2:length(str1));
    str1 = [tpltfunc, str1, ')'];
    str2 = str2(2:length(str2));
    str2 = [bpltfunc, str2, ')'];
    subplot(211)
    if strcmp(plot_type,'bode_l') | strcmp(plot_type,'bode_gl'),
        if strcmp(matlab_ver(1),num2str(3))
            axis(topaxis)
            eval([str1 ';'])
        else
            eval([str1 ';'])
            axis(topaxis)
        end
    else
        eval([str1 ';'])
    end
    if strcmp(plot_type,'bode_g') | strcmp(plot_type,'bode_gl'),
        grid
    end
    ylabel(toplabel)
    xlabel(ivlabel)
    subplot(212)
    if strcmp(plot_type,'bode_l') | strcmp(plot_type,'bode_gl'),
        if strcmp(matlab_ver(1),num2str(3))
            axis(botaxis)
            eval([str2 ';'])
        else
            eval([str2 ';'])
            axis(botaxis)
        end
    else
        eval([str2 ';'])
    end
    if strcmp(plot_type,'bode_g') | strcmp(plot_type,'bode_gl'),
        grid
    end
    ylabel(bottomlabel)
    xlabel(ivlabel)
    %subplot(111)
    aa = [aa;aaa];
end


if nargout == 1
	q = aa;
end

%------------------------------------------------------------------------
% lmiinfo(lmisys)
%
% Gives information about the system of LMI defined in LMISYS
% This includes information about:
%   * the variable matrices (dimensions and structure)
%   * the block structure and dimensions of the LMIs
%   * the term content of each LMI
%
% Input:
%   LMISYS    internal description of the system of LMIs
%

% Author: A. Ignat   1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $

function lmiinfo(LMIsys)

if nargin~=1, error('usage: lmiinfo(lmisys)'); end

[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);


if isempty(LMI_set),
    error('LMISYS contains no information on the LMI dimensions');
elseif isempty(LMI_var),
    error('LMISYS contains no information on matrix variables');
elseif isempty(LMI_term),
    error('LMISYS contains no information on LMI terms');
end


disp(sprintf('\n\n                      LMI   ORACLE  \n'));

top = 0 ;
writevar = [' This is a system of ', num2str(size(LMI_set,2)),...
        ' LMI(s) with ',num2str(size(LMI_var,2)),' matrix variables'];
disp('                     --------------    ');
disp(sprintf('\n%s\n',writevar)) ;
disp(sprintf(' Do you want information on '));
disp('     (v) matrix variables      (l) LMIs       (q) quit   ');
rep = input('?> ','s');
while length(rep)~=1 | ~any(rep==['v' 'V' 'l' 'L' '1' 'q' 'Q']),
    disp('     (v) matrix variables      (l) LMIs       (q) quit   ');
    rep = input('?> ','s');
end

while rep ~= 'q' & rep ~= 'Q'
    
    if any(rep == ['v' 'V']),
        
        % info about variable matrices: structure, dimensions
        
        
        nrvarm = goodans(1,size(LMI_var,2),...
            ' Which variable matrix (enter its index k between ',1) ;
        writevar = ['     X',num2str(nrvarm),' is a '];
        if LMI_var(2,nrvarm) == 1
            if LMI_var(5,nrvarm) == 1 & LMI_var(6,nrvarm) == 1
                writevar = ['     x',num2str(nrvarm),' is a scalar variable\n'];
                disp(sprintf(writevar));
            else
                writevar = [writevar,num2str(LMI_var(5,nrvarm)),'x',...
                        num2str(LMI_var(6,nrvarm)),' symmetric block diagonal matrix'];
                disp(sprintf(writevar));
                
                %the block structure of on symmetric block diagonal variable
                
                for i = 1:LMI_var(7,nrvarm)
                    writevar = ...
                        ['       its (',num2str(i),',',num2str(i),')-block is a '];
                    if LMI_var(9+(i-1)*2,nrvarm) == 0
                        writevar = [ writevar,'scalar block t*I of size '];
                    elseif LMI_var(9+(i-1)*2,nrvarm) == 1
                        writevar = [ writevar,'full block of size '];
                    elseif LMI_var(9+(i-1)*2,nrvarm) == -1,
                        writevar = [ writevar,'zero block of size '];
                    else
                        disp(sprintf('         Error in variable definition: unknown block type'));
                    end
                    writevar = [writevar,num2str(LMI_var(8+(i-1)*2,nrvarm))];
                    disp(writevar);
                end
                disp(' ');
            end
        elseif LMI_var(2,nrvarm) == 2
            writevar = [writevar,num2str(LMI_var(5,nrvarm)),'x', ...
                    num2str(LMI_var(6,nrvarm)),' rectangular matrix\n'];
            disp(sprintf(writevar));
        elseif any(LMI_var(2,nrvarm) == [31 32]),
            writevar = [writevar,'matrix of type 3\n'];
            disp(sprintf(writevar));
        else
            disp(' Error in variable definition: type of structure unknown'); return;
        end
        
        
    elseif any(rep == ['l' '1' 'L']),
        % info ablout an LMI
        
        nrlmi = goodans(1,size(LMI_set,2),...
            ' Which LMI (enter its number k between ',1);
        
        
        % checks for left, right side existence and left, right
        % inner factor presence
        lmilb=LMI_set(1,nrlmi);
        islside=any(LMI_term(1,:)==lmilb);  % LHS ~=0
        isrside=any(LMI_term(1,:)==-lmilb); % RHS ~=0
        
        % Look for outer factor
        indof = find(abs(LMI_term(1,:))==lmilb & LMI_term(2,:)==0);
        isoutf = ~isempty(indof);
        if isoutf
            ptr = LMI_term(5,indof(1));  % start of outer factor record in DATA
            rN=data(ptr+1);  cN=data(ptr+2);   % outer factor dims
        end
                
        if islside == 0       % left side = 0
            writevar = ['           0   < '];
        elseif isoutf == 0    % no left outer factor
            writevar = ['          L(x)   < '] ;
        else                  % left side with outer factor
            writevar = ['          N'' * L(x) * N   < '] ;
        end
        if isrside == 0 % right side = 0
            writevar = [writevar,'  0 '];
        elseif isoutf == 0 % no right outer factor
            writevar = [writevar,'  R(x) '] ;
        else % right side with outer factor
            writevar = [writevar,'  M'' * R(x) * M '] ;
        end
        disp(sprintf('     This LMI is of the form \n')) ;
        disp(sprintf('%s\n',writevar)) ;
        writevar =['     where  the inner factor(s) has ', ...
                num2str(LMI_set(6,nrlmi)),' diagonal block(s)'] ;
        disp(writevar);
        if isoutf
            writevar = ['            the outer factor(s) is of size ',...
                    num2str(rN),'x',num2str(cN)];
            disp(writevar);
        end
        disp(sprintf('\n\n'));
        
        
        %info about the inner factor(s)
        
        
        
        % choose the inner factor
        
        switch islside + isrside
        case 2
            disp(sprintf(' Do you want info on the inner factors ?\n'));
            rlif = 'Z' ;
            while ~any(strcmpi(rlif,{'r','l','t','o'}))
                disp(sprintf('  (l) left     (r) right     (o) other LMI    (t) back to top level     '));
                rlif = input('?> ','s');
            end
            while any(strcmpi(rlif,{'r','l'}))
                disp(' ');
                lminf = 'Z';
                while ~any(strcmpi(lminf,{'b','w'}))
                    disp(' You want to see:   (w) the whole factor    (b) only one block  ?');
                    lminf = input('?> ','s');
                end
                infobw(LMI_set,LMI_var,LMI_term,data,nrlmi,rlif,lminf) ;
                rlif = 'Z' ;
                while ~any(strcmpi(rlif,{'r','l','t','o'}))
                    disp(sprintf('\n Do you want info on the inner factors ?\n'));
                    disp(sprintf('  (l) left     (r) right     (o) other LMI    (t) back to top level     '));
                    rlif = input('?> ','s');
                end
                
            end %while rlif == 'l'| 'r'
            if strcmpi(rlif,'o')
                top = 1;
            end
            
        case 1
            if islside == 0 rlif = 'r' ; writevar=[' right'];
            else rlif = 'l' ;writevar=[' left'];
            end
            disp(sprintf(' Do you want info on the%s inner factor ?\n',writevar));
            lminf = 'Z';
            while ~any(strcmpi(lminf,{'b','w','t','o'}))
                disp('        (w) whole factor     (b) only one block ');
                disp('        (o) other LMI        (t) back to top level   ');
                lminf = input('?> ','s');
            end
            
            while any(strcmpi(lminf,{'w','b'}))
                infobw(LMI_set,LMI_var,LMI_term,data,nrlmi,rlif,lminf) ;
                lminf = 'Z';
                while ~any(strcmpi(lminf,{'b','w','t','o'}))
                    disp('        (w) whole factor     (b) only one block ');
                    disp('        (o) other LMI        (t) back to top level   ');
                    lminf = input('?> ','s');
                end
                
            end % while lminf = 'w' | 'b'
            if strcmpi(lminf,'o')
                top = 1;
            end
            
        otherwise 
            disp(sprintf(' LMI %i : 0 < 0 !\n',nrlmi)) ;
        end
        
        
    end %if rep
    if top == 0
        writevar = [' This is a system of ', num2str(size(LMI_set,2)),...
                ' LMI with ',num2str(size(LMI_var,2)),' variable matrices'];
        disp('                     --------------    ');
        disp(sprintf('\n%s\n',writevar)) ;
        disp(sprintf(' Do you want information on '));
        rep = 't' ;
        while ~any(strcmpi(rep,{'v','1','l','q'}))
            disp('     (v) matrix variables     (l) LMIs      (q) quit   ');
            rep = input('?> ','s');
        end
    else 
        top = 0;
    end
    
end % while rep

disp(' ');
disp(sprintf(' It has been a pleasure serving you!\n'));

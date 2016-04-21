function [output_stack,IRR,ORR,ARR] = evalfis(input_stack, fismatrix);
% EVALFIS Evaluation of a fuzzy inference system.
%   OUTPUT_STACK = EVALFIS(INPUT_STACK, FISMATRIX) computes the
%   output of a fuzzy inference system specified by FISMATRIX.
%   INPUT_STACK can be a vector specifying the input vector, or
%   a matrix where each row specifies an input vector.
%   OUTPUT_STACK is a stack of output (row) vectors.
%
%   For example:
%
%       [xx, yy] = meshgrid(-5:5);
%       input = [xx(:) yy(:)];
%       fismat = readfis('mam21');
%       out = evalfis(input, fismat);
%       surf(xx, yy, reshape(out, 11, 11))
%       title('evalfis')

%   Roger Jang, 11-19-93, 1-17-94, 9-29-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:22:27 $

global GLOBAL_FIS_MATRIX
global FIS_NAME FIS_TYPE IN_N OUT_N IN_MF_N OUT_MF_N RULE_N
global AND_METHOD OR_METHOD IMP_METHOD AGG_METHOD DEFUZZ_METHOD
global BOUND IN_MF_TYPE OUT_MF_TYPE RULE_LIST AND_OR RULE_WEIGHT
global IN_PARAM OUT_PARAM
global OUT_TEMPLATE_MF OUT_MF QUALIFIED_OUT_MF OVERALL_OUT_MF

point_n = 101;
mf_para_n = 4;

initialization = 1;
% Check if initialization necessary.
if (size(fismatrix, 1) == size(GLOBAL_FIS_MATRIX, 1)),
if (size(fismatrix, 2) == size(GLOBAL_FIS_MATRIX, 2)),
if ~isequal(fismatrix,GLOBAL_FIS_MATRIX),
    initialization = 0;
end
end
end

% Unpack data and initialize global variables.
if initialization,
    GLOBAL_FIS_MATRIX = fismatrix;
    FIS_NAME =  fismatrix.name;  
    FIS_TYPE =  fismatrix.type;
    FIS_TYPE(find(FIS_TYPE == 0)) = [];
    IN_N =      length(fismatrix.input);
    OUT_N =     length(fismatrix.output);
    for i=1:IN_N
     IN_MF_N(i) =   length(fismatrix.input(i).mf);
    end
    for i=1:OUT_N
     OUT_MF_N(i) =  length(fismatrix.output(i).mf);
    end

    RULE_N =    length(fismatrix.rule);

    AND_METHOD =    fismatrix.andMethod;
    OR_METHOD =     fismatrix.orMethod;
    IMP_METHOD =    fismatrix.impMethod;
    AGG_METHOD =    fismatrix.aggMethod;
    DEFUZZ_METHOD = fismatrix.defuzzMethod;
    AND_METHOD(find(AND_METHOD == 0)) = [];
    OR_METHOD(find(OR_METHOD == 0)) = [];
    IMP_METHOD(find(IMP_METHOD == 0)) = [];
    AGG_METHOD(find(AGG_METHOD == 0)) = [];
    DEFUZZ_METHOD(find(DEFUZZ_METHOD == 0)) = [];
    IN_MF_TYPE=[];
    for i=1:IN_N
         in_bound(i, 1:2)=fismatrix.input(i).range;
         for j=1:length(fismatrix.input(i).mf)
           IN_MF_TYPE=strvcat(IN_MF_TYPE, fismatrix.input(i).mf(j).type);
         end
    end
    for i=1:OUT_N
         out_bound(i, 1:2)=fismatrix.output(i).range;
         for j=1:length(fismatrix.output(i).mf)
           OUT_MF_TYPE=strvcat(OUT_MF_TYPE, fismatrix.output(i).mf(j).type);
         end
    end
    
    BOUND =     [in_bound; out_bound];

    
%%%    tmp =       getfis(fismatrix, 'rulelist');
%%%    for i=1:length(fismatrix.rulenew)
%%%      RULE_WEIGHT(i,:) =   fismatrix.rulenew(i).weight;
%%%      AND_OR(i,:) =        fismatrix.rulenew(i).connective;
%%%      RULE_LIST(i,:) = fismatrix.rulenew(i).weight;

    tmp =       getfis(fismatrix, 'rulelist');
    RULE_WEIGHT =   tmp(:, IN_N+OUT_N+1);
    AND_OR =        tmp(:, IN_N+OUT_N+2);
    RULE_LIST = tmp(:, 1:IN_N+OUT_N);

    
    k=1;
    totalInputMFs=sum(IN_MF_N);
    totalOutputMFs=sum(OUT_MF_N);
    IN_PARAM=zeros(totalInputMFs, 4);
    for i=1:IN_N
       for j=1:length(fismatrix.input(i).mf)
          temp=fismatrix.input(i).mf(j).params;
          IN_PARAM(k,1:length(temp))=temp;
          k=k+1;
       end
    end
    k=1;
    OUT_PARAM=zeros(totalOutputMFs, 4);
    for i=1:OUT_N
       for j=1:length(fismatrix.output(i).mf)
          temp=fismatrix.output(i).mf(j).params;
          OUT_PARAM(k,1:length(temp))=temp;
          k=k+1;
       end
    end
    

    if strcmp(FIS_TYPE, 'sugeno'),
        OUT_PARAM = OUT_PARAM(:, 1:IN_N+1);
    elseif strcmp(FIS_TYPE, 'mamdani'),
        OUT_PARAM = OUT_PARAM(:, 1:mf_para_n);
    else
        error('Unknown FIS type!');
    end

    if strcmp(FIS_TYPE, 'mamdani'),
        % Compute OUT_TEMPLATE_MF
        OUT_TEMPLATE_MF = zeros(sum(OUT_MF_N), point_n);
        cum_mf = cumsum(OUT_MF_N);
        for i = 1:sum(OUT_MF_N),
            tmp = find((cum_mf-i) >= 0);
            output_index = tmp(1);      % index for output
            OUT_TEMPLATE_MF(i, :) = ...
                evalmf(linspace(BOUND(IN_N+output_index,1), ...
                BOUND(IN_N+output_index,2), point_n), ...
                OUT_PARAM(i, :), deblank(OUT_MF_TYPE(i, :)));
        end

        % Reorder to fill OUT_MF, an (RULE_N X point_n*OUT_N) matrix.
        OUT_MF = zeros(RULE_N, point_n*OUT_N);
        for i = 1:RULE_N,
            for j = 1:OUT_N,
                mf_index = RULE_LIST(i, IN_N+j);
                index = sum(OUT_MF_N(1:j-1)) + abs(mf_index);
                if mf_index > 0,    % regular MF
                    OUT_MF(i, (j-1)*point_n+1:j*point_n) = ...
                        OUT_TEMPLATE_MF(index, :); 
                elseif mf_index < 0,% Linguistic hedge "NOT"
                    OUT_MF(i, (j-1)*point_n+1:j*point_n) = ...
                        1 - OUT_TEMPLATE_MF(index, :); 
                else                % Don't care (MF index == 0)
                    OUT_MF(i, (j-1)*point_n+1:j*point_n) = ...
                        ones(1, point_n);
                end
            end
        end

        % Allocate other matrices
        QUALIFIED_OUT_MF = zeros(RULE_N, point_n*OUT_N);
        OVERALL_OUT_MF = zeros(1, point_n*OUT_N);
    end
%   fprintf('Global variables for %s FIS are initialized\n', FIS_NAME);
end
% End of initialization

% Error checking for input stack
m = size(input_stack, 1);
n = size(input_stack, 2);
if ~((n >= IN_N) | ((n == 1) & (m >= IN_N))),
    fprintf('The input stack is of size %dx%d,', m, n);
    fprintf('while expected input vector size is %d.\n', IN_N);
    error('Exiting ...');
end
if ((n == 1) & (m == IN_N))
    data_n = 1;
    input_stack = input_stack';
else
    data_n = m;
end

% Allocate output stack
output_stack = zeros(data_n, OUT_N);

% Iteration through each row of input stack

for kkk = 1:data_n,
input = input_stack(kkk, :);

% Find in_template_mf_value
in_template_mf_value = zeros(sum(IN_MF_N), 1);
cum_mf = cumsum(IN_MF_N);
for i = 1:sum(IN_MF_N),
    tmp = find((cum_mf-i) >= 0);
    input_index = tmp(1);
    in_template_mf_value(i) = ...
    evalmf(input(input_index), IN_PARAM(i, :), deblank(IN_MF_TYPE(i, :)));
end

% Reordering to fill in_mf_value, which is an (RULE_N X IN_N) matrix.
index = ones(RULE_N, 1)*cumsum([0 IN_MF_N(1:IN_N-1)]) +...
    abs(RULE_LIST(:, 1:IN_N));
zero_index = find(index == 0);  % index for don't care MF
index(zero_index) = ones(size(zero_index)); % temp. setting for easy indexing
in_mf_value = reshape(in_template_mf_value(index), RULE_N, IN_N);

% Take care of don't care (MF index is zero)
% tmp1 is the position index for zeor mf index in a AND rule
tmp1 = find(((AND_OR(:, ones(IN_N, 1))==1).*(RULE_LIST(:, 1:IN_N)==0))==1);
in_mf_value(tmp1) = ones(size(tmp1));% take care of zero index
% tmp2 is the position index for zeor mf index in a OR rule
tmp2 = find(((AND_OR(:, ones(IN_N, 1))==2).*(RULE_LIST(:, 1:IN_N)==0))==1);
in_mf_value(tmp2) = zeros(size(tmp2));% take care of zero index

% Take care of linguistic hedge NOT (MF index is negative) 
neg_index = find(RULE_LIST(:, 1:IN_N) < 0);
in_mf_value(neg_index) = 1 - in_mf_value(neg_index);
%disp(in_mf_value);

% Find the firing strengths
% AND_METHOD = 'min' or 'prod'; which is used as function name too
% OR_METHOD = 'max' or 'probor'; which is used as function name too
firing_strength = zeros(RULE_N, 1);
and_index = find(AND_OR == 1);
or_index = 1:RULE_N;
or_index(and_index) = [];
if IN_N ~= 1,
    firing_strength(and_index) = feval(AND_METHOD, in_mf_value(and_index, :)')';
    firing_strength(or_index) = feval(OR_METHOD, in_mf_value(or_index, :)')';
else
    firing_strength = in_mf_value;
end
%disp(firing_strength);

% Recalculate firing strengths scaled by rule weights
firing_strength = firing_strength.*RULE_WEIGHT;

% Find output
if strcmp(FIS_TYPE, 'sugeno'),
    template_output = OUT_PARAM*[input(:); 1]; % Output for template

    % Reordering according to the output part of RULE_LIST; 
    % Negative MF index will becomes positive
    index = ones(RULE_N, 1)*cumsum([0 OUT_MF_N(1:OUT_N-1)]) +...
        abs(RULE_LIST(:, IN_N+1:IN_N+OUT_N));
    zero_index = find(index == 0);
    index(zero_index) = ones(zero_index);   % temp. setting for easy indexing
    rule_output = reshape(template_output(index), RULE_N, OUT_N);
    zero_index = find(RULE_LIST(:, IN_N+1:IN_N+OUT_N) == 0);
    rule_output(zero_index) = zeros(size(zero_index));  % take care of zero index
    sum_firing_strength = sum(firing_strength);

    if sum_firing_strength == 0
        fprintf('input = [');
        for i=1:IN_N,
            fprintf('%f ', input(i));
        end
        fprintf(']\n');
        error('Total firing strength is zero!');
    end

    if strcmp(DEFUZZ_METHOD, 'wtaver'),
        output_stack(kkk, :) = firing_strength'*rule_output/sum_firing_strength;
    elseif strcmp(DEFUZZ_METHOD, 'wtsum'),
        output_stack(kkk, :) = firing_strength'*rule_output;
    else
        error('Unknown defuzzification method!');
    end

elseif strcmp(FIS_TYPE, 'mamdani'),
    % Transform OUT_MF to QUALIFIED_OUT_MF
    % Duplicate firing_strength.
    tmp = firing_strength(:, ones(1, point_n*OUT_N));

    if strcmp(IMP_METHOD, 'prod'),      % IMP_METHOD == 'prod'
        QUALIFIED_OUT_MF = tmp.*OUT_MF;
    elseif strcmp(IMP_METHOD, 'min'),   % IMP_METHOD == 'min'
        QUALIFIED_OUT_MF = feval(IMP_METHOD, tmp, OUT_MF);
    else    % IMP_METHOD is user-defined
        tmp1 = feval(IMP_METHOD, [tmp(:)'; OUT_MF(:)']);
        QUALIFIED_OUT_MF = reshape(tmp1, RULE_N, point_n*OUT_N);
    end

    % AGG_METHOD = 'sum' or 'max' or 'probor' or user-defined
    OVERALL_OUT_MF = feval(AGG_METHOD, QUALIFIED_OUT_MF);

    for i = 1:OUT_N;
        output_stack(kkk, i) = defuzz( ...
        linspace(BOUND(IN_N+i,1), BOUND(IN_N+i,2), point_n), ...
            OVERALL_OUT_MF(1, (i-1)*point_n+1:i*point_n), ...
            DEFUZZ_METHOD);
    end
else
    fprintf('fis_type = %d\n', FIS_TYPE);
    error('Unknown FIS type!');
end
end

if nargout >= 2, IRR = in_mf_value; end 

if strcmp(FIS_TYPE, 'sugeno'),
    if nargout >= 3,
        ORR = rule_output;
    end
    if nargout >= 4,
        ARR = firing_strength(:, ones(1,OUT_N));
    end
else
    if nargout >= 3,
        ORR = [];
        for iii = 1:OUT_N,
            ORR = [ORR; QUALIFIED_OUT_MF(:,(iii-1)*point_n+1:iii*point_n)];
        end
        ORR = ORR';
    end
    if nargout >= 4,
        ARR = reshape(OVERALL_OUT_MF, point_n, OUT_N);
    end
end

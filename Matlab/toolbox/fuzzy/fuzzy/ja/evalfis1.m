% EVALFIS1 は、ファジィ推論システムを計算します。
% OUTPUT_STACK = EVALFIS1(INPUT_STACK, FISMATRIX) は、FISMATRIX で設定さ
% れるファジィ推論システムの出力を計算します。INPUT_STACK は、入力ベクト
% ル、または、行列を設定するベクトルで、行列の場合、各行は入力ベクトルを
% 指定します。OUTPUT_STACK は、出力(行)ベクトルのスタックです。
%
% 例題：
%
%       [xx, yy] = meshgrid(-5:5);
%       input = [xx(:) yy(:)];
%       fismat = readfis('mam21');
%       out = evalfis(input, fismat);
%       surf(xx, yy, reshape(out, 11, 11))
%       title('evalfis')


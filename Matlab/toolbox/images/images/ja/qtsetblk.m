% QTSETBLK   4�����̃u���b�N�l�̐ݒ�
%
% J = QTSETBLK(I,S,DIM,VALS) �́AI ��4�����̒��̊e�X�� DIM �s DIM ���
% �u���b�N��VALS �̒��̑Ή����� DIM �s DIM ��̃u���b�N�ƒu�������܂��B
% S �� QTDECOMP �ɂ��o�͂����X�p�[�X�s��ł��B���Ȃ킿�A4�����̍\��
% ���܂�ł��܂��BVALS �́ADIM x DIM x K �z��ɂȂ�܂��B�����ŁAK �́A
% 4������ DIM �s DIM ��̃u���b�N�̐��ł��B
%
% �N���X�T�|�[�g
% -------------
% I �́Alogical�Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X��
% �T�|�[�g���Ă��܂��BS �́A�N���X sparse �ł��B
%
% ����
% ----
% VALS �̒��̃u���b�N�̏��Ԃ́AI �̒��̃u���b�N�̗�����̏��Ԃƈ�v
% ���Ă��܂��B���Ƃ��΁AVALS ��4x4x2�̏ꍇ�AVALS(:,:,1) �́AI �̒���
% �ŏ���4�s4��̃u���b�N�̒l���܂�ł��܂��B�����āAVALS(:,:,2) �́A
% 2�Ԗڂ�4�s4��̃u���b�N�̒l���܂�ł��܂��B
%
% ���
% ----
%       I = [1    1    1    1    2    3    6    6
%            1    1    2    1    4    5    6    8
%            1    1    1    1   10   15    7    7
%            1    1    1    1   20   25    7    7
%           20   22   20   22    1    2    3    4
%           20   22   22   20    5    6    7    8
%           20   22   20   20    9   10   11   12
%           22   22   20   20   13   14   15   16];
%
%       S = qtdecomp(I,5);
%       newvals = cat(3,zeros(4),ones(4));
%       J = qtsetblk(I,S,4,newvals);
%
% �Q�l�FQTDECOMP, QTGETBLK



%   Copyright 1993-2002 The MathWorks, Inc.  

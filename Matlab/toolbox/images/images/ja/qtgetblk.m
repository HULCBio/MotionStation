% QTGETBLK   4�����̃u���b�N�l�̎擾
%
% [VALS,R,C] = QTGETBLK(I,S,DIM) �́AI ��4�������� DIM �s DIM ��̃u
% ���b�N���܂ޔz��� VALS �ɏo�͂��܂��BS �́AQTDECOMP �ɂ��o�͂����
% �X�p�[�X�s��ł��B���Ȃ킿�A4�����̍\�����܂�ł��܂��BVALS �́A
% DIM x DIM x K �z��ɂȂ�܂��B�����ŁAK ��4������ DIM �s DIM ���
% �u���b�N�̐��ł��B�ݒ肵���傫���̃u���b�N�����݂��Ȃ��ꍇ�A���ׂĂ�
% �o�͂͋�s��ɂȂ�܂��BR �� C �́A�u���b�N�̍�����̍s���W�Ɨ���W��
% �܂ރx�N�g���ł��B
%
% [VALS,IDX] = QTGETBLK(I,S,DIM) r�́A�u���b�N�̍�����̐��`�C���f�b�N�X
% ���܂ރx�N�g���� IDX �ɏo�͂��܂��B
%
% �N���X�T�|�[�g
% -------------
% I �́Alogical�Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X��
% �T�|�[�g���Ă��܂��BS �́A�N���X sparse �ł��B
%
% ����
% ----
% VALS �̒��̃u���b�N�̏��Ԃ́AI �̒��̃u���b�N�̗�����̏��Ԃƈ�v��
% �Ă��܂��B���Ƃ��΁AVALS ��4x4x2�̏ꍇ�AVALS(:,:,1) �́AI �̒���
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
%       [vals,r,c] = qtgetblk(I,S,4);
%
% �Q�l�FQTDECOMP, QTSETBLK



%   Copyright 1993-2002 The MathWorks, Inc.  

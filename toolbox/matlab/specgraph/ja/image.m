% IMAGE   �C���[�W�̕\��
% 
% IMAGE(C) �́A�s�� C ���C���[�W�Ƃ��ĕ\�����܂��BC �̊e�v�f�́A�C���[�W
% ����patch�̃J���[���w�肵�܂��BC �́AM�sN��܂���MxNx3�̍s��ŁA
% double,uint8�܂���uint16�̃f�[�^���܂�ł��܂��B
%
% C ��2������M�sN��̍s��̂Ƃ��AC �̗v�f�́A�J���[���w�肷�邽�߂ɁA
% �J�����g��COLORMAP�̃C���f�b�N�X�Ƃ��Ďg�p����܂��B�C���[�W�I�u�W�F�N�g
% �� CDataMapping �v���p�e�B�̒l�́A�J���[�}�b�v�̗v�f��I��������@��
% �w�肵�܂��BCDataMapping �� 'direct'(�f�t�H���g)�̏ꍇ�AC �̒l�̓J���[
% �}�b�v�̃C���f�b�N�X�Ƃ��Ď�舵���܂�(double�Ȃ�1�x�[�X�Auint8 �܂���
% uint16 �Ȃ��0�x�[�X)�B CDataMapping �� 'scaled' �̏ꍇ�AC�l�́A�ŏ���
% �f�[�^ CLim �ɏ]���ăX�P�[�����O����A�����̌��ʃJ���[�}�b�v�̃C��
% �f�b�N�X�Ƃ��Ď�舵���܂��BC ��3������MxNx3�s�̂Ƃ��AC(:,:,1) �̗v�f��
% �Ԃ̋��x�AC(:,:,2)�̗v�f�͗΂̋��x�AC(:,:,3)�v�f�͐̋��x�Ƃ��ĉ���
% ����Aimage�� CDataMapping�v���p�e�B�͖�������܂��Bdouble���܂ލs���
% �΂��āA�J���[�̋��x�� [0.0, 1.0] �͈̔͂ł��Buint8�܂���uint16���܂�
% �s��ɑ΂��āA�J���[�̋��x�� [0, 255] �͈̔͂ł��B
%
% IMAGE(C) �́A�v�f C(1,1) �̒��S������(1,1)�ɐݒ肵�A�v�f(M,N)�̒��S��
% ����(M,N)�ɐݒ肵�āA���ƍ�����1�̒P�ʂƂ��āA�epatch��`�悵�܂��B
% ���ʂƂ��āA�C���[�W�̊O���͈̔͂́A���� [0.5 N+0.5 0.5 M+0.5] �ɂȂ�A
% �e�C���[�W�̒��S�̃s�N�Z���́A1��M�܂���N�̊Ԃ͈̔͂̐����ŕ\���ꂽ���W
% �ɐݒ肳��܂��B
%
% IMAGE(X,Y,C) �́AX �� Y ���x�N�g���̂Ƃ��AC(1,1) �� C(M,N) �̃s�N�Z����
% ���S�̈ʒu���w�肵�܂��B�v�f C(1,1) �́A(X(1)�AY(1))�𒆐S�Ƃ��A�v�f 
% C(M,N) �� (X(end)�AY(end)) �𒆐S�Ƃ��AC �̎c��̗v�f�̒��S�̃s�N�Z���́A
% ������2�_�̊Ԃɓ��Ԋu�ɐݒ肳���̂ŁApatch�́A���ׂē������ƍ�����
% �Ȃ�܂��B
%
% IMAGE �́AIMAGE�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% C �܂��� X,Y,C ��3�v�f�̌�ɁA�C���[�W�̃v���p�e�B���w�肷�邽�߂ɁA
% �p�����[�^�ƒl�̑g�𑱂��邱�Ƃ��ł��܂��BC �܂��� X,Y,C ��3�v�f��
% �ȗ����āA�p�����[�^�ƒl�̑g���킹���g���Ă��ׂẴv���p�e�B���w��
% �ł��܂��B
%
% IMAGE(...,'Parent',AX) �́A�쐬���ɃC���[�W�I�u�W�F�N�g�̐eaxes�Ƃ�
% ��AX���w�肵�܂��B 
%
% C �܂��� X,Y,C ���g���ČĂяo�����Ƃ��AIMAGE �̓C���[�W���͂ނ悤��
% ���͈̔͂�ݒ肵�Aaxes�� Ydir �v���p�e�B�� 'reverse' �ɁAaxes�� View 
% �v���p�e�B�� [0 90] �ɐݒ肵�܂��B
%
% �C���[�W�I�u�W�F�N�g�́Aaxes�� [0 90] �ȊO�̊p�x V �ł͕`�悳��܂���B
% �C���[�W����]���邱�Ƃɂ���ē��l�̌��ʂ𓾂�ɂ́A�e�L�X�g�}�b�s���O
% �Ƌ��� SURF ���g�����A�܂��� PCOLOR ���g���Ă��������B
%
% H ���C���[�W�̃n���h���ԍ��̂Ƃ��A�C���[�W�I�u�W�F�N�g�̃v���p�e�B��A
% �J�����g�̒l�̃��X�g�����邽�߂ɂ́AGET(H) �����s���Ă��������B�C���[�W
% �I�u�W�F�N�g�̃v���p�e�B��L���ȃv���p�e�B�l�̃��X�g�����邽�߂ɂ́A
% SET(H) �����s���Ă��������B
%
% �Q�l�FIMAGESC, COLORMAP, PCOLOR, SURF, IMREAD, IMWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 

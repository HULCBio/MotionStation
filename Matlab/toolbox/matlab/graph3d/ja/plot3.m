% PLOT3   3�����̃��C���Ɠ_�̃v���b�g
% 
% PLOT3() �́APLOT()��3�����o�[�W�����ł��B
%
% PLOT3(x,y,z) �́Ax�Ay�Az �����������̃x�N�g���̂Ƃ��A���W�� x�Ay�Az ��
% �v�f�ł���_��ʂ郉�C����3������ԂɃv���b�g���܂��B
% 
% PLOT3(X,Y,Z) �́AX�AY�AZ �������T�C�Y�̍s��̂Ƃ��AX�AY�AZ �̗񂩂�
% �����镡���̃��C�����v���b�g���܂��B
% 
% ���C���^�C�v�A�v���b�g�V���{���A�J���[�́APLOT3(X,Y,Z,s) �Ŏw��ł��܂��B
% s �́APLOT �R�}���h�ɂ��\�������L�����N�^��������A1�A2�A3 ��
% �����ꂩ�̃L�����N�^�̕�����ł��B
% 
% PLOT3(x1,y1,z1,s1,x2,y2,z2,s2,x3,y3,z3,s3,...) �́A(x,y,z,s) ��4�v�f�Œ�`
% �����v���b�g��g���킹�܂��Bx�Ay�Az �̓x�N�g���܂��͍s��ŁAs �͕�����
% �ł��B
% 
% ���: helix(����)
% 
%     t = 0:pi/50:10*pi;
%     plot3(sin(t),cos(t),t);
% 
% PLOT3 �́ALINE���ɕt����ꂽLINESERIES�I�u�W�F�N�g�̃n���h���ԍ�
% ����Ȃ��x�N�g�����o�͂��܂��BX�AY�AZ ��3�v�f�܂��� X�AY�AZ�AS ��
% 4�v�f�̂��ɂ́A���C���̃v���p�e�B���w�肷�邽�߂ɁA�p�����[�^�ƒl
% �̑g���w�肵�܂��B
%
% �Q�l�FPLOT, LINE, AXIS, VIEW, MESH, SURF.

%-------------------------------
% �ڍגǉ�:
%
%
% NextPlot axis �v���p�e�B �� REPLACE (HOLD �� off) �̏ꍇ�APLOT3 �́A
% Position ���������ׂĂ� axis �v���p�e�B���f�t�H���g�l�Ƀ��Z�b�g���A
% ���ׂĂ� axis children (line, patch, text, surface, ����сAimage
% �I�u�W�F�N�g) ���폜���܂��B

% Copyright 1984-2002 The MathWorks, Inc. 
% WHO   �J�����g�̕ϐ��̕\��
% 
% WHO �́A�J�����g�̃��[�N�X�y�[�X�ɂ���ϐ������X�g���܂��B
% WHOS �́A�e�ϐ��ɂ��� WHO �����ڍׂȏ����o�͂��܂��B
% WHO GLOBAL �� WHOS GLOBAL �́A�O���[�o�����[�N�X�y�[�X�ɂ���ϐ���
% ���X�g���܂��B
% WHO -FILE FILENAME �́A�w�肵��.MAT�t�@�C���̕ϐ������X�g���܂��B
%
% WHO ... VAR1 VAR2 �́A�w�肵���ϐ������ɕ\���𐧌����܂��B�p�^�[����
% ��v����ϐ���\�����邽�߂� ���C���h�J�[�h�L�����N�^ '*' ���g�����Ƃ�
% �ł��܂��B���Ƃ��΁AWHO A* �́A�J�����g�̃��[�N�X�y�[�X���� A ����
% �n�܂邷�ׂĂ̕ϐ����������A�\�����܂��B
%
% WHO -REGEXP PAT1 PAT2 �́A���K�\�����g�p����w��p�^�[���Ɉ�v����
% ���ׂĂ̕ϐ���\�����邽�߂Ɏg�p�ł��܂��B
% ���K�\���̎g�p�ɂ��Ă̏ڍׂ𓾂�ɂ́A�R�}���h�v�����v�g�ŁA
% "doc regexp" �Ɠ��͂��Ă��������B
%
% �t�@�C�����܂��͕ϐ�����������ɕۑ�����Ă���Ƃ��́A
% WHO('-file',FILE,V1,V2) �̂悤�Ȋ֐��`���̃V���^�b�N�X���g����
% ���������B
%
% S = WHO(...) �́A���[�N�X�y�[�X�܂��̓t�@�C�����̕ϐ������܂ރZ���z���
% �o�͂��܂��B�o�͈���������Ƃ��́A�֐��`���� WHO ���g���Ă��������B
%
%
% �p�^�[���}�b�`���O�̗�:
%       who a*                      % "a" �ł͂��܂�ϐ�����\��
%       who -regexp ^b\d{3}$        % "b" �ł͂��܂�A 3 digits
%                                   % �������ϐ�����\��
%       who -file fname -regexp \d  % MAT-�t�@�C�� fname �ɑ��݂���
%                                   % �C�� digits ���܂ޕϐ�����\��
%
% �Q�l WHOS, SAVE, LOAD.

%   Copyright 1984-2003 The MathWorks, Inc. 
% SAVE   ���[�N�X�y�[�X�ϐ����f�B�X�N��ɕۑ�
% 
% SAVE FILENAME �́A���ׂẴ��[�N�X�y�[�X�ϐ����AFILENAME .mat �Ƃ���
% �o�C�i��"MAT-�t�@�C��"�ɕۑ����܂��B�f�[�^�́ALOAD �œǂݍ��ނ��Ƃ�
% �ł��܂��BSAVE FILENAME �Ɋg���q���Ȃ��ꍇ�́A.mat �����肵�܂��B
%
% SAVE ���g�ł́A'matlab.mat' �Ɩ��t�����o�C�i��'MAT �t�@�C��'���쐬����
% ���B'matlab.mat' ���������݂ł��Ȃ��ꍇ�́A�G���[�ɂȂ�܂��B
%
% SAVE FILENAME X �́AX �݂̂�ۑ����܂��B
% SAVE FILENAME X Y Z �́AX�AY�AZ ��ۑ����܂��B���C���h�J�[�h'*'�́A�p
% �^�[���Ɉ�v����ϐ��݂̂�ۑ����܂��B
%
% SAVE FILENAME -REGEXP PAT1 PAT2  �́A���K�\�����g�p����w��p�^�[��
% �Ɉ�v���邷�ׂĂ̕ϐ���ۑ����邽�߂Ɏg�p�ł��܂��B
% ���K�\���̎g�p�ɂ��Ă̏ڍׂ́A�R�}���h�v�����v�g�ŁA"doc regexp" 
% �Ɠ��͂��Ă��������B
%
% SAVE FILENAME -STRUCT S �́A�X�J���[�\���� S �̃t�B�[���h���A
% �t�@�C�� FILENAME ���̌X�̕ϐ��Ƃ��ĕۑ����܂��B
% SAVE FILENAME -STRUCT S X Y Z  �́A�t�B�[���h S.X, S.Y ����� S.Z ��
% FILENAME �ɁA�X�̕ϐ� X, Y ����� Z �Ƃ��ĕۑ����܂��B
%
% ASCII �I�v�V�����F
%  SAVE ...  -ASCII  �́A�t�@�C���g���q�Ɋւ�炸�A�o�C�i���̑����
%		     8����ASCII�������g���܂��B
%  SAVE ...  -ASCII -DOUBLE �́A16����ASCII�������g���܂��B
%  SAVE ...  -ASCII -TABS �́A�^�u�ŋ�؂�܂��B
%  SAVE ...  -ASCII -DOUBLE -TABS ��16���ŁA�^�u�ŋ�؂��܂��B
%
% MAT �I�v�V�����F
%  SAVE ...  -MAT �́A�g���q�Ɋւ�炸�AMAT�`���ŕۑ����܂��B
%  SAVE ...  -V4 �́AMATLAB 4�����[�h�ł���`����MAT-�t�@�C����ۑ���
%             �܂��B
%  SAVE ...  -APPEND �́A�����̃t�@�C��(MAT-�t�@�C���̂�)�ɕϐ���ǉ�
% 		     ���܂��B
%
%  SAVE ... -COMPRESS  �́A�ϐ������k���A��菬����MAT-�t�@�C���ɂ��܂��B
%                       -COMPRESS �I�v�V�����́A-V4 �܂��� -ASCII
%                       �ƂƂ��Ɏg�p���邱�Ƃ��ł��܂���B
%
%  SAVE ... -NOUNICODE �́AMAT-�t�@�C�����ȑO�̃o�[�W������MATLAB�ɂ��
%�@�@�@�@�@�@�@�@�@�@�@�ǂ߂�悤�ɁA�V�X�e���f�t�H���g�����G���R�[�f�B���O
%                      �X�L�[���ł��ׂĂ̕����f�[�^��ۑ����܂��B 
%                      -NOUNICODE�I�v�V�����́A -V4 �I�v�V�����ƂƂƂ���
%                      �g�p���邱�Ƃ��ł��܂���B
%
% -V4 �I�v�V�������g�p����Ƃ��́AMATLAB 4 �ƌ݊����̂Ȃ��ϐ��́AMAT-
% �t�@�C���ɕۑ�����܂���B���Ƃ��΁AN�����z��A�\���́A�Z���Ȃǂ́A
% MATLAB 4 ��MAT-�t�@�C���ɕۑ�����܂���B�܂��A19 ���������������O
% �����ϐ����AMATLAB 4 �� MAT-�t�@�C���ɕۑ�����܂���B
%
% �t�@�C�����܂��͕ϐ�����������Ƃ��Ċi�[����Ă���Ƃ��́A���Ƃ��΁A
% SAVE('filename','var1','var2') �̂悤�� SAVE �̊֐��`���̃V���^�b�N�X
% ���g���Ă��������B
%
% �p�^�[���}�b�`���O�̗�:
%     save fname a*                % "a" �ł͂��܂�ϐ���ۑ�
%     save fname -regexp ^b\d{3}$  % "b" �ł͂��܂�A 3 digits
%                                  %  �������ϐ���ۑ�
%     save fname -regexp \d        % �C�� digits ���܂ޕϐ���ۑ�
%
% �Q�l LOAD, WHOS, DIARY, FWRITE, FPRINTF, UISAVE, FILEFORMATS.

%   Copyright 1984-2003 The MathWorks, Inc.

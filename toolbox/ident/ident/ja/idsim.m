% IDSIM  �^����ꂽ�_�C�i�~�b�N�V�X�e�����V�~�����[�V�������܂��B
% 
%   Y = IDSIM(UE,MODEL)
%
% MODEL: IDMODEL �t�H�[�}�b�g�AIDSS, IDPOLY, IDARX, GREYBOX �̂����ꂩ��
% �^����ꂽ���f���̃p�����[�^���܂݂܂��B
%
%   UE : ���� - �m�C�Y�f�[�^ UE = [U E]�B�����ŁAU �́A���̓f�[�^�ŁA
%        IDDATA �I�u�W�F�N�g(���͂Ƃ��Ē�`���ꂽ�M��������)�A�܂��́A�s
%        �� U = [U1, U2,....]�̂����ꂩ�ŗ^�����Ă��܂��B�����ŁAk ��
%        �ڂ̓��͂͗�x�N�g�� Uk �ł��B���l�ɁAE ��IDDATA �I�u�W�F�N�g�A
%        �܂��́A�m�C�Y���͂̍s��̂����ꂩ�ł�(�o�̓`�����l�����Ɨ񐔂�
%        ����)�BE ���ȗ�����Ă���ꍇ�A�m�C�Y�̂Ȃ��V�~�����[�V�������s
%        ���܂��B
%        �m�C�Y�̉e���́AMODEL �̒��Ɋ܂܂�镪�U���ŃX�P�[�����O����
%        �܂��B
%
%   Y  : �V�~�����[�V�������ꂽ�o�́BU �� IDDATA �I�u�W�F�N�g�̏ꍇ�AY 
%        �� IDDATA �I�u�W�F�N�g�Ƃ��ďo�͂���܂��B�s��̂悤�Ȃ��̑���
%        �ꍇ�Ak �Ԗڂ̗�́Ak �Ԗڂ̏o�̓`�����l���ɂȂ�܂��B
%
% UE �������̎����f�[�^����\������� IDDATA �I�u�W�F�N�g�̏ꍇ�AY ����
% �̂悤�ɂȂ�܂��B
%
% MODEL ���A���n�̏ꍇ�A���� U �̏��ɏ]���čŏ��ɃT���v�����O����A��
% ���āAIDDATA �I�u�W�F�N�g('Ts' �� 'InterSample' �v���p�e�B)�ɂȂ�܂��B
%
% [Y,YSD] = IDSIM(UE,MODEL) ���g���āA�V�~�����[�g���ꂽ�o�͂̐��肳���
% �W���΍� YSD ���v�Z����܂��BYSD �́AY �Ɠ����t�H�[�}�b�g�ł��B
%
% Y = IDSIM(UE,MODEL,INIT) �́A������ԂɃA�N�Z�X���܂��B
%       INIT = 'm' (�f�t�H���g) �́A���f���̏�����Ԃ��g���܂��B
%       INIT = 'z' �́A������Ԃ��[���ɂ��܂��B
%       INIT = X0 (��x�N�g��)�B������ԂƂ��āAX0 ���g���܂��B
%
% �V�~�����[�V�����ƃ��f���쐬�Ɋւ��ẮAIDINPUT, IDMODEL ���Q��
% ���f���̕]���Ɋւ��ẮACOMPARE �� PREDICT ���Q��

%   Copyright 1986-2001 The MathWorks, Inc.

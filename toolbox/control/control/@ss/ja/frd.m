% FRD   ���g�������f�[�^���f���ւ̕ϊ��܂��͍쐬
%
% ���g�������f�[�^(FRD)���f���́A���������f�[�^���܂�LTI�V�X�e���̎��g
% ���������X�g�A����̂ɗL���ł��B
%
% �쐬:
% SYS = FRD(RESPONSE,FREQS) �́AFREQS �̎��g���_�ł̉����f�[�^ RESPONSE 
% ������FRD���f�� SYS ���쐬���܂��B�o�͈��� SYS ��FRD���f���ł��B
% �ڍׂ͈ȉ��̢�f�[�^�t�H�[�}�b�g����Q�Ƃ��Ă��������B
%
% SYS = FRD(RESPONSE,FREQS,TS) �́A�T���v������ TS (�T���v�����Ԃ��w��
% ���Ȃ��ꍇ�́ATS = -1 �ɐݒ肵�Ă�������)�̗��U����FRD���f�����쐬
% ���܂��B
%
% SYS = FRD �́A���FRD���f�����쐬���܂��B
%
% ��L�̂��ׂĂ̏����ł́A���̓��X�g�ɑ����āA���̑g��ݒ�ł��܂��B
% 
%    'PropertyName1', PropertyValue1, ...
% 
% �����̑g�́AFRD���f���̗l�X�ȃv���p�e�B��ݒ肵�܂�(�ڍׂ́ALTIPROPS 
% �ƃ^�C�v���Ă�������)�B
% 
% ���� SYS = FRD(RESPONSE,FREQS,REFSYS) �́A��`�ς݂�LTI���f�� REFSYS 
% ���炷�ׂĂ�LTI�v���p�e�B���p������ SYS ���쐬���܂��B
%
% �f�[�^�t�H�[�}�b�g:
% SISO���f���ɑ΂��āAFREQS �͎����g���x�N�g���ŁARESPONSE �͉����f�[�^
% �x�N�g���ł��B�����ŁARESPONSE(i) �́AFREQS(i) �ł̃V�X�e���̉�����
% �\�����܂��B
%
% NU ���� NY �o�͂ŁA���g���_ NF �� MIMO FRD ���f���ɑ΂��āARESPONSE �́A
% NY*NU*NF �z��ŁARESPONSE(i,j,k) �́A���g�� FREQS(k) �ł̓��� j ����
% �o�� i �܂ł̎��g���������w�肵�܂��B
%
% �f�t�H���g�ł́AFREQS�̎��g���P�ʂ� 'rad/s' �ł��B'Units' �v���p�e�B��
% �ύX���邱�ƂŁA�P�ʂ� 'Hz' �ɕύX���邱�Ƃ��ł��܂��B���̃v���p�e�B��
% �ύX���Ă����g���̐��l���ύX����Ȃ����Ƃɒ��ӂ��Ă��������BCHGUNITS 
% (SYS,UNITS) ��p���āAFRD ���f���̎��g���P�ʂ�ύX����ƁA�K�v�ȕϊ���
% ���s����܂��B
%
% FRD���f���̔z��:
% ��L�� RESPONSE �ɑ΂��āAND�z��𗘗p���邱�ƂŁAFRD���f���̔z���
% �쐬���邱�Ƃ��ł��܂��B���Ƃ��΁ARESPONSE ���A[NY NU NF 3 4] �̃T�C�Y
% �̔z��̂Ƃ��A
% 
%    SYS = FRD(RESPONSE,FREQS) 
% 
% �́A3�s4���FRD���f���̔z����쐬���܂��B�����ŁASYS(:,:,k,m) = FRD
% (RESPONSE(:,:,:,k,m),FREQS),  k = 1:3,  m = 1:4�ł��B�e�X��FRD���f��
% �́ANU ���� NY �o�͂ŁAFREQS �̊e�X�̎��g���_�ł̃f�[�^�������܂��B
%
% �ϊ�:
% SYS = FRD(SYS,FREQS,'Units',UNITS) �́A�C�ӂ�LTI���f�� SYS ��FRD���f��
% �\���ɕϊ����AFREQS �̊e���g���ł̃V�X�e���̉������쐬���܂��BUNITS �́A
% FREQS �ł̎��g���P�ʂŁA'rad/s' �܂��� 'Hz' �ł��B�Ō��2�̈�����
% �ȗ����ꂽ�ꍇ�A�f�t�H���g�� 'rad/s' �ɂȂ�܂��B���ʂ́AFRD���f���ł��B
%
% �Q�l : LTIMODELS, SET, GET, FRDATA, CHGUNITS, LTIPROPS, TF, ZPK, SS.


%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 

% IDFRD �́AIdentified Frequency Response Data ���f���̍쐬�A�܂��́AID-
% FRD���f���ւ̕ϊ����s�Ȃ��܂��B
%
% Identified Frequency Response Data (IDFRD) ���f���́A�s�m�������܂ސ��`
% �V�X�e���̎��g���������i�[����ꍇ�ɗL���Ȃ��̂ł��BIDFRD �́A�����I��
% �����f�[�^��֐� SPA �� ETFE ���璼�ڐ���ł�����g���������i�[���邱��
% ���ł��܂��B
%
% ���ӁF
%    MF = IDFRD(RESPONSE,FREQS,TS) 
% 
% �́AFREQS �ŗ^��������g���_�ŁARESPONSE �̒��̉����f�[�^������ IDFRD
% ���f�� MF ���쐬���܂��BTS = 0 ���g���āA�A�����ԃV�X�e������̉�������
% �`���܂��B�ڍׂ́A"�f�[�^�t�H�[�}�b�g"���Q�Ƃ��Ă��������B
%
% �����̕s�m����(�����U)�Ɋւ�����𓾂�ɂ́A
% 
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE)
% 
% ���g���܂��B�����ŁACOVARIANCE �́A���Ɏ�����]����t�H�[�}�b�g�ŁARE-
% SPONSE �̋����U���܂�ł��܂��B
%
% �(�m�C�Y)�̃X�y�N�g���Ɋւ�������܂ނ��߁A�܂��́A���n��̃X�y�N
% �g�����i�[���邽�߁A�s�m�����Ɋւ���v���p�e�B'SpectrumData'��'Noise-
% Covariance'���g���܂��B
% 
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE,...
%               'SpectrumData',SPECTRUM,'NoiseCovariance',COVSPECT)
% 
% �f�[�^�t�H�[�}�b�g�ɂ��ẮA���̂��̂��Q�Ƃ��Ă��������B
%
% IDFRD ���f���́A�C�ӂ� IDMODEL �܂��́ALTI ���f�� MOD �����g�������f�[
% �^�ɕϊ����邱�Ƃɂ��쐬�ł��܂��B
%
%    MF = IDFRD(MOD)�A�܂��́A MF = IDFRD(MOD,FREQS)
%
% ���g��������o�̓m�C�Y�X�y�N�g���́A�����̋����U�Ɠ��l�ɁAMOD ����v
% �Z����AMF �Ɋi�[����܂��BMOD �̓��̔C�ӂ� InputDelay ���A�ʑ��x��ɕ�
% ������A���̏ꍇ�AMF �� InputDelay = zeros(nu,1) �ɂȂ�܂��B
%
% ��̂��ׂẴV���^�b�N�X�ɂ����āA���̓��X�g�́AIDFRD ���f���̎�X�̃v
% ���p�e�B��ݒ肷�邽�߂ɁA
% 
%       'PropertyName1', PropertyValue1, ...
% 
% �̂悤�Ƀy�A�Őݒ肵�܂�(�ڍׂ́AIDPROPS IDFRD �Ɠ��͂��Ă�������)�B
%
% �f�[�^�t�H�[�}�b�g�F
% SISO ���f���ɑ΂��āAFREQS �́A�������g���x�N�g���ŁARESPONSE �́A����
% �f�[�^�x�N�g���ŁA�����ŁARESPONSE(i) �́AFREQS(i) �ŃV�X�e��������\��
% ���܂��B
%
% NY �o�́ANU ���͂������A���g���_ NF ������MIMO IDFRD ���f���ɑ΂��āA
% RESPONSE �́ANY-NU-NF �z��ɂȂ�܂��B�����ŁARESPONSE(i,j,k) �́A���� 
% j ����o�� i �ւ̎��g�� FREQS(k) �ł̎��g��������ݒ肵�܂��B
%
% COVARIANCE �́A5D �z��ŁACOVARIANCE(KY,KU,k,:,:))�́ARESPONSE(KY,KU,k)
% ��2�s2��̋����U�s��ł��B(1,1)�v�f�́A�������̕��U�A(2,2)�v�f��������
% �̕��U�A(1,2)��(2,1)�v�f�́A�����Ƌ������Ԃ̋����U�ł��BSQUEEZE(COVAR-
% IANCE(KY,KU,k,:,:)) �́A�Ή����鉞���̋����U�s���^���܂��B
%
% SPECTRUM �́ANY-NY-NF �z��ŁASPECTRUM(ky1,ky2,k) �́A���g�� FREQS(k) 
% �ŁA�o��ky1 �Əo�� ky2 �ł̏�Ԃ̃N���X�X�y�N�g���ł��B
%
% COVSPECT �́ASOECTRUM �Ɠ��������̔z��ł��B�����ŁACOVSPECT(ky1,ky2,k)
% �́ASPECTRUM(k1,k2,k) �̕��U�ɂȂ�܂��B
%
% �f�t�H���g�ŁAFREQS �̒��̎��g���̒P�ʂ́A'rad/sec'�ł��B�܂��A'Units' 
% �v���p�e�B���g���āA'Hz' �ɕύX���邱�Ƃ��ł��܂��B���̃v���p�e�B�l���
% �X���邱�Ƃ́A���l�I�Ȏ��g���l��ύX���邱�Ƃł͂Ȃ����Ƃ𒍈ӂ��Ă���
% �����BCHGUNITS(SYS,UNITS) ���g���āAFRD ���f���̎��g���P�ʂ�ύX���A�K
% �v�Ȃ�ϊ������܂��B
% 



%   Copyright 1986-2001 The MathWorks, Inc.

% PMUSIC   MUSIC �ŗL�x�N�g���@���g���āA���g���̐���
% S = PMUSIC(X,P)�́A���U���ԐM���x�N�g�� X �̋[���X�y�N�g�����x�N�g�� S
% �ɏo�͂��܂��BP �́A�M�� X �̒��̕��f�����g�̐��ł��BX ���f�[�^�s���
% �ꍇ�A�e�s�͕ʁX�̃Z���T�[�܂��͎�������̑���l�Ɖ��߂���܂��B���[�U
% �́A�����Ŏg�p����f�[�^�s����A�֐� CORRMTX ���g���č쐬�ł��܂��B
%
% S = PMUSIC(R,P,'corr') �́A����s�� R �ŗ^����ꂽ���U���ԐM���̑��֍s
% ��̋[���X�y�N�g�����o�͂��܂��B
%
% P ��2�v�f�x�N�g���̏ꍇ�AP(2) �́A�M����Ԃƃm�C�Y��Ԃ𕪗�����J�b�g
% �I�t�Ƃ��Ďg���܂��BP(2)�ƍŏ��̌ŗL�l�̐ς��傫���ŗL�l���M���̌�
% �L�l�ƍl�����܂��B���̏ꍇ�A�M���̕�����Ԃ̎����́A�ق� P(1) �ɂȂ�
% �܂��B
%
% �����M���ɑ΂��āAPMUSIC �́A�f�t�H���g�ł́A�����̋[���X�y�N�g�����o
% �͂��܂��B���f���M���ɑ΂��āA�S�̂̋[���X�y�N�g�����o�͂��܂��B�����M
% ���ɑ΂��āA�S�̂̋[���X�y�N�g�����o�͂������ꍇ�APMUSIC(X,P,'whole')
% �Ƃ��Ă��������B'whole'��'corr'�̕�����́AP�̌�̔C�ӂ̈ʒu�ɐݒ肷��
% ���Ƃ��ł��܂��B
%
% S = PMUSIC(X,P,NFFT) �́A�[���X�y�N�g�����v�Z���邽�߂Ɏg�p���� FFT ��
% ������ݒ肵�܂��B�����ɑ΂��āANFFT �������̏ꍇ�A(NFFT/2+1)�ŁA�
% �̏ꍇ�A(NFFT+1)/2 �ł��B���f���ł́AS �́A��������� NFFT �ɂȂ�܂��B
% ��̏ꍇ�A�f�t�H���g�́A256 �ł��B
%
% [S,W] = PMUSIC(...) �́A�[���X�y�N�g�����v�Z���鐳�K�����ꂽ�p���g�� W
% ��ݒ肷��x�N�g�����o�͂��܂��BW �̒P�ʂ́Arad/�T���v���ł��B�����M��
% �ɑ΂��āAW �́ANFFT �������̏ꍇ[0,pi]�̋�ԂɍL����ANFFT ����̏�
% ��[0,pi)�͈̔͂ɂȂ�܂��B���f���M���̏ꍇ�AW �́A��ɁA[0.2*pi)�̋��
% �ł��B
%
% [S,F] = PMUSIC(...,Fs) �́A�T���v�����O���g���� Hz �P�ʂŐݒ肵�AHz ��
% �Ƀp���[�X�y�N�g�����x���o�͂��܂��BF �́AHz �P�ʂ̎��g���x�N�g���ŁA
% �����Őݒ肳��Ă�����g���ŁA�[���X�y�N�g�����v�Z���܂��B�����M���ɑ�
% ���āAF�́ANFFT �������̏ꍇ[0,Fs/2]�ŁA��̏ꍇ[0,Fs/2)�͈̔͂ɍL��
% ��܂��B���f���M���ɑ΂��āAF�́A��ɁA[0,Fs)�͈̔͂ł��BFs����ɂ���
% �ƁA�f�t�H���g�̃T���v�����O���g��1 Hz ���g���܂��B
% 
% [S,F] = PMUSIC(...,NW,NOVERLAP)  �́A�M���x�N�g�� X �𒷂� NW �ŁA�I�[
% �o���b�vNOVERLAP �T���v���̕����ɕ������܂��B�����̕����́A�s��̍s
% �Ƃ��čl���A���̓]�u�������̂Ƃ̏�Z�ŁAX �� NW �s NW ��̑��֍s�����
% �����܂��BNW ���x�N�g���̏ꍇ�A�f�[�^�s��̍s�́ANW �̒����̃E�C���h�E
% ��K�p���܂��B��܂��͏ȗ�����Ă���ꍇ�ANW = 2*P �� NOVERLAP = NW-1
% ��ݒ肵�܂��B
%
% [S,W,V,E] = PMUSIC(...) �́A�s��̗񂪃m�C�Y������ԂɑΉ�����ŗL�x�N
% �g���ł���s�� V �Ƃ��ׂĂ̌ŗL�l���܂ރx�N�g�� E ���o�͂��܂��B���̃V
% ���^�b�N�X�́A�����g�̎��g���ƃp���[�����肷��̂ɗL���Ȃ��̂ł��B
%
% �o�͈�����ݒ肵�Ȃ� PMUSIC(...) �́A�J�����g�� Figure �E�C���h�E�ɋ[
% ���X�y�N�g�����v���b�g���܂��B
%
% ���F
%      randn('state',1); n=0:99;   
%      s=exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      X=corrmtx(s,12,'mod');   % �C�������U�@���g���āA���֍s��𐄒�
%      pmusic(X,3,'whole');     % NFFT �́A�f�t�H���g�l256���g���܂��B
%
%      n=0:99; figure;
%      s2=sin(pi/3*n)+2*sin(pi/4*n)+randn(1,100);
%      X2=corrmtx(s2,20,'cov'); % �����U�@���g���āA���֍s��𐄒�      
%      pmusic(X2,4,'whole');    % ���������g�ɑ΂��āA�M����Ԃ̎�����
%                               % 2�{�̂��̂��g���܂�
% 
% �Q�l�F   ROOTMUSIC, PEIG, PMTM, PCOV, PMCOV, PBURG, PYULEAR, PWELCH,
%          CORRMTX, PSDPLOT.



%   Copyright 1988-2002 The MathWorks, Inc.

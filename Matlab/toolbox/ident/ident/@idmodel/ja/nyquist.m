% NYQUIST �́A���g���֐��� Nyquist ���}���v���b�g���܂��B
%   NYQUIST(M)  
%   NYQUIST(M,'SD',SD) 
%   NYQUIST(M,W) 
%   NYQUIST(M,'SD',SD,W)
%
% �����ŁAM �́AIDPOLY, IDSS, IDARX, IDGREY �Ɠ��l�ɁA���胋�[�`��(ETFE 
% �� SPA ���܂�)�œ�����AIDMODEL �I�u�W�F�N�g�A�܂��́AIDFRD �I�u�W�F
% �N�g�̂ǂ��炩�ł��BM �����n�񃂃f���̏ꍇ�A�v���b�g�͏o�͂���܂���B
%
% �M�����: NYQUIST(M,'SD',SD)
% SD ���[�����傫�������̏ꍇ�ASD �W���΍��ɑΉ�����M����Ԃ��A�v�Z��
% �Ă�����g���_10�_����*�Ń}�[�N����܂��B�M����Ԃ����ʓI�Ƀv���b�g��
% �邽�߂ɁA'SD' �̑���� 'SDmN' ���g�p���Ă��������B�����ŁAN �͎��g��
% N �_���ƂɐM����Ԃ��\������邱�Ƃ��Ӗ����A'm' �͊e�X�̓_�̃}�[�J���w
% �肵�܂��B�Ⴆ�΁A'SD+25' �̂悤�Ɏw�肵�܂��B
%
% ���g���̎w��: NYQUIST(M,W)
% W �́AIDMODELs �Ŏg�p������g���ł��BW ���x�N�g���̏ꍇ�A���g���֐��́A
% W �̒l�ɑ΂��ăv���b�g����܂��BW ={WMIN,WMAX} �̏ꍇ�AWMIN �� WMAX ��
% �Ԃ̎��g����Ԃ����`���g���O���b�h�ŃJ�o�[����܂�(����: �����ʂň͂�
% �܂�)�BW = {WMIN,WMAX,NP}�́ANP �_�Ōv�Z����܂��B
%
% �����̃��f��:
% NYQUIST(M1,M2,...,Mn) ���g���āA�������̃��f���̎��g���֐����v���b�g
% ���܂��BNYQUIST(M1,'r',M2,'y--',M3,'gx')���g���āA�J���[�A���C���A�}�[
% �N��ݒ肷�邱�Ƃ��ł��܂��B�ڍׂ́AHELP PLOT ���Q�Ƃ��Ă��������B
% 
% MIMO���f��:
% �f�t�H���g���[�h�́A���f�� Mi �ŕ\�������e���͂Əo�͂̂��ׂĂ̑g�ɑ�
% ���� Nyquist ���}�𓯎��ɃV�~�����[�V�������A�v���b�g������̂ł��B���f
% ����InputName��OutputName���A�\�[�g�̂��߂ɗ��p����܂��B�����̑g������
% ����ꍇ�AENTER ���g���āA���̐}�̕\�����s�����Ƃ��ł��܂��B�\���̓r
% ���ŋ����I�����邽�߂ɂ́ACTRL-C ���^�C�v���܂��B�����}��ɂ��ׂẴv��
% �b�g�𓾂�ɂ́ANYQPLOT(M,SD,'same') ���g���܂��B
% 
% ��\���A���g���֐��̌v�Z:
% NYQUIST ���A�P��V�X�e���Ƌ��ɃR�[������A�o�͈������ݒ肳��Ă���ꍇ�A
%  
%   H = NYQUIST(M,W)�A�܂��́A[H,W,COVH] = NYQUIST(M)
% 
% �v���b�g�́A�X�N���[����ɕ`����܂���B 
% M �� NY �o�́ANU ���͂������AW ��NW �̎��g�������ꍇ�AH �́AH(ky,ku
% ,k) ���A���� ku ����o�� ky �ł̎��g�� W(k) �̕��f�����g��������^���� 
% NY-NU-NW �z��ɂȂ�܂��BSISO ���f���ɑ΂��āA���g�������̃x�N�g����
% �邽�߂ɂ́AH(:)�����s���܂��B
% �s�m������� COVH �́A5D �z��ŁACOVH(KY,KU,k,:,:)�́A���� KU ����o�� 
% KY �܂ł̎��g�� W(k)�ł�2�s2��̋����U�s��ł��B(1,1)�v�f�́A�������̕�
% �U�A(2,2)�v�f���������̕��U�A(1,2)��(2,1)�v�f�́A�����Ƌ������Ԃ̋����U
% �ł��BSQUEEZE(covH(KY,KU,k,:,:)) �́A�Ή����鉞���̋����U�s���^���܂��B
%
% M �����n��̏ꍇ�AH �́A�o�͂̃X�y�N�g���Ƃ��ďo�͂���܂��B���Ȃ킿�A
% NY-NY-NW �z��ɂȂ�܂��BH(:,:,k) �́A���g�� W(k) �ł̃X�y�N�g���s���
% ���B�v�f H(K1,K2,k) �́A���g�� W(k) �ł̏o�� K1 �� K2 �Ƃ̃N���X�X�y�N
% �g���ł��BK1 = K2 �̏ꍇ�A����́A�o��K1 �̎����l�p���[�X�y�N�g���ɂȂ�
% �܂��BCOVH �́A�X�y�N�g�� H �̋����U�ɂȂ�A����ŁACOVH(K1,K1,k) �́A
% ���g�� W(k) �ł̃p���[�X�y�N�g���o�� K1 �̕��U�ɂȂ�܂��B�N���X�X�y�N
% �g���̕��U�Ɋւ�����́A�ʏ�A�^�����܂���(K1 �� K2 �ɓ������Ȃ���
% ���ACOVH(K1,K2,k) = 0 �ɂȂ�܂�)�B
% 
% ���f�� M �����n��łȂ��ꍇ�A�m�C�Y(�o�͏)�M���̃X�y�N�g�����𓾂�
% �ɂ́A NYQUIST(M('n')) ���g���܂��B
%
% �Q�l�F IDMODEL/BODE, FFPLOT



%   Copyright 1986-2001 The MathWorks, Inc.

% IDMODEL/ZPKDATA �́A��_ - �� - �Q�C���f�[�^�ւ̃N�C�b�N�A�N�Z�X���s��
% �܂��B
% 
% [Z,P,K] = ZPKDATA(MODEL) �́AIDMODEL ���f�� MODEL �̊e I/O �`�����l��
% �̗�_�A�ɁA�Q�C�����o�͂��܂��B�Z���z�� Z,P �ƍs�� K �́A�o�͂Ɠ����s
% ���������A���͂Ɠ����񐔂������A����(I,J)�v�f�́A���� J ����o�� I ��
% �ł̓`�B�֐��̗�_�A�ɁA�Q�C���ƂȂ�܂��B
%
% poles_IJ = P{I,J} ���g���āA���� J ����o�� I �܂ł̋ɂ�ǂݍ��݂܂��B
% 
% K �́A������ł̃Q�C���ł��B 
% 
%    G(z) = K*(z-z1)(z-z2)...(z-zn)/[(z-p1)(z-p2)...(z-pn)]
%
% MODEL �̑��̃v���p�e�B�́AGET ���g�����A�܂��́A���ړI�ɍ\���̂̎Q�Ɩ@
% (���Ƃ��΁AMODEL.Ts)���g���ăA�N�Z�X���܂��B
%
% SISO ���f�� MODEL �ɑ΂��āA�V���^�b�N�X
% 
%       [Z,P,K] = ZPKDATA(MODEL,'v')
% 
% �́A��_ Z �Ƌ� P ���Z���z��łȂ���x�N�g���Ƃ��ďo�͂��܂��B
%
% [Z,P,K,dZ,dP,dK] = ZPKDATA(MODEL) �́A��_�A�ɁA�Q�C���̐��肵�����U��
% �̃A�N�Z�X��^���܂��BdZ{ky,ku}(:,:,k) �́A��_ z{ky,ku}(k) �̋����U�s
% ��ŁA(1,1)�v�f�́A�������̕��U�A(2,2)�v�f���������̕��U�A(1,2)��(2,1)
% �v�f�́A�����Ƌ������Ԃ̋����U�ł��B���l�̂��Ƃ��AdP �Ɋւ��Ă��]����
% ���B
%
% [Z,P,K] = ZPKDATA(MODEL(ky,ku)) �́A�w�肵���o�͂Ɠ��̓`�����l���Ɋ֘A
% �����ɂ�^���܂��B
%
% MODEL �����n�񃂃f����(���͂��Ȃ�)�ꍇ�A�ɁA�남��� y = H e �Ƃ���
% ���K������Ȃ��\���ł���`�B�֐� H �̃Q�C�����Ԃ���܂��B���K�����ꂽ
% �\���𓾂�ɂ́A�ŏ��� MODEL = NOISECNV(MODEL,'n') ��K�p���܂��B
%
% [Z,P,K] = ZPKDATA(MODEL('Noise')) �́A�m�C�Y���Ɋ֘A������_�Ƌɂ�^��
% �܂�(����́Ay = Gu+He �̒��̓`�B�֐��s�� H �̗�_�Ƌɂł�)�B



%   L. Ljung 10-1-86, revised 7-3-87,1-16-94.
%   Copyright 1986-2001 The MathWorks, Inc.

% DE2BI 10�i�����o�C�i���x�N�g���ɕϊ�
% 
% B = DE2BI(D) �́A���łȂ�����10�i���x�N�g�� D ���o�C�i���s�� B �ɕϊ�
% ���܂��B�o�C�i���s�� B �̊e�s�́AD �̈�v�f�ɑΉ����܂��B�o�C�i���o��
% �̃f�t�H���g�̕����́A�E�[�� MSB �ł��B���Ȃ킿�AB �̒��̍ŏ��̗v�f�́A
% �ŉ��ʃr�b�g��\���܂��B
% 
% �x�N�g�����͂ɉ����āA3�̃I�v�V�����p�����[�^��^���邱�Ƃ��ł��܂��B
%
% B = DE2BI(...,N) �́AN ���g���āA�o�͂��錅(��)����ݒ肵�܂��B
%
% B = DE2BI(...,N,P) �́AP ���g���āA10�i���v�f��ϊ��������ݒ肵�܂��B
%
% B = DE2BI(...,FLAG) �́AFLAG ���g���āA�o�͂̕��������肵�܂��BFLAG 
% �́A2�̒l�A'right-msb'��'left-msb' ���g�p���邱�Ƃ��ł��܂��B
% 'right-msb' Flag �̏ꍇ�A�֐��̃f�t�H���g�����͕ύX����܂���B
% 'left-mbs' FLAG �̏ꍇ�A�o�͂̕����𔽑΂ɂ��āAMSB �����[�ɂ��ĕ\��
% ���܂��B
%
%    ���:
%    >> D = [12; 5];
%
%    >> B = de2bi(D)                 >> B = de2bi(D,5)
%    B =                             B =
%         0     0     1     1             0     0     1     1     0
%         1     0     1     0             1     0     1     0     0
%
%    >> T = de2bi(D,[],3)            >> B = de2bi(D,5,'left-msb')
%    T =                             B = 
%         0     1     1                   0     1     1     0     0
%         2     1     0                   0     0     1     0     1
%
% �Q�l�F BI2DE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:34:21 $

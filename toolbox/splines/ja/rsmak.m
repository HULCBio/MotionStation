% RSMAK   rB-�^�̗L���X�v���C���̑g����
%
% RSMAK(KNOTS,COEFS) �́A���͂ɂ���Ďw�肳�ꂽ�L���X�v���C����
% rB-�^���o�͂��܂��B
%
% �L���X�v���C����B-�^�ƂƂ��ĕW������邱�ƁA���Ȃ킿�A���ꂪ�X�v���C��
% �̍ŏI�v�f�ɂ���ė^�����A���q���c��v�f�ŋL�q�����悤�ȗL���X�v
% ���C���ł��邱�Ƃ������āA����͌����� SPMAK(KNOTS,COEFS) �̏o�͂ł��B
% ���l�ɁA���̃^�[�Q�b�g�̎����́ASPMAK(KNOTS,COEFS) �̏o�͂ɑ΂��Ă�
% ���������������Ȃ�܂��B
%
% ���ɁA���͂̌W���́A�����炩�� d>0 �ɑ΂���(d+1)�v�f�̃x�N�g���l��
% �Ȃ���΂Ȃ炸�AN�����̒l�����������̂ɂ͂Ȃ�܂���B
%
% �Ⴆ�΁Aspmak([-5 -5 -5 5 5 5],[26 -24 26]) �́A��� [-5 .. 5] ��
% ������ t |-> t^2+1 ��B-�^��^�������Aspmak([-5 -5 -5 5 5 5], [1 1 1]) 
% �́A�萔�֐�1��B-�^��^���܂��B�܂��A�R�}���h
%
%      runge = rsmak([-5 -5 -5 5 5 5],[1 1 1; 26 -24 26]);
%
% �́A���Ԋu�̃T�C�g�ł̑�������ԂɊւ���Runge�̗��ŗL���ȗL���֐�
% t |-> 1/(t^2+1) �ɑ΂����� [-5 .. 5] �ł�rB-�^��^���܂��B
%
% RSMAK(KNOTS,COEFS,SIZEC) �́ACOEFS ����ɑ����v�f��1�̎��������Ƃ���
% �g�p����܂��B���̏ꍇ�ASIZEC �� COEFS �̈Ӑ}�����傫����^����x�N
% �g���łȂ���΂Ȃ�܂���B���� SIZEC(1) �́A���ۂ� COEFS �̍ŏ��̎�����
% �Ȃ���΂Ȃ�܂���B�]���āASIZEC(1)-1 �́A�^�[�Q�b�g�̎����ł��B
%   
% rB-�^�́Ac(:,i) �� NURBS �̑Ή����鐧��_�ł���A�܂��Aw(i) �����̑Ή�
% ����d�݂ł���Ƃ��ɁArB-�^�̕W���I�ȌW���� [w(i)*c(:,i);w(i)] �̌`��
% ���Ƃ����Ӗ��ɂ����āANURBS �̃o�[�W�����Ɠ����ł��B
%
% RSMAK(OBJECT,varargin) �́A������ OBJECT �Ŏw�肳�ꂽ����̊􉽊w�I��
% �`����o�͂��܂��B�Ⴆ�΁A
%
% rsmak('circle',radius,center) �́A�^����ꂽ���a(�f�t�H���g1)�ƒ��S
% (�f�t�H���g (0,0))�����~���L�q����2���̗L���X�v���C����^���܂��B
%
% rsmak('cone',radius,height) �́A��[�� (0,0,0) ��z-���W��ɒ���������
% �^����ꂽ���a(�f�t�H���g1)�Ɣ����̍���(�f�t�H���g1)�̑Ώ̂ȉ~����
% �L�q����2���̗L���X�v���C����^���܂��B
%
% rsmak('cylinder',radius,height) �́Az-���W��ɒ��������^����ꂽ���a
% (�f�t�H���g1)�ƍ���(�f�t�H���g1)�̉~�����L�q����2���̗L���X�v���C����
% �^���܂��B
%
% rsmak('southcap',radius,center) �́A�^����ꂽ���a(�f�t�H���g1)�ƒ��S
% (�f�t�H���g (0,0,0))�������̓쑤��6����1��^���܂��B
%
% transf �ɂ���Ďw�肳�ꂽ�A�t�B��(affine)�ϊ��̌��ʂƂ��Đ������􉽊w�I
% �ȃI�u�W�F�N�g�����o���ɂ́Afncmb(rs,transf) ���g�p���Ă��������B
% �Ⴆ�΁A�ȉ��� 'southcap' ���g�ƁA���̉�]�̂�����2����т��̋��f��
% ����ė^������悤�ȋ���2/3�̃v���b�g�𐶐����܂��B
%
%      southcap = rsmak('southcap');
%      xpcap = fncmb(southcap,[0 0 -1;0 1 0;1 0 0]);
%      ypcap = fncmb(xpcap,[0 -1 0; 1 0 0; 0 0 1]);
%      northcap = fncmb(southcap,-1);
%      fnplt(southcap), hold on, fnplt(xpcap), fnplt(ypcap), fnplt(northcap)
%      axis equal, shading interp, view(-115,10), axis off, hold off
%
% �Q�l : RSBRK, RPMAK, PPMAK, SPMAK, FNBRK.


%   Copyright 1999-2003 C. de Boor and The MathWorks, Inc.

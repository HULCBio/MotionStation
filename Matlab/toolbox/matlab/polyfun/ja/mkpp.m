%MKPP �敪���������쐬
% PP = MKPP(BREAKS,COEFS) �́A�ߓ_�ƌW������敪������ PP ���쐬���܂��B
% BREAKS �́A��� L �̏o���_�ƏI���_��\�킷�v�f���܂ޒ��� L+1 �̃x�N�g��
% �ł��B�s�� COEFS �́AL�~K �łȂ���΂Ȃ�܂���B��i�s�ACOEFS(i,:) ���A
% ��� [BREAKS(i) ... BREAKS(i+1)] �ł� K ���������̃��[�J���ȌW����\�킷�A
% ���Ȃ킿�A������                 
%   COEFS(i,1)*(X-BREAKS(i))^(K-1) + COEFS(i,2)*(X-BREAKS(i))^(K-2) + ... 
%   COEFS(i,K-1)*(X-BREAKS(i)) + COEFS(i,K) �ł��B
% ����: K ���̑������́A ���̂悤�� K �̌W�����g�p���ċL�q���܂��B
%      C(1)*X^(K-1) + C(2)*X^(K-2) + ... + C(K-1)*X + C(K)
% �]���āA������ K ��菬�����Ȃ�܂��B���Ƃ��΁A�L���[�r�b�N�������́A�ʏ�A
% 4 �v�f�����x�N�g���Ƃ��Ă�����܂��B
%
% PP = MKPP(BREAKS,COEFS,D) �́A�敪������ PP ��D-�x�N�g���l�ł��邱�Ƃ�
% �Ӗ����Ă��܂��BD �́A�X�J���[�܂��͐����x�N�g���̂����ꂩ�ł��BBREAKS �́A
% ���� L+1 �̃x�N�g���ŁA�v�f�l�́A�����������܂��BCOEFS �̃T�C�Y������
% �����Ă��A���̍Ō�̎����́A�������̎��� K �ɂƂ��܂��B���̂��߁A�c���
% �����̐ς́Aprod(D)*L �ɂȂ�K�v������܂��B
% COEFS ���T�C�Y [prod(D),L,K] �Ƃ���ƁACOEFS(r,i,:) �́Ai�Ԗڂ̋敪��
% �������� r �Ԗڂ̗v�f�� K �W���ł��B�����I�ɂ́ACOEFS �́A�T�C�Y 
% [prod(D)*L,K] �̍s��Ƃ��ĕۑ�����܂��B
%
% ���:
% ���̍ŏ���2�̃v���b�g�́A�񎟎� 1-(x/2-1)^2 = -x^2/4 + x ��
% ��� [-2 .. 2] ������ [-8 .. -4] �ɃV�t�g���A���̑������̕��A
% ���Ȃ킿�A�񎟎� (x/2-1)^2-1 = x^2/4 - x �́A[-2 .. 2] ������ 
% [-4 .. 0] �փV�t�g���܂��B
%      subplot(2,2,1)
%      cc = [-1/4 1 0];
%      pp1 = mkpp([-8 -4],cc); xx1 = -8:0.1:-4;
%      plot(xx1,ppval(pp1,xx1),'k-')
%      subplot(2,2,2)
%      pp2 = mkpp([-4 -0],-cc); xx2 = -4:0.1:0;
%      plot(xx2,ppval(pp2,xx2),'k-')
%      subplot(2,1,2)
%      pp = mkpp([-8 -4 0 4 8],[cc; -cc; cc; -cc]);
%      xx = -8:0.1:8;
%      plot(xx,ppval(pp,xx),'k-')
%      [breaks,coefs,l,k,d] = unmkpp(pp);
%      dpp = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
%      hold on, plot(xx,ppval(dpp,xx),'r-'), hold off
% �Ō�̃v���b�g�́A4��Ԃɓn���āA�ŏ���2�̓񎟎���ύX�����č쐬����
% �敪���������v���b�g���܂��B�敪�������̓������������邽�߂ɁAUNMKPP ��
% ��蓾��ꂽ�敪�������ɂ��Ă̏�񂩂�\�������悤�ɁA1�K���֐���
% ������Ă��܂��B
%
% ���� BREAKS,COEFS �̃T�|�[�g�N���X
%      float: double, single
%
% �Q�l UNMKPP, PPVAL, SPLINE.

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.

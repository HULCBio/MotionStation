%SPLINE �L���[�r�b�N�X�v���C���f�[�^���
% PP = SPLINE(X,Y) �́A�f�[�^�ʒu X �ŁA�f�[�^�l Y �ɑ΂��āA�L���[�r�b�N
% �X�v���C����Ԃ̋敪�������`��^���܂��B����́APPVAL ��
% �X�v���C�����[�e�B���e�B UNMKPP �Ŏg�����Ƃ��ł��܂��B
% X �̓x�N�g���łȂ���΂Ȃ�܂���B
% Y ���x�N�g���̏ꍇ�AY(j) �́AX(j) �ň�v����l�ɂƂ��܂��B�]���āA
% Y �́AX �Ɠ��������ł���K�v������܂� -- ��O�ɂ��ẮA���L���Q�Ƃ���
% ���������B
% Y ���s��܂��� ND �z��̏ꍇ�AY(:,...,:,j) �́AX(j) �ň�v����l��
% �Ƃ��܂��B�]���āAY �̍Ō�̎����́Alength(X) �ɓ������Ȃ�܂� --
% ���̗�O�ɂ��ẮA���L���Q�Ƃ��Ă��������B
%
% YY = SPLINE(X,Y,XX) �́AXX �ł̕�Ԃ̒l�� YY �ɗ^���A 
% YY = PPVAL(SPLINE(X,Y),XX) �Ɠ����ł��B
% YY �̃T�C�Y�ɂ��Ă̏ڍׂ́APPVAL ���Q�Ƃ��Ă��������B
%
% �ʏ�A�ߓ_�Ȃ��̒[�_�������g���܂��B�������AY �� X �̗v�f����2��
% �ȏ㑽���c���̃f�[�^�����ꍇ�́AY���̍ŏ��ƍŌ�̍��W�́A�L���[�r�b�N
% �X�v���C���̒[�_�ł̌��z�Ƃ��Ďg���܂��BY ���x�N�g���̏ꍇ�A����́A
% ���̂��Ƃ��Ӗ����܂��B
%       f(X) = Y(2:end-1),  Df(min(X))=Y(1),    Df(max(X))=Y(end).
% Y ���ALENGTH(X)+2 �ɓ������ASIZE(Y,N) �̍s��܂���N-D �z��̏ꍇ�A
% f(X(j)) �́Aj=1:LENGTH(X) �ɑ΂��Ēl Y(:,...,:,j+1) �Ɉ�v���A
% Df(min(X)) �́AY(:,:,...:,1) �ɁADf(max(X)) �́AY(:,:,...:,end) ��
% ��v���܂��B
%
% ���:
% ����́A�����g�̃X�v���C���Ȑ����쐬���A���ȊԊu�ŃT���v�����O�����
% �ł��B
%       x = 0:10;  y = sin(x);
%       xx = 0:.25:10;
%       yy = spline(x,y,xx);
%       plot(x,y,'o',xx,yy)
%
% ���:
% �ȉ��́A�Ō�̌��z���L�q����Ă���A�N�����v���ꂽ�A���邢�͊��S�ȃX�v
% ���C����Ԃ̗��p�������܂��B���̗�ł́A���镪�z�̒l�ւ̓��}�̒[�̓_��
% �̌��z���[���ɂȂ�Ƃ������񂪂���܂��B
%      x = -4:4; y = [0 .15 1.12 2.36 2.36 1.46 .49 .06 0];
%      cs = spline(x,[0 y 0]);
%      xx = linspace(-4,4,101);
%      plot(x,y,'o',xx,ppval(cs,xx),'-');
%
% ���� x, y, xx �̃T�|�[�g�N���X
%   float: double, single
%
% �Q�l INTERP1, PPVAL, UNMKPP, MKPP, SPLINES (The Spline Toolbox).

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.

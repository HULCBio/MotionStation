% VIEWMTX   ���_�ϊ��s��
% 
% A = VIEWMTX(AZ,EL) �́A3�����x�N�g����2�����v���b�g�T�[�t�F�X�ɓ��e
% ���邽�߂ɗp����A4�s4��̐��ˉe�ϊ��s�� A ���o�͂��܂��B���ʊp��
% �p�ɂ��ẮAVIEW �Ɠ�����`���g�p���Ă��������B���ɁAAZ �� EL ��
% �P�ʂ͊p�x�łȂ���΂Ȃ�܂���B���̃R�}���h
% 
%         VIEW(AZ,EL)
%         A = VIEW
% 
% �͓����ϊ��s����o�͂��܂����A�J�����g��VIEW�͕ύX���܂���B
%
% A = VIEWMTX(AZ,EL,PHI) �́A3�����̃x�N�g����2�����̃v���b�g�T�[�t�F�X
% �ɓ��e���邽�߂ɗp����4�s4��̓����ϊ��s����o�͂��܂��BPHI �́A��
% �K�����ꂽ�v���b�g�����̂̓����@�̎��_���p�x�ŕ\�킵�����̂ŁA������
% �c�݂̗ʂ𐧌䂵�܂��B
% 
%         PHI =  0 �x�́A���ˉe�ł��B
%         PHI = 10 �x�́A�]�������Y�Ɏ��Ă��܂��B
%         PHI = 25 �x�́A�W�������Y�Ɏ��Ă��܂��B
%         PHI = 60 �x�́A�L�p�����Y�Ɏ��Ă��܂��B
% 
% �s�� A �́AVIEW(A) ���g���Ď��_�̕ϊ���ݒ肷�邽�߂Ɏg�p�ł��܂��B
%
% A = VIEWMTX(AZ,EL,PHI,XC) �́A���K�����ꂽ�v���b�g�����̓��̃^�[�Q�b�g
% �_(�܂��́A���Ă���_)�Ƃ��� XC ���g���āA�����ϊ��s����o�͂��܂��B
% XC =[xc,yc,zc] �́A�v���b�g�����̓��̓_ (xc,yc,zc) ���w�肵�܂��B
% �f�t�H���g�l�́A�v���b�g�����̓��̍ł��߂��_�ł��B
%
%   XC = 0.5+sqrt(3)/2*[cos(EL)*sin(AZ),-cos(EL)*cos(AZ),sin(EL)].
%
% �Q�l�FVIEW.


%   Clay M. Thompson 5-1-91
%   Revised 12-17-91, 3-10-92 by CMT
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:21 $

% WK1READ   �X�v���b�h�V�[�g(WK1)�t�@�C���̓ǂݍ���
% 
% A = WK1READ('FILENAME' ) �́ALotus WK1�X�v���b�h�V�[�g�t�@�C�� 
% FILENAME �̂��ׂẴf�[�^���s�� A �ɓǂݍ��݂܂��B�e�L�X�g�Ɋ܂܂��
% �Z���́A�[���ɐݒ肳��܂��B�Z������ NaN �̃e�L�X�g�́ANaN �̃^�C�v
% �Ƃ��ďo�͂���܂��B
%
% A = WK1READ('FILENAME',R,C) �́ALotus WK1�X�v���b�h�V�[�g�̍s R �Ɨ� C 
% ����n�܂�f�[�^���s�� A �ɓǂݍ��݂܂��BR �� C �́A�[������Ƃ��Ă����
% �ŁAR = C = 0�́A�X�v���b�h�V�[�g�̍ŏ��̃Z���ł��B
%
% A = WK1READ('FILENAME',R,C,RNG) �́A�X�v���b�h�V�[�g����f�[�^��I��
% ���邽�߂ɁA�Z���̗̈�܂��͗̈於���w�肵�܂��B�Z���̗̈�́A
% RNG = [R1 C1 R2 C2] �Ŏw�肳��܂��B�����ŁA(R1,C1) �͓ǂݍ��ރf�[�^
% �̍�����ŁA(R2,C2) �͉E�����ł��BRNG �́ARNG = 'A1..B7' �̂悤��
% �X�v���b�h�V�[�g�̕\�L�@��A'Sales' �̂悤�ȗ̈於���g���Ďw�肷��
% ���Ƃ��ł��܂��B
%
% [A,B] = WK1READ(...) �́A��Ɠ����悤�ɁA�Z���z�� B �Ƀe�L�X�g�f�[�^��
% �X�g�A���܂��B
%
% �Q�l�FWK1WRITE, CSVREAD, CSVWRITE.


%   Brian M. Bourgault 10/22/93 
%   Copyright 1984-2002 The MathWorks, Inc.  
% 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:33 $ 

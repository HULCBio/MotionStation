% FWRITE   �o�C�i���f�[�^���t�@�C���ɏ����o���܂��B
% 
% COUNT = FWRITE(FID,A,PRECISION) �́A�s�� A �̗v�f���w�肵���t�@�C
% ���ɁAMATLAB�l�̎w�肵�����x�ŕϊ����ď����o���܂��B�f�[�^�́A��
% �ɏ����o����܂��BCOUNT�́A����ɏ����o���ꂽ�v�f���ł��B
%
% FID �́AFOPEN ���瓾���鐮���̃t�@�C�����ʎq�ŁA�W���o�͂ɑ΂���
% ��1�A�W���G���[�ɑ΂��Ă�2�ł��B
% 
% PRECISION �́A���ʂ̌^�ƃT�C�Y�𐧌䂵�܂��BFREAD �Ŏg�p�ł��鐸�x
% �̃��X�g���Q�Ƃ��Ă��������B'bitN' �܂��� 'ubitN' �̂ǂ��炩�� PRECISION 
% �ɑ΂��Ďg��ꂽ�ꍇ�́AA �͈̔͊O�̒l�́A���ׂẴr�b�g���I���ł���
% ��Ԃ̒l�Ƃ��ĕ\����܂��B
%
% COUNT = FWRITE(FID,A,PRECISION,SKIP) �́A�e PRECISION �l��������
% ��O�ɃX�L�b�v����o�C�g����ݒ肷��I�v�V������ SKIP �������܂��
% ���܂��BSKIP�������ݒ肳��Ă���ꍇ�́AFWRITE �́AA �̗v�f���ׂĂ�
% �������܂ŃX�L�b�v���Ēl�������A�܂��X�L�b�v���đ��̒l�������A���X��
% �Ȃ�܂��BPRECISION �� 'bitN' �܂��� 'ubitN' �̂悤�ȃr�b�g�t�H�[�}�b�g
% �̏ꍇ�́ASKIP �̓r�b�g�P�ʂŐݒ肳��܂��B����́A�Œ蒷�̃��R�[�h
% �����A���̃t�B�[���h�Ƀf�[�^��}������̂ɗL���ł��B
%
% ���Ƃ��΁A
%
%     fid = fopen('magic5.bin','wb')
%     fwrite(fid,magic(5),'integer*4')
%
% �́A4�o�C�g�̐����Ƃ��Ċi�[���ꂽ�A5�s5��̖����w�s���25�v�f���܂ށA
% 100�o�C�g�̃o�C�i���t�@�C�����쐬���܂��B
%
% �Q�l�FFREAD, FPRINTF, SAVE, DIARY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:16 $
%   Built-in function.

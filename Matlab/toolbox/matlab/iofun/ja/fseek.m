% FSEEK   �t�@�C���̈ʒu�w���q�̐ݒ�
% 
% STATUS = FSEEK(FID�AOFFSET�AORIGIN) �́AFID �Ŏw�肳���t�@�C����
% �̃t�@�C���ʒu�w���q���AORIGIN �ɑ΂��Ďw�肳�ꂽ OFFSET �o�C�g�̈�
% �u�Ɉړ����܂��B
%
% FID �́AFOPEN ���瓾���鐮���̃t�@�C�����ʎq�ł��B
%
% OFFSET �̒l�́A���̂悤�ɉ��߂���܂��B
%     > 0    �t�@�C���̏I�[�����ֈړ�
%     = 0    �ʒu��ύX���܂���
%     < 0    �t�@�C���̐擪�����ֈړ�
%
% ORIGIN�̒l�́A���̂悤�ɉ��߂���܂��B
%     'bof' �܂��� -1   �t�@�C���̐擪
%     'cof' �܂���  0   �t�@�C�����̃J�����g�̈ʒu
%     'eof' �܂���  1   �t�@�C���̏I�[
%
% STATUS �́Afseek ���삪���������0�ŁA���s�Ȃ��-1�ł��B�G���[������
% ����ꍇ�́A��葽���̏��𓾂邽�߂ɁAFERROR ���g���Ă��������B
%
% ���:
%
%     fseek(fid,0,-1)
%
% �́A�t�@�C���������C���h���܂��B
%
% �Q�l�FFOPEN, FTELL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:13 $
%   Built-in function.


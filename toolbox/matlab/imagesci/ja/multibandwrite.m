% MULTIBANDWRITE   �t�@�C���ւ̃}���`�o���h�̃f�[�^�̏�������
%
% MULTIBANDWRITE �́A�o�C�i���t�@�C����3�����̃f�[�^�Z�b�g�������o���܂��B
% ���ׂẴf�[�^��1�̊֐��̌Ăяo���ŏ������܂�邩�A�܂��� 
% MULTIBANDWRITE �̓t�@�C���Ɋ��S�ȃf�[�^�Z�b�g�̈ꕔ���������ނ��߂�
% �J��Ԃ��R�[������܂��B
%
% �ȉ���2�̍\���́A1�̊֐��̌Ăяo���Ńt�@�C���ɂ��ׂẴf�[�^
% �Z�b�g���������ނ��߂� MULTIBANDWRITE ���g�p������@�ł��B�ȉ���
% �L�q�����I�v�V�����̃p�����[�^/�l�̑΂͂����̍\���Ƌ��Ɏg�p����
% ���Ƃ��ł��܂��B
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE) �́A�o�C�i���t�@�C�� 
%   FILENAME �ɔC�ӂ̐��l�܂��͘_���^�C�v��2�����܂���3�����z��Ƃ���
%   DATA ���������݂܂��B�o���h�� INTERLEAVE �Ŏw�肳�ꂽ������
%   �t�@�C���ɏ�����Ă��܂��BDATA ��3�Ԗڂ̎����̒����́A�o���h�̐���
%   �����ł��B�f�t�H���g�ł́A�f�[�^��MATLAB�Ɋi�[���ꂽ���̂Ɠ������x
%   �Ńt�@�C���ɏ������܂�܂�(DATA �̃N���X�Ɠ����ł�)�BINTERLEAVE �́A
%   �t�@�C���ɏ������܂ꂽ�o���h�ɃC���^�[���[�u�̎�@���w�肷�镶����
%   �ł��B�L���ȕ������ ���ꂼ�� band-interleaved-by-line�A
%   band-interleaved-by-pixel�Aband-sequential ��\��'bil'�A'bip'�A
%   'bsq'�ł��BDATA ��2�����̏ꍇ�́AINTERLEAVE �͉����s���܂���B
%   FILENAME �����ɑ��݂���ꍇ�A�I�v�V������ OFFSET �p�����[�^���w��
%   ����Ă��Ȃ���Ώ㏑������܂��B
%     
% ���ׂẴf�[�^�Z�b�g�́A���L�̍\�����g�p���� MULTIBANDWRITE �ւ̕���
% �̃R�[�����쐬����A�t�@�C���ɍו������ꂽ�`�ŏ������܂�܂��B
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,START,TOTALSIZE) �́A�o�C�i��
%   �t�@�C���ɏ������f�[�^���������݂܂��BDATA �͂��ׂẴf�[�^�Z�b�g��
%   �T�u�Z�b�g�ł��BMULTIBANDWRITE �́A�t�@�C���ɂ��ׂẴf�[�^����������
%   ���߂ɕ�����R�[������܂��B���ׂẴt�@�C���́A�ŏ��̊֐��̌Ăяo����
%   �ɏ������܂�A�T�u�Z�b�g�̊O�����ŏ��̌Ăяo���ŗ^����ꂽ�l�Ŗ�������
%   �܂��B�����Ă���ɑ����Ăяo���͖��߂�ꂽ�l�̂��ׂāA���邢�͈ꕔ��
%   �㏑�����܂��B�p�����[�^ FILENAME�AINTERLEAVE�AOFFSET ����� TOTALSIZE 
%   �́A�t�@�C���̑S�̂��������ނ܂ł͈��̂܂܂ł���ׂ��ł��B
%
%      START == [firstrow firstcolumn firstband] �́A1�~3�ł��B�����ŁA
%      firstrow �� firstcolumn �̓{�b�N�X���̍���̃C���[�W�̃s�N�Z��
%      �ʒu����^���Afirstband �͏������ނ��߂̍ŏ��̃o���h�̃C���f�b�N�X
%      ��^���܂��BDATA �́A�������̃o���h�ɑ΂��Ă������̃f�[�^��
%      �܂�ł��܂��BDATA(I,J,K) �́A(firstband + K - 1)�Ԗڂ̃o���h����
%      [firstrow + I - 1, firstcolumn + J - 1]�̃s�N�Z���ɑ΂���f�[�^��
%      �܂݂܂��B
%
%      TOTALSIZE == [totalrows,totalcolumns,totalbands] �́A�t�@�C����
%      �܂܂�Ă��邷�ׂẴf�[�^�Z�b�g��3�����T�C�Y���ׂĂ�^���܂��B
%
% �����̃I�v�V�����p�����[�^/�l�̐��Ƒg�ݍ��킹�́A��L�\���̂�������
% �Ō�ɉ������܂��B
%
% MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,...,PARAM,VALUE,...) 
%
%   �p�����[�^�l�̑g:
%     
%   PRECISION �́A�t�@�C���ɏ������ފe�v�f�̏����ƃT�C�Y���R���g���[��
%   ���邽�߂̕�����ł��BPRECISION �ɑ΂���L���Ȓl�̃��X�g�ɂ��Ă�
%   FWRITE �̃w���v���Q�Ƃ��Ă��������B�f�t�H���g�̐��x�́A�f�[�^��
%   �N���X�ł��B
%
%   OFFSET �́A�ŏ��̃f�[�^�v�f�̑O�ɃX�L�b�v���邽�߂̃o�C�g���ł��B
%   �t�@�C�������ɑ��݂���ꍇ�A�f�t�H���g�ŃX�y�[�X�𖞂������߂�
%   ASCII�̃k���l���������܂�܂��B�f�[�^���������ޑO�ɁA���邢�͏���
%   ���񂾌�ɁA�t�@�C���Ƀw�b�_���������ނƂ��ɂ��̃I�v�V�����͗L���ł��B
%   �f�[�^���������񂾌�Ƀw�b�_���������ނƂ��A�t�@�C���� �p�[�~�b�V����
%   'r+' ���g�p���� FOPEN �ŊJ���ׂ��ł��B
%
%   MACHFMT �́A�t�@�C���ɏ������܂ꂽ�f�[�^�̏������R���g���[������
%   ������ł��BFOPEN �Ńh�L�������g������Ă��� MACHINEFORMAT �ɑ΂���
%   ���ׂĂ̒l�͗L���ł����A�W���̒l�́Alittle endian �ɑ΂��� 'ieee-le'�A
%   big endian �ɑ΂��� 'ieee-be' �ł��B���ׂẴ��X�g�� FOPEN ���Q��
%   ���Ă��������B�f�t�H���g�̃}�V���t�H�[�}�b�g�́A���[�J���̃}�V��
%   �t�H�[�}�b�g�ł��B
%     
%   FILLVALUE �́A�s���f�[�^�ɑ΂��Ďw�肳���l�̐��ł��BFILLVALUE ��
%   ���ׂĂ̕s�������f�[�^�ɑ΂���fill�l���w�肷��P��̐����A�܂��� 
%   �e�o���h�ɑ΂���fill�l���w�肷��o���h�̐��� 1�~number �̃x�N�g��
%   �ł��B���̒l�̓f�[�^���ו������ď������܂��Ƃ��ɁA�X�y�[�X��
%   ���߂邽�߂Ɏg���܂��B
%
% ���:
%
%   1.  ���ׂẴf�[�^��1�̊֐��Ăяo���Ńt�@�C���ɏ������܂�܂��B
%       �o���h�� interleaved by line �ł��B
%        
%         multibandwrite(data,'data.img','bil');
%  
%   2.  MUTLIBANDWRITE �́A�t�@�C���Ɋe�o���h���������ނ��߂Ƀ��[�v��
%       ���Ŏg���܂��B
%
%       for i=1:totalBands
%           multibandwrite(bandData,'data.img','bip',[1 1 i],...
%                          [totalColumns, totalRows, totalBands]);
%       end
%       
%   3.  �e�o���h�̃T�u�Z�b�g�̂� MULTIBANDWRITE �ւ̊e�Ăяo���Ƃ���
%       ���p�\�ł��B�Ⴆ�΁A���ׂẴf�[�^�Z�b�g��1024�~1024�s�N�Z��
%       ��3�̃o���h(1024�~1024�~3�̍s��)������������܂���B
%       128�~128�̉�̂�MULTIBANDWRITE �ւ̊e�Ăяo���Ƃ��ăt�@�C����
%       �������ނ��Ƃ��\�ł��B
%
%      numBands = 3;
%      totalDataSize =  [1024 1024 numBands];
%      for i=1:numBands
%         for k=1:8
%             for j=1:8
%                upperLeft = [(k-1)*128 (j-1)*128 i];
%                multibandwrite(data,'banddata.img','bsq',...
%                               upperLeft,totalDataSize);
%             end
%          end
%       end
%
% �Q�l : MULTIBANDREAD, FWRITE, FREAD 


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:10 $
%   $Revision.1 $  $Date: 2004/04/28 01:57:10 $



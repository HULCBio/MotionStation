% FITSINFO     FITS�t�@�C���̏����擾
%
% INFO = FITSINFO(FILENAME) �́AFITS (Flexible Image Transport System) 
% �t�@�C���̓��e�Ɋւ�������܂ލ\���̂̃t�B�[���h���o�͂��܂��B
% FILENAME �́AFITS �t�@�C���̖��O���w�肷�镶����ł��B
%
% �\���� INFO �́A���̃t�B�[���h���܂݂܂��B
%
% Filename     �t�@�C������\�������� 
%      
% FileSize     �t�@�C���̃T�C�Y���o�C�g�P�ʂŎ�������
%      
% FileModDate  �t�@�C���̏C�������܂ޕ�����
%
% Contents     �L�q����Ă��鏇�ԂɃt�@�C�����̊g���q���X�g���܂ރZ���z��
%      
% PrimaryData  FITS�t�@�C�����̊�{�f�[�^�Ɋւ�������܂ލ\����
%
% �\���� PrimaryData �́A���̃t�B�[���h���܂�ł��܂��B
%
%      DataType      �f�[�^�̐��x 
%      
%      Size          �e�����̃T�C�Y���܂ޔz��
%
%      DataSize      ��{�f�[�^�̃o�C�g���ŕ\�����T�C�Y 
%
%      MissingDataValue  ����`�f�[�^�ł��邱�Ƃ������l
%
%      Intercept     ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁASlope �Ɋւ��Ďg�p����l 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁAIntercept �Ɋւ��Ďg�p����l  
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        �t�@�C���̐擪����ŏ��̃f�[�^�l�̈ʒu�܂ł̃o�C�g��
%
%      Keywords      �e��̃w�b�_�ɂ��ׂĂ� Keywords, Values, Comments 
%                    ���܂�(�L�[���[�h��)�s3 ��̃Z���z��B
%
% FITS�t�@�C���́A�g�����\�ł��B���̃t�B�[���h��1�A�܂��͕����̂���
% ��INFO�\���̂̒��Ɋ܂܂��邱�Ƃ��ł��܂��B
%   
%      AsciiTable  ���̃t�@�C������ASCII Table�g���Ɋւ�������܂�
% �@�@�@�@�@�@�@�@ �\���̔z��
%         
%      BinaryTable ���̃t�@�C������Binary Table�g���Ɋւ�������܂�
%                  �\���̔z��
%         
%      Image       ���̃t�@�C������Image�g���Ɋւ�������܂ލ\���̔z��
%       
%      Unknown     ���̃t�@�C�����̕W���I�łȂ��g���Ɋւ�������܂�
%                  �\���̔z��
%
% �\���� AsciiTable �́A���̃t�B�[���h�������܂��B
%
%      Rows         �e�[�u�����̍s��
%        
%      RowSize      �e�s�̃L�����N�^��
%      
%      NFields      �e�s�̃t�B�[���h��
%      
%      FieldFormat  �e�t�B�[���h�������������Ƃ��Ɏg�p����t�H�[�}�b�g
%                   ���܂� 1 �s NFields ��̔z��B�t�H�[�}�b�g�́A
%                   FORTRAN-77 format�R�[�h�ł��B
%
%      FieldPrecision �e�t�B�[���h�Ƀf�[�^�̐��x���܂�1�sNFields��̔z��
%
%      FieldWidth   �e�t�B�[���h�ɃL�����N�^�����܂�1�sNFields��̔z��
%
%      FieldPos     �e�t�B�[���h�ɑ΂���J�n���\�����l����Ȃ�1�s
%                   NFields��̔z��
%
%      DataSize     ASCII Table���̃f�[�^�T�C�Y��\���o�C�g��
%
%      MissingDataValue  �e�t�B�[���h���̖���`�f�[�^��\�����߂Ɏg�p
%                        ���鐔�l����Ȃ�1�sNFIELDS��̔z��
%
%      Intercept    ���̕��������g���āA�z��f�[�^�l������ۂ̃f�[�^�l
%                   ���v�Z���邽�߂ɁASlope �ŗ��p���鐔�l����Ȃ�1�s
%                   NFIELDS ��̔z��:
%                   actual_value = Slope*array_value+Intercept
%		    
%      Slope        ���̕��������g���āA�z��f�[�^�l������ۂ̃f�[�^�l
%                   ���v�Z���邽�߂ɁAIntercept �ŗ��p���鐔�l����Ȃ�1�s
%                   NFIELDS ��̔z��
%                   actual_value = Slope*array_value+Intercept
%
%      Offset       �t�@�C���̐擪����e�[�u�����̍ŏ��̃f�[�^�l�̈ʒu�܂�
%                   �̃o�C�g��
%		    
%      Keywords     ASCII�e�[�u���w�b�_���̂��ׂĂ� Keywords, Values, 
%                   Comments ���܂�(�L�[���[�h�� ) �s 3 ��̃Z���z��
%          
% BinaryTable �\���̂́A�ȉ��̃t�B�[���h���܂݂܂��B
%
%      Rows        �e�[�u���̍s��
%                  
%      RowSize     �e�s�̃o�C�g��
%                  
%      NFields     �e�s�̃t�B�[���h��
%
%      FieldFormat  �e�t�B�[���h���̃f�[�^�̃f�[�^�^�C�v���܂�1�s 
%                   NFields��̃Z���B�f�[�^�^�C�v�́AFITS�o�C�i��
%                   �e�[�u���t�H�[�}�b�g�R�[�h�ŕ\�킳��܂��B
%
%      FieldPrecision  �e�t�B�[���h���̃f�[�^�̐��x���܂�1�sNFields��
%                      �̃Z��
%
%      FieldSize    N�Ԗڂ̃t�B�[���h�̒l�̐����܂�1�s NFields ��̔z��
%                            
%      DataSize     Binary Table���̃f�[�^�̃o�C�g���B�l�ɂ́A���C��
%                   �e�[�u���̂��ׂẴf�[�^���܂܂�܂��B
%
%      MissingDataValue  �e�t�B�[���h���̖���`�̃f�[�^��\�킷���߂�
%                        �p����1�sNFields ��̔z��
%
%      Intercept    ���̎����g���Ĕz��f�[�^�l����^�̃f�[�^�l���v�Z����
%                   ���߂�Slope�Ƌ��ɗp�����鐔�l����Ȃ�1�sNFields��z��:
%                   actual_value = Slope*array_value+ Intercept
%		    
%      Slope        ���̎����g���Ĕz��f�[�^�l����^�̃f�[�^�l���v�Z����
%                   ���߂�Intercept�Ƌ��ɗp�����鐔�l����Ȃ�1�sNFields��z��:
%                   actual_value = Slope*array_value+ Intercept
%		    
%      Offset       �t�@�C���̐擪����ŏ��̃f�[�^�l�̈ʒu�܂ł̃o�C�g��
%
%      ExtensionSize    ���C���e�[�u����ʉ߂��邷�ׂẴf�[�^�̃o�C�g�P��
%                       �̃T�C�Y
%
%      ExtensionOffset  �t�@�C���̐擪���烁�C���e�[�u����ʉ߂���f�[�^��
%                       �ʒu�܂ł̃o�C�g��
%      
%      Keywords     �o�C�i���e�[�u���w�b�_���̂��ׂĂ�Keywords, Values, 
%                   Comments���܂�(�L�[���[�h��) �s 3 ��̃Z���z��
%                    
% Image �\���̂́A�ȉ��̃t�B�[���h���܂݂܂��B
%   
%      DataType      �f�[�^�̐��x
%      
%      Size          �e�����̃T�C�Y���܂ޔz��
%
%      DataSize      Image�g���q���̃o�C�g�P�ʂ̃f�[�^�T�C�Y
%
%      MissingDataValue  ����`�f�[�^��\�킷���߂ɗp����l
%
%      Intercept     ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁASlope �Ɋւ��Ďg�p����l 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁAIntercept �Ɋւ��Ďg�p����l: 
%                    actual_value = Slope*array_value + Intercept
%
%      Offset        �t�@�C���̐擪����ŏ��̃f�[�^�l�̈ʒu�܂ł̃o�C�g��
%
%      Keywords      Image�̃w�b�_���̂��ׂĂ� Keywords, Values, Comments
%                    ���܂�(�L�[���[�h��) �s 3 ��̃Z���z��
%
% Unknown �\���̂́A�ȉ��̃t�B�[���h���܂݂܂��B
%
%      DataType      �f�[�^�̐��x
%
%      Size          �e�����̃T�C�Y���܂ޔz��
%
%      DataSize      �g���q���̃o�C�g�P�ʂ̃f�[�^�T�C�Y
%      
%      Intercept     ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁASlope �Ɋւ��Ďg�p����l 
%                    actual_value = Slope*array_value + Intercept
%
%      Slope         ���̎����g���Ĕz��s�N�Z���l����^�̃s�N�Z���l��
%                    �v�Z���邽�߂ɁAIntercept �Ɋւ��Ďg�p����l 
%                    actual_value = Slope*array_value + Intercept
%
%      MissingDataValue  ����`�f�[�^��\�킷���߂ɗp����l
%
%      Offset        �t�@�C���̐擪����ŏ��̃f�[�^�l�̈ʒu�܂ł̃o�C�g��
%
%      Keywords      �g���q�w�b�_���̂��ׂĂ�Keywords, Values, 
%                    Comments���܂�(�L�[���[�h��) �s 3 ��̃Z���z��
%
% �Q�l �F FITSREAD.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:41 $


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LP635    � Autor � Crislei Toledo        � Data � 14.01.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � RDMAKE para posicionar a tabela de TES e verificar se deve ���
���          � ou nao contabilizar a NF em questao                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ESPECIFICO PARA EPC                                        ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA    � MOTIVO DA ALTERACAO                            ���
�������������������������������������������������������������������������Ĵ��
���            �         �                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


#include "rwmake.ch"        
User Function LP635()

Local cParam  := PARAMIXB
Local nRet    := 0
Local aArqAtu := { Alias(), IndexOrd(), Recno()}
Local aArqSF2 := { SF2->(IndexOrd()),SF2->(Recno()) }
Local aArqSF4 := { SF4->(IndexOrd()),SF4->(Recno()) } 
Local aArqSD2 := { SD2->(IndexOrd()),SD2->(Recno()) }

DbSelectArea("SD2")
DbSetOrder(3) //Documento+Serie+Cliente+Loja
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

If !Eof()
   DbSelectArea("SF4")
   DbSetOrder(1) //Codigo
   DbSeek(xFilial("SF4")+SD2->D2_TES)
   If !Eof()
      Do Case
         Case cParam $ "SV"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO$"D/B",0,IIF(ALLTRIM(SF2->F2_SERIE) $ "FAT/U/SF",SF2->F2_VALBRUT,0))
         Case cParam $ "IS"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO$"D/B",0,SF2->F2_VALISS)
         Case cParam $ "IR"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO$"D/B",0,SF2->F2_VALIRRF)
         Case cParam $ "IN"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO$"D/B",0,SF2->F2_VALINSS)
         Case cParam $ "VD"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO$"D/B",0,IIF(SF2->F2_SERIE$"NF /NFA",SF2->F2_VALMERC,0))
         Case cParam $ "DV"
              nRet := IIF(SF4->F4_CONTAB="N" .OR. SF2->F2_TIPO<>"D",0,IIF(SF2->F2_SERIE$"NF /NFA",SF2->F2_VALMERC,0))
         Case cParam $ "IC"
              nRet := IIF(SF4->F4_CONTAB = "N",0,IIF(SF2->F2_SERIE$"NF /NFA",SF2->F2_VALICM,0))
      EndCase
   EndIf
EndIf

//Restaurando o ambiente
DbSelectArea("SD2")
DbSetOrder(aArqSD2[1])
DbGoTo(aArqSD2[2]) 

DbSelectArea("SF4")
DbSetOrder(aArqSF4[1])
DbGoTo(aArqSF4[2]) 

DbSelectArea("SF2")
DbSetOrder(aArqSF2[1])
DbGoTo(aArqSF2[2])

DbSelectArea(aArqAtu[01])
DbSetOrder(aArqAtu[02])
DbGoTo(aArqAtu[03])


Return(nRet)
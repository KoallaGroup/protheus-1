#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function SD1100E()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("AARQSD,CANO,CMES,CREV,CCCUSTO,CDESCRI")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SD1100E  � Autor �Ederson Dilney Colen M.� Data �14/01/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Gravacao do Saldo na Exclusao da Nota Fiscal de  ���
���          � Entrada no Estoque.                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para EPC                                        ���
���          � Usado sobre o ponto de entrada.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

aArqSD  := { Alias() , IndexOrd() , Recno() }
cAno	:= SubStr(DtoS(SD1->D1_DTREF),1,4)
cMes	:= SubStr(DtoS(SD1->D1_DTREF),5,2)
cRev	:= "000"
cCCusto := SD1->D1_CC+Space(11-Len(SD1->D1_CC))
cDescri := SD1->D1_FORNECE+SD1->D1_LOJA+Space(10-Len(SD1->D1_FORNECE+SD1->D1_LOJA))

dbSelectArea("SZB")
dbSetOrder(1)
dbSeek(xFilial("SZB")+cCCusto+cAno)

While (! Eof()) 				       .And. ;
      (SZB->ZB_FILIAL          == xFilial("SZB"))      .And. ;
      (Alltrim(SZB->ZB_CCUSTO) == Alltrim(SD1->D1_CC)) .And. ;
      (SZB->ZB_ANO             == cAno)

  If Val(cRev) < Val(SZB->ZB_Revisao)
     cRev := SZB->ZB_Revisao
  EndIf

  dbSelectArea("SZB")
  dbSkip()

EndDo

dbSelectArea("SZB")
dbSetOrder(2)
dbSeek(xFilial("SZB")+cCCusto+cAno+cRev+cDescri)

While (!Eof())                                                 .And. ;
      (SZB->ZB_FILIAL          == xFilial("SZB"))              .And. ;
      (Alltrim(SZB->ZB_CCUSTO) == Alltrim(SD1->D1_CC))       .And. ;
      (SZB->ZB_Ano             == cAno)                        .And. ;
      (SZB->ZB_Revisao         == cRev)                        .And. ;
      (Alltrim(SZB->ZB_Descri) == SD1->D1_FORNECE+SD1->D1_LOJA)
 
   If SZB->ZB_TIPO <> "D"
      dbSelectArea("SZ2")
      dbSetOrder(3)
      dbSeek(xFilial("SZ2")+cCCusto)

      dbSelectArea("SZC")
      dbSetOrder(2)
      dbSeek(xFilial("SZC")+SZ2->Z2_COD+SD1->D1_FORNECE+SD1->D1_LOJA)

      If Eof()
         MSGSTOP("Para este titulo nao existe um Contrato x Fornecedor.")
         dbSelectArea("SZB")
         dbSkip()
         Loop
      EndIf
   EndIf

   dbSelectArea("SZB")
   RecLoCk("SZB",.F.)
   Do Case
      Case cMes == "01"
           Replace ZB_SALD01 With SZB->ZB_SALD01 - SD1->D1_TOTAL
      Case cMes == "02"
           Replace ZB_SALD02 With SZB->ZB_SALD02 - SD1->D1_TOTAL
      Case cMes == "03"
           Replace ZB_SALD03 With SZB->ZB_SALD03 - SD1->D1_TOTAL
      Case cMes == "04"
           Replace ZB_SALD04 With SZB->ZB_SALD04 - SD1->D1_TOTAL
      Case cMes == "05"
           Replace ZB_SALD05 With SZB->ZB_SALD05 - SD1->D1_TOTAL
      Case cMes == "06"
           Replace ZB_SALD06 With SZB->ZB_SALD06 - SD1->D1_TOTAL
      Case cMes == "07"
           Replace ZB_SALD07 With SZB->ZB_SALD07 - SD1->D1_TOTAL
      Case cMes == "08"
           Replace ZB_SALD08 With SZB->ZB_SALD08 - SD1->D1_TOTAL
      Case cMes == "09"
           Replace ZB_SALD09 With SZB->ZB_SALD09 - SD1->D1_TOTAL
      Case cMes == "10"
           Replace ZB_SALD10 With SZB->ZB_SALD10 - SD1->D1_TOTAL
      Case cMes == "11"
           Replace ZB_SALD11 With SZB->ZB_SALD11 - SD1->D1_TOTAL
      Case cMes == "12"
           Replace ZB_SALD12 With SZB->ZB_SALD12 - SD1->D1_TOTAL
   EndCase

   MsUnLock()

   dbSelectArea("SZB")
   dbSkip()

EndDo

DbSelectArea(aArqSD[1])
DbSetOrder(aArqSD[2])
DbGoTo(aArqSD[3])

// Substituido pelo assistente de conversao do AP5 IDE em 25/06/01 ==> __Return()
Return()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � LP656    � Autor �Crislei de A. Toledo   � Data �10/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina para posicionar a tabela SD1 no LP de estorno de NF ���
���          � com Rateio                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para EPC                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

#include "rwmake.ch"

User Function LP656()

Local cParam  := PARAMIXB
Local nValLct := 0
Local aArqAnt := {Alias(), IndexOrd(), Recno()}
Local aArqSD1 := {"SD1",SD1->(IndexOrd()), SD1->(Recno())}
Local aArqSDE := {"SDE",SDE->(IndexOrd()), SDE->(Recno())}

/*
cParam = I => Item da NF (despesa)
cParam = P => PIS
cParam = C => COFINS
cParam = D => DIF. ALIQUOTA
cParam = R => ICMS RETIDO
*/

/*
Do Case 
   Case cParam $ "I"
        dbSelectArea("SD1")
        dbSetOrder(13)//FILIAL+DOCUMENTO+SERIE+FORNECEDOR+LOJA+ITEMNF
        If dbSeek(xFilial("SD1")+SDE->DE_DOC+SDE->DE_SERIE+SDE->DE_FORNECE+SDE->DE_LOJA+SDE->DE_ITEMNF)
//              nValLct := (SDE->DE_PERC*(SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_ICMSRET+D1_ICMSCOM))/100-(SDE->DE_PERC*SD1->D1_VALDESC)/100) 
              nValLct := (SDE->DE_PERC*(SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE))/100-(SDE->DE_PERC*SD1->D1_VALDESC)/100) 
        EndIf
   Case cParam $ "P/C"
        dbSelectArea("SF1")
        dbSetOrder(1)//FILIAL+DOCUMENTO+SERIE+FORNECEDOR+LOJA
        If dbSeek(xFilial("SF1")+SDE->DE_DOC+SDE->DE_SERIE+SDE->DE_FORNECE+SDE->DE_LOJA)        
           If cParam $ "C" .AND. SF1->F1_VALIMP5 <> 0
              nValLct := ((SDE->DE_PERC/100)*(SF1->F1_VALIMP5))
           ElseIf cParam $ "P" .AND. SF1->F1_VALIMP6 <>0
                  nValLct := ((SDE->DE_PERC/100)*(SF1->F1_VALIMP6))
           EndIf
        EndIf
EndCase
*/

dbSelectArea("SD1")
dbOrderNickName("USUSD101") //dbSetOrder(13)//FILIAL+DOCUMENTO+SERIE+FORNECEDOR+LOJA+ITEMNF

If dbSeek(xFilial("SD1")+SDE->DE_DOC+SDE->DE_SERIE+SDE->DE_FORNECE+SDE->DE_LOJA+SDE->DE_ITEMNF)        
   Do Case 
      Case cParam $ "I"        
           nValLct := (SDE->DE_PERC*(SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE))/100-(SDE->DE_PERC*SD1->D1_VALDESC)/100) 
      Case cParam $ "P"
           If SD1->D1_VALIMP6 <> 0
              nValLct := ((SDE->DE_PERC/100)*(SD1->D1_VALIMP6))
           EndIf
      Case cParam $ "C"
           If SD1->D1_VALIMP5 <> 0
              nValLct := ((SDE->DE_PERC/100)*(SD1->D1_VALIMP5))
           EndIf
      Case cParam $ "D"
           nValLct := ((SDE->DE_PERC*SD1->D1_ICMSCOM)/100-(SDE->DE_PERC*SD1->D1_VALDESC)/100)
      Case cParam $ "R"
           nValLct := ((SDE->DE_PERC*SD1->D1_ICMSRET)/100-(SDE->DE_PERC*SD1->D1_VALDESC)/100)
   EndCase
EndIf

dbSelectArea(aArqSDE[01])
dbSetOrder(aArqSDE[02])
dbGoTo(aArqSDE[03])

dbSelectArea(aArqSD1[01])
dbSetOrder(aArqSD1[02])
dbGoTo(aArqSD1[03])

dbSelectArea(aArqAnt[01])
dbSetOrder(aArqAnt[02])
dbGoTo(aArqAnt[03])

Return(nValLct)
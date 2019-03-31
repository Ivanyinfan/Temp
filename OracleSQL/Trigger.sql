CREATE OR REPLACE TRIGGER I_I_ITM_STOREITEM 
AFTER INSERT
ON I_ITM_STOREITEM 
REFERENCING NEW AS NEWROW OLD AS OLD
FOR EACH ROW
begin  Insert into Rep_LogTable values ( S_Rep_LogTable.nextVal , 'I_ITM_STOREITEM');
Insert Into R_SD_I_ITM_STOREITEM ( 
    Rep_sync_id, Rep_common_id, 
    Rep_operationType, 
    Rep_status, 
    ID , 
    ITEMCODE , 
    COUNTERCODE , 
    PROMOTIONMARK , 
    DISCOUNTMARK , 
    MEMBERPRICE , 
    STORETEMPPRICE , 
    STORESALESTATE , 
    TEMPDISTRIBUTIONMARK , 
    MERCHANTCODE , 
    ITEMNAME , 
    BARCODE , 
    ITEMSHORTNAME , 
    ITEMTYPECODE , 
    RETAILTYPECODE , 
    PRODUCTCODE , 
    UNIT , 
    RETURNGOODS , 
    PRICE , 
    ITEMCODETYPE , 
    STORECODE , 
    BRANDCODE , 
    CLASSCODE , 
    AREACODE , 
    rep_old_ID , 
    Rep_server_name , 
    Rep_PK_Changed 
) Values ( 
    S_R_SD_I_ITM_STOREITEM.nextVal, 
    null ,
    'I',
    null , 
    :newRow.ID , 
    :newRow.ITEMCODE , 
    :newRow.COUNTERCODE , 
    :newRow.PROMOTIONMARK , 
    :newRow.DISCOUNTMARK , 
    :newRow.MEMBERPRICE , 
    :newRow.STORETEMPPRICE , 
    :newRow.STORESALESTATE , 
    :newRow.TEMPDISTRIBUTIONMARK , 
    :newRow.MERCHANTCODE , 
    :newRow.ITEMNAME , 
    :newRow.BARCODE , 
    :newRow.ITEMSHORTNAME , 
    :newRow.ITEMTYPECODE , 
    :newRow.RETAILTYPECODE , 
    :newRow.PRODUCTCODE , 
    :newRow.UNIT , 
    :newRow.RETURNGOODS , 
    :newRow.PRICE , 
    :newRow.ITEMCODETYPE , 
    :newRow.STORECODE , 
    :newRow.BRANDCODE , 
    :newRow.CLASSCODE , 
    :newRow.AREACODE , 
    :newRow.ID , 
    'hlmis_3001',null
) ; end ;
/

CREATE OR REPLACE TRIGGER HLBH.D_I_ITM_STOREITEM 
AFTER DELETE
ON HLBH.I_ITM_STOREITEM 
REFERENCING NEW AS NEW OLD AS OLDROW
FOR EACH ROW
begin  Insert into Rep_LogTable values ( S_Rep_LogTable.nextVal , 'I_ITM_STOREITEM');
Insert Into R_SD_I_ITM_STOREITEM ( 
    Rep_sync_id, Rep_common_id,
    Rep_operationType, 
    Rep_status, 
    ID , 
    ITEMCODE , 
    COUNTERCODE , 
    PROMOTIONMARK , 
    DISCOUNTMARK , 
    MEMBERPRICE , 
    STORETEMPPRICE , 
    STORESALESTATE , 
    TEMPDISTRIBUTIONMARK , 
    MERCHANTCODE , 
    ITEMNAME , 
    BARCODE , 
    ITEMSHORTNAME , 
    ITEMTYPECODE , 
    RETAILTYPECODE , 
    PRODUCTCODE , 
    UNIT , 
    RETURNGOODS , 
    PRICE , 
    ITEMCODETYPE , 
    STORECODE , 
    BRANDCODE , 
    CLASSCODE , 
    AREACODE , 
    rep_old_ID , 
    Rep_server_name , 
    Rep_PK_Changed 
)
Values ( 
    S_R_SD_I_ITM_STOREITEM.nextVal, 
    null ,
    'D', 
    null , 
    :oldRow.ID , 
    :oldRow.ITEMCODE , 
    :oldRow.COUNTERCODE , 
    :oldRow.PROMOTIONMARK , 
    :oldRow.DISCOUNTMARK , 
    :oldRow.MEMBERPRICE , 
    :oldRow.STORETEMPPRICE , 
    :oldRow.STORESALESTATE , 
    :oldRow.TEMPDISTRIBUTIONMARK , 
    :oldRow.MERCHANTCODE , 
    :oldRow.ITEMNAME , 
    :oldRow.BARCODE , 
    :oldRow.ITEMSHORTNAME , 
    :oldRow.ITEMTYPECODE , 
    :oldRow.RETAILTYPECODE , 
    :oldRow.PRODUCTCODE , 
    :oldRow.UNIT , 
    :oldRow.RETURNGOODS , 
    :oldRow.PRICE , 
    :oldRow.ITEMCODETYPE , 
    :oldRow.STORECODE , 
    :oldRow.BRANDCODE , 
    :oldRow.CLASSCODE , 
    :oldRow.AREACODE , 
    :oldRow.ID , 
    'hlmis_3001',
    null
) ; end ;

CREATE OR REPLACE TRIGGER HLBH.U_I_ITM_STOREITEM 
AFTER UPDATE
ON HLBH.I_ITM_STOREITEM 
REFERENCING NEW AS NEWROW OLD AS OLDROW
FOR EACH ROW
declare maxlogid number; pkchanged char(1);  begin  Insert into Rep_LogTable values ( S_Rep_LogTable.nextVal , 'I_ITM_STOREITEM');  Select max(Rep_cid) into maxlogid from Rep_LogTable;  if( :oldRow.ID!= :newRow.ID ) THEN  pkChanged := 'Y';  END IF;  Insert Into R_SD_I_ITM_STOREITEM ( Rep_sync_id, Rep_common_id, Rep_operationType, Rep_status, ID , ITEMCODE , COUNTERCODE , PROMOTIONMARK , DISCOUNTMARK , MEMBERPRICE , STORETEMPPRICE , STORESALESTATE , TEMPDISTRIBUTIONMARK , MERCHANTCODE , ITEMNAME , BARCODE , ITEMSHORTNAME , ITEMTYPECODE , RETAILTYPECODE , PRODUCTCODE , UNIT , RETURNGOODS , PRICE , ITEMCODETYPE , STORECODE , BRANDCODE , CLASSCODE , AREACODE , rep_old_ID , Rep_server_name , Rep_PK_Changed ) Values ( S_R_SD_I_ITM_STOREITEM.nextVal,maxlogid,'U','B',:oldRow.ID , :oldRow.ITEMCODE , :oldRow.COUNTERCODE , :oldRow.PROMOTIONMARK , :oldRow.DISCOUNTMARK , :oldRow.MEMBERPRICE , :oldRow.STORETEMPPRICE , :oldRow.STORESALESTATE , :oldRow.TEMPDISTRIBUTIONMARK , :oldRow.MERCHANTCODE , :oldRow.ITEMNAME , :oldRow.BARCODE , :oldRow.ITEMSHORTNAME , :oldRow.ITEMTYPECODE , :oldRow.RETAILTYPECODE , :oldRow.PRODUCTCODE , :oldRow.UNIT , :oldRow.RETURNGOODS , :oldRow.PRICE , :oldRow.ITEMCODETYPE , :oldRow.STORECODE , :oldRow.BRANDCODE , :oldRow.CLASSCODE , :oldRow.AREACODE , :oldRow.ID , 'lbmis.dep6.com_3001',null) ;  Insert Into R_SD_I_ITM_STOREITEM ( Rep_sync_id, Rep_common_id, Rep_operationType, Rep_status, ID , ITEMCODE , COUNTERCODE , PROMOTIONMARK , DISCOUNTMARK , MEMBERPRICE , STORETEMPPRICE , STORESALESTATE , TEMPDISTRIBUTIONMARK , MERCHANTCODE , ITEMNAME , BARCODE , ITEMSHORTNAME , ITEMTYPECODE , RETAILTYPECODE , PRODUCTCODE , UNIT , RETURNGOODS , PRICE , ITEMCODETYPE , STORECODE , BRANDCODE , CLASSCODE , AREACODE , rep_old_ID , Rep_server_name , Rep_PK_Changed ) Values ( S_R_SD_I_ITM_STOREITEM.nextVal, maxlogid,'U','A',:newRow.ID , :newRow.ITEMCODE , :newRow.COUNTERCODE , :newRow.PROMOTIONMARK , :newRow.DISCOUNTMARK , :newRow.MEMBERPRICE , :newRow.STORETEMPPRICE , :newRow.STORESALESTATE , :newRow.TEMPDISTRIBUTIONMARK , :newRow.MERCHANTCODE , :newRow.ITEMNAME , :newRow.BARCODE , :newRow.ITEMSHORTNAME , :newRow.ITEMTYPECODE , :newRow.RETAILTYPECODE , :newRow.PRODUCTCODE , :newRow.UNIT , :newRow.RETURNGOODS , :newRow.PRICE , :newRow.ITEMCODETYPE , :newRow.STORECODE , :newRow.BRANDCODE , :newRow.CLASSCODE , :newRow.AREACODE , :oldRow.ID , 'hlmis_3001',pkChanged) ;  end ;
/


drop table R_SD_I_ITM_STOREITEM;

drop table I_ITM_STOREITEM;
select count(*) from I_ITM_STOREITEM;
CREATE TABLE "C##DEP6"."I_ITM_STOREITEM" 
(	"ID" CHAR(12 BYTE) NOT NULL ENABLE, 
	"ITEMCODE" CHAR(7 BYTE) NOT NULL ENABLE, 
	"COUNTERCODE" CHAR(6 BYTE), 
	"PROMOTIONMARK" CHAR(1 BYTE) DEFAULT 'X', 
	"DISCOUNTMARK" NUMBER(1,0), 
	"MEMBERPRICE" NUMBER(12,2), 
	"STORETEMPPRICE" NUMBER(12,2), 
	"STORESALESTATE" NUMBER(1,0), 
	"TEMPDISTRIBUTIONMARK" NUMBER(1,0), 
	"MERCHANTCODE" CHAR(6 BYTE), 
	"ITEMNAME" VARCHAR2(50 BYTE), 
	"BARCODE" VARCHAR2(20 BYTE), 
	"ITEMSHORTNAME" VARCHAR2(12 BYTE), 
	"ITEMTYPECODE" CHAR(5 BYTE), 
	"RETAILTYPECODE" CHAR(3 BYTE), 
	"PRODUCTCODE" VARCHAR2(30 BYTE), 
	"UNIT" VARCHAR2(10 BYTE), 
	"RETURNGOODS" NUMBER(1,0), 
	"PRICE" NUMBER(12,2), 
	"ITEMCODETYPE" NUMBER(1,0) DEFAULT 0, 
	"STORECODE" CHAR(5 BYTE) NOT NULL ENABLE, 
	"BRANDCODE" CHAR(6 BYTE), 
	"CLASSCODE" VARCHAR2(8 BYTE), 
	"AREACODE" VARCHAR2(8 BYTE), 
	 CONSTRAINT "I_ITM_STOREITEM_U01" UNIQUE ("ITEMCODE", "COUNTERCODE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MASTER"  ENABLE, 
	 CONSTRAINT "I_ITEM_STOREITEM_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 917504 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "IDX_ITM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 25 PCTUSED 0 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 5242880 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "SALES_1" ;

   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ID" IS '编号门店编码+商品编码';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ITEMCODE" IS '商品编码*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."COUNTERCODE" IS '柜号*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."PROMOTIONMARK" IS '促销标志*（X－表示不促销A,B,C－表示促销）';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."DISCOUNTMARK" IS 'POS允许打折*0：不允许1：允许';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."MEMBERPRICE" IS '会员价';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."STORETEMPPRICE" IS '门店暂时售价*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."STORESALESTATE" IS '门店销售状态*0：正常1：自动登记删除2：手工登记删除3: 合同终止（3.2 门店自动撤销"登记删除"）';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."TEMPDISTRIBUTIONMARK" IS '是否临时销售状态*0：否1：是';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."MERCHANTCODE" IS '供应商编码*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ITEMNAME" IS '商品全称*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."BARCODE" IS '条形码*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ITEMSHORTNAME" IS '商品简称*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ITEMTYPECODE" IS '商品分类编码*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."RETAILTYPECODE" IS '销售分类*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."PRODUCTCODE" IS '商品货号';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."UNIT" IS '计量单位*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."RETURNGOODS" IS '是否允许退货*0：不允许1：允许';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."PRICE" IS '核定售价*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."ITEMCODETYPE" IS '商品编码类型*0：正常商品编码1：大类码';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."STORECODE" IS '门店号*';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."BRANDCODE" IS '品牌';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."CLASSCODE" IS '课号';
   COMMENT ON COLUMN "C##DEP6"."I_ITM_STOREITEM"."AREACODE" IS '区号';
   COMMENT ON TABLE "C##DEP6"."I_ITM_STOREITEM"  IS '商品门店属性传输接口表';

  CREATE INDEX "C##DEP6"."I_ITM_STOREITEM_ITEM" ON "C##DEP6"."I_ITM_STOREITEM" ("ITEMCODE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "IDX_ITM" ;

CREATE TABLE "C##DEP6"."R_SD_I_ITM_STOREITEM" 
(	"REP_SYNC_ID" NUMBER, 
	"REP_COMMON_ID" NUMBER, 
	"REP_OPERATIONTYPE" CHAR(1 BYTE), 
	"REP_STATUS" CHAR(1 BYTE), 
	"ID" CHAR(12 BYTE), 
	"ITEMCODE" CHAR(7 BYTE), 
	"COUNTERCODE" CHAR(6 BYTE), 
	"PROMOTIONMARK" CHAR(1 BYTE), 
	"DISCOUNTMARK" NUMBER(1,0), 
	"MEMBERPRICE" NUMBER(12,2), 
	"STORETEMPPRICE" NUMBER(12,2), 
	"STORESALESTATE" NUMBER(1,0), 
	"TEMPDISTRIBUTIONMARK" NUMBER(1,0), 
	"MERCHANTCODE" CHAR(6 BYTE), 
	"ITEMNAME" VARCHAR2(50 BYTE), 
	"BARCODE" VARCHAR2(20 BYTE), 
	"ITEMSHORTNAME" VARCHAR2(12 BYTE), 
	"ITEMTYPECODE" CHAR(5 BYTE), 
	"RETAILTYPECODE" CHAR(3 BYTE), 
	"PRODUCTCODE" VARCHAR2(30 BYTE), 
	"UNIT" VARCHAR2(10 BYTE), 
	"RETURNGOODS" NUMBER(1,0), 
	"PRICE" NUMBER(12,2), 
	"ITEMCODETYPE" NUMBER(1,0), 
	"STORECODE" CHAR(5 BYTE), 
	"BRANDCODE" CHAR(6 BYTE), 
	"CLASSCODE" VARCHAR2(8 BYTE), 
	"AREACODE" VARCHAR2(8 BYTE), 
	"REP_OLD_ID" CHAR(12 BYTE), 
	"REP_SERVER_NAME" VARCHAR2(255 BYTE), 
	"REP_PK_CHANGED" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MASTER" ;

   COMMENT ON TABLE "C##DEP6"."R_SD_I_ITM_STOREITEM"  IS '商品门店信息';

  CREATE INDEX "C##DEP6"."I_R_SD_I_ITM_STOREITEM" ON "C##DEP6"."R_SD_I_ITM_STOREITEM" ("REP_SYNC_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "MASTER" ;
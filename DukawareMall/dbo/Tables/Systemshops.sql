CREATE TABLE [dbo].[Systemshops] (
    [ShopId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [Displayname]  VARCHAR (100) NOT NULL,
    [Shopnumber]   VARCHAR (100) NULL,
    [Shopcode]     VARCHAR (40)  NOT NULL,
    [StaffId]      BIGINT        NOT NULL,
    [Phoneid]      BIGINT        NULL,
    [Phonenumber]  VARCHAR (12)  NULL,
    [Emailaddress] VARCHAR (100) NULL,
    [Extra]        VARCHAR (100) NULL,
    [Extra1]       VARCHAR (100) NULL,
    [Extra2]       VARCHAR (100) NULL,
    [Extra3]       VARCHAR (100) NULL,
    [Extra4]       VARCHAR (100) NULL,
    [Extra5]       VARCHAR (100) NULL,
    [Extra6]       VARCHAR (100) NULL,
    [Extra7]       VARCHAR (100) NULL,
    [Extra8]       VARCHAR (100) NULL,
    [Extra9]       VARCHAR (100) NULL,
    [IsDefault]    BIT           DEFAULT ((0)) NOT NULL,
    [Isactive]     BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [Datecreated]  DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ShopId] ASC)
);






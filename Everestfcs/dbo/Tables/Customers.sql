﻿CREATE TABLE [dbo].[Customers] (
    [CustomerId]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [Tenantid]                 BIGINT          NOT NULL,
    [Firstname]                VARCHAR (100)   NULL,
    [Lastname]                 VARCHAR (100)   NULL,
    [Companyname]              VARCHAR (100)   NULL,
    [Emailaddress]             VARCHAR (100)   NOT NULL,
    [Phoneid]                  BIGINT          NOT NULL,
    [Phonenumber]              VARCHAR (12)    NOT NULL,
    [Dob]                      DATETIME        NULL,
    [Gender]                   VARCHAR (15)    NULL,
    [IDNumber]                 VARCHAR (15)    NULL,
    [Designation]              VARCHAR (20)    NULL,
    [Pin]                      VARCHAR (100)   NULL,
    [Pinharsh]                 VARCHAR (100)   NULL,
    [CompanyAddress]           VARCHAR (100)   NULL,
    [ReferenceNumber]          VARCHAR (40)    NULL,
    [CompanyIncorporationDate] DATETIME        NULL,
    [CompanyRegistrationNo]    VARCHAR (30)    NULL,
    [CompanyPIN]               VARCHAR (70)    NULL,
    [CompanyVAT]               VARCHAR (100)   NULL,
    [Contractstartdate]        DATETIME        NULL,
    [Contractenddate]          DATETIME        NULL,
    [StationId]                BIGINT          NOT NULL,
    [CountryId]                BIGINT          NOT NULL,
    [NoOfTransactionPerDay]    INT             DEFAULT ((0)) NOT NULL,
    [AmountPerDay]             DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ConsecutiveTransTimeMin]  INT             DEFAULT ((0)) NOT NULL,
    [IsPortaluser]             BIT             DEFAULT ((0)) NOT NULL,
    [IsActive]                 BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]                BIT             DEFAULT ((0)) NOT NULL,
    [Extra]                    VARCHAR (100)   NULL,
    [Extra1]                   VARCHAR (100)   NULL,
    [Extra2]                   VARCHAR (100)   NULL,
    [Extra3]                   VARCHAR (100)   NULL,
    [Extra4]                   VARCHAR (100)   NULL,
    [Extra5]                   VARCHAR (100)   NULL,
    [Extra6]                   VARCHAR (100)   NULL,
    [Extra7]                   VARCHAR (100)   NULL,
    [Extra8]                   VARCHAR (100)   NULL,
    [Extra9]                   VARCHAR (100)   NULL,
    [Createdby]                BIGINT          NULL,
    [Modifiedby]               BIGINT          NULL,
    [Datecreated]              DATETIME        NULL,
    [Datemodified]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([CustomerId] ASC),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[SystemCountry] ([CountryId]),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[SystemCountry] ([CountryId])
);




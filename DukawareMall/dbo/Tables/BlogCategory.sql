CREATE TABLE [dbo].[BlogCategory] (
    [BlogCategoryId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [BlogCategoryName] VARCHAR (100) NOT NULL,
    [CreatedBy]        BIGINT        NOT NULL,
    [ModifiedBy]       BIGINT        NOT NULL,
    [DateCreated]      DATETIME      NOT NULL,
    [DateModified]     DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([BlogCategoryId] ASC),
    UNIQUE NONCLUSTERED ([BlogCategoryName] ASC)
);


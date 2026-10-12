CREATE SCHEMA History
GO

/****** Object:  Table [dbo].[ApiMapping]    Script Date: 04/17/2017 12:10:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ApiMapping](
	[ApiMapping_ID] [INT] IDENTITY(1,1) NOT NULL,
	[ApiName] [VARCHAR](255) NOT NULL,
	[ApiVersion] [VARCHAR](50) NOT NULL,
	[OperationId] [VARCHAR](255) NOT NULL,
	[Path] [VARCHAR](1000) NOT NULL,
	[Method] [VARCHAR](10) NOT NULL,
	[PartnerNameMicro] [VARCHAR](10) NOT NULL,
	[TargetUrlTemplate] [VARCHAR](2000) NOT NULL,
	[CreatedBy] [VARCHAR](50) NOT NULL,
	[CreatedOn] [DATETIME] NOT NULL,
	[UpdatedBy] [VARCHAR](50) NOT NULL,
	[UpdatedOn] [DATETIME] NOT NULL,
CONSTRAINT [PK_dbo_ApiMapping_ApiMapping_ID] PRIMARY KEY CLUSTERED 
(
	[ApiMapping_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ApiMapping] ADD  CONSTRAINT [DF_ApiMapping_CreatedBy]  DEFAULT (SUSER_SNAME()) FOR [CreatedBy]
GO

ALTER TABLE [dbo].[ApiMapping] ADD  CONSTRAINT [DF_ApiMapping_CreatedOn]  DEFAULT (GETDATE()) FOR [CreatedOn]
GO

ALTER TABLE [dbo].[ApiMapping] ADD  CONSTRAINT [DF_ApiMapping_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[ApiMapping] ADD  CONSTRAINT [DF_ApiMapping_UpdatedOn]  DEFAULT (GETDATE()) FOR [UpdatedOn]
GO

CREATE NONCLUSTERED INDEX [UQ_dbo_ApiMapping_ApiName_ApiVersion_OpreationId_Path_Method_PartnerNameMicro] ON [dbo].[ApiMapping]
(
	[ApiName] ASC,
	[ApiVersion] ASC,
	[OperationId] ASC,
	[Path] ASC,
	[Method] ASC,
	[PartnerNameMicro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

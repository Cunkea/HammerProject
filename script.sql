USE [master]
GO
/****** Object:  Database [Company]    Script Date: 22.5.2018. 11:03:10 ******/
CREATE DATABASE [Company]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Company', FILENAME = N'C:\Users\susen\Company.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Company_log', FILENAME = N'C:\Users\susen\Company_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Company] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Company].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Company] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Company] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Company] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Company] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Company] SET ARITHABORT OFF 
GO
ALTER DATABASE [Company] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Company] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Company] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Company] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Company] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Company] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Company] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Company] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Company] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Company] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Company] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Company] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Company] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Company] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Company] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Company] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Company] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Company] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Company] SET  MULTI_USER 
GO
ALTER DATABASE [Company] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Company] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Company] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Company] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Company] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Company] SET QUERY_STORE = OFF
GO
USE [Company]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Company]
GO
/****** Object:  UserDefinedFunction [dbo].[averageSalary]    Script Date: 22.5.2018. 11:03:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[averageSalary]()
returns decimal
as begin
	declare @average decimal;
	set @average = (select avg(a.salary) as Average from Employee a inner join Department b on a.departmentNo = b.departmentNo WHERE (b.departmentLocation not like 'London' and b.departmentName like 'Development'));
	return (@average);
end;
GO
/****** Object:  Table [dbo].[Department]    Script Date: 22.5.2018. 11:03:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department](
	[departmentNo] [int] IDENTITY(1,1) NOT NULL,
	[departmentName] [varchar](20) NOT NULL,
	[departmentLocation] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[departmentNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[employeeNo] [int] IDENTITY(1,1) NOT NULL,
	[employeeName] [varchar](50) NOT NULL,
	[salary] [int] NOT NULL,
	[departmentNo] [int] NULL,
	[lastModifyDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[employeeNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[countEmployees]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[countEmployees]()
returns table
as
	return
		select a.departmentLocation as "Location", count(distinct b.employeeNo) as "Number"
		from Department a inner join Employee b on (a.departmentNo = b.departmentNo) 
		group by a.departmentLocation
		having count(distinct b.employeeNo) not like 1;
GO
/****** Object:  UserDefinedFunction [dbo].[devEmployees]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[devEmployees]()
returns table
as
return
	select all a.departmentLocation as "Location", count(case a.departmentName when 'Development' then 1 else null end) as "Number"
	from Department a left join Employee b on (a.departmentNo = b.departmentNo)
	group by a.departmentLocation
GO
/****** Object:  View [dbo].[vwDepartment]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwDepartment] as
select departmentNo, departmentName + ' ' + departmentLocation as departmentDescription
from Department;
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([departmentNo])
REFERENCES [dbo].[Department] ([departmentNo])
GO
/****** Object:  StoredProcedure [dbo].[spIncreaseSalary]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spIncreaseSalary]  
    @id int,   
    @perc int   
as
    update Employee
	set salary = salary * (1 + @perc/100.00)
	where employeeNo = @id 
GO
/****** Object:  Trigger [dbo].[setDate]    Script Date: 22.5.2018. 11:03:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[setDate]
on [dbo].[Employee]
after insert, update
as
update dbo.Employee
set lastModifyDate = getdate()
where employeeNo in (select distinct employeeNo from inserted)
GO
ALTER TABLE [dbo].[Employee] ENABLE TRIGGER [setDate]
GO
USE [master]
GO
ALTER DATABASE [Company] SET  READ_WRITE 
GO

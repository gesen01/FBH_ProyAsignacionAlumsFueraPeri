SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
--EXEC spCENumeroPeriodos 'FBH',4,N'2022-2023',N'ARTEM1PREI',N'A'
IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='P' AND NAME='spCENumeroPeriodos')
DROP PROCEDURE spCENumeroPeriodos
GO
CREATE PROCEDURE spCENumeroPeriodos --SP para msostrar solo los Periodos de la asignación que faltan por calificar en Calificación, Asistencia y Cierre Periodo --RG 13-Octubre-2014
         
  @Empresa       varchar(5),
  @Sucursal      int,
  @CicloEscolar  varchar(20),
  @Materia       varchar(20),
  @Grupo	     varchar(1)
		           
--//WITH ENCRYPTION
AS BEGIN  
  DECLARE @DurPeriodos int
		, @PeriodoInicio int
		, @Contador int  
		, @MovTipo VARCHAR(25)
  DECLARE @Tabla AS Table (Periodo int) 

  SELECT @MovTipo=a.Mov
  FROM CE a 
  WHERE Empresa = @Empresa 
  AND Sucursal = @Sucursal 
  AND CicloEscolar = @CicloEscolar 
  AND Materia = @Materia AND a.Grupo = @Grupo

  SELECT @DurPeriodos = ISNULL(DurPeriodos,0) FROM CEAsignacionProgramaPeriodo WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND CicloEscolar = @CicloEscolar AND Materia = @Materia AND Grupo = @Grupo
  
  SELECT @PeriodoInicio = ISNULL(Periodo,0) FROM CEAsignacionProgramaPeriodo WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND CicloEscolar = @CicloEscolar AND Materia = @Materia AND Grupo = @Grupo  
  
  SELECT @Contador = @PeriodoInicio
  
  WHILE  @Contador<=@DurPeriodos
  BEGIN
    INSERT @Tabla(Periodo)
    SELECT @Contador
    SET @Contador = @Contador + 1
  END 
  
 IF @MovTipo NOT IN ('Ajuste Calificacion','Calificacion exten')
  DELETE FROM @Tabla WHERE Periodo IN (SELECT ISNULL(PeriodoAsig,0) FROM CE a JOIN MovTipo b ON a.Mov = b.Mov AND Modulo = 'CE' AND Clave IN ('CE.CP') WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND CicloEscolar = @CicloEscolar AND Materia = @Materia AND a.Grupo = @Grupo AND Estatus = 'CONCLUIDO')
   
  SELECT * FROM @Tabla
END
GO
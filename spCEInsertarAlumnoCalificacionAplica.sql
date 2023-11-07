SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='P' AND NAME='spCEInsertarAlumnoCalificacionAplica')
DROP PROCEDURE spCEInsertarAlumnoCalificacionAplica
GO
CREATE PROCEDURE spCEInsertarAlumnoCalificacionAplica		
  @Empresa         varchar(5),
  @CicloEscolar    varchar(20),
  @Estacion        int,
  @Materia         varchar(20),
  @SubMateria      varchar(20),
  @Grupo           varchar(1),
  @Sucursal        int,
  @Periodo         varchar(10),
  @Mov             varchar(20),
  @Concepto		   varchar(50)	-- RPA (19/06/14): Para que muestre filtrado por Concepto calificación
  

--//WITH ENCRYPTION
AS BEGIN
DECLARE 
  @MovTipo     varchar(20),
  @Tipo        varchar(20)
  
  SELECT @MovTipo = Clave FROM MovTipo WHERE Mov = @Mov AND Modulo = 'CE'
  
  IF @MovTipo = 'CE.AAS' --CE.ACL
  BEGIN -- RPA (19/06/14): Se dividió para que muestre diferente información si es Ajuste Asistencia o Ajuste Calificación
	SELECT @Tipo = 'Asistencia'
  	  IF EXISTS (SELECT * FROM CEAlumnoCalificacionAplica WHERE Estacion = @Estacion)
	  DELETE CEAlumnoCalificacionAplica WHERE Estacion = @Estacion

	  INSERT CEAlumnoCalificacionAplica(Estacion, Empresa,   AplicaRenglon, Aplica, AplicaID, CicloEscolar,   Programa,   SubPrograma,   Materia,   Alumno,   PlanEstudios,   Grupo,   NivelAcademico,   Sucursal,   Periodo,   ConceptoCalificacion,   Consecutivo,   FechaEmision,   Asistencia) -- RPA (19/06/14): Se agrega para traer asistencia y fecha
	  SELECT                           @Estacion, a.Empresa, a.Renglon,     a.Mov,  a.MovID,  a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Asistencia -- RPA (19/06/14): Se agrega para traer asistencia y fecha
		FROM CEAplica2 a 
		JOIN CE c ON a.Mov = c.Mov AND a.MovID = c.MovID -- RPA (19/06/14): Se agrega para traer asistencia
		JOIN CED d ON c.ID = d.ID AND a.Renglon = d.Renglon -- RPA (19/06/14): Se agrega para traer asistencia
		JOIN MovTipo mt ON a.Mov = mt.Mov AND mt.Modulo = 'CE' -- RPA (19/06/14): Se agrega para traer solo asistencia o ajuste asistencia
	   WHERE a.CicloEscolar = @CicloEscolar
		 AND a.Materia = @Materia
		 AND a.SubMateria = @SubMateria
		 AND a.Grupo = @Grupo -- RPA (19/06/14): Para que muestre filtrado por Grupo Forzoso
		 AND a.Empresa = @Empresa
		 AND a.Sucursal = @Sucursal
		 AND a.Periodo = @Periodo
		 AND a.ConceptoCalificacion = ISNULL(NULLIF(@Concepto,''),a.ConceptoCalificacion) -- RPA (19/06/14): Para que muestre filtrado por Concepto Calificación
	     AND mt.Clave IN('CE.AS','CE.AAS') -- RPA (19/06/14): Se agrega para traer solo asistencia o ajuste asistencia
	  GROUP BY a.Empresa, a.Renglon, a.Mov, a.MovID, a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Asistencia -- RPA (19/06/14): Se agrega para traer asistencia y fecha
  END
   
  IF @MovTipo = 'CE.ACL'  -- RPA (19/06/14): Se dividió para que muestre diferente información si es Ajuste Asistencia o Ajuste Calificación
  BEGIN
     SELECT @Tipo = 'Calificacion'
	 IF EXISTS (SELECT * FROM CEAlumnoCalificacionAplica WHERE Estacion = @Estacion)
	 DELETE CEAlumnoCalificacionAplica WHERE Estacion = @Estacion

	  INSERT CEAlumnoCalificacionAplica(Estacion, Empresa,   AplicaRenglon, Aplica, AplicaID, CicloEscolar,   Programa,   SubPrograma,   Materia,   Alumno,   PlanEstudios,   Grupo,   NivelAcademico,   Sucursal,   Periodo,   ConceptoCalificacion,   Consecutivo,   FechaEmision,   Calificacion,   CalificacionEval) -- RPA (19/06/14): Se agrega para traer calificaciones y fecha
	  SELECT                           @Estacion, a.Empresa, a.Renglon,     a.Mov,  a.MovID,  a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Calificacion, d.CalificacionEval -- RPA (19/06/14): Se agrega para traer calificaciones y fecha
		FROM CEAplica2 a 
		JOIN CE c ON a.Mov = c.Mov AND a.MovID = c.MovID -- RPA (19/06/14): Se agrega para traer calificaciones
		JOIN CED d ON c.ID = d.ID AND a.Renglon = d.Renglon -- RPA (19/06/14): Se agrega para traer calificaciones
	   	JOIN MovTipo mt ON a.Mov = mt.Mov AND mt.Modulo = 'CE' -- RPA (19/06/14): Se agrega para traer solo calificación o ajuste calificación
	   WHERE a.CicloEscolar = @CicloEscolar
		 AND a.Materia = @Materia
		 --AND a.SubMateria = @SubMateria
		 AND a.Grupo = @Grupo -- RPA (19/06/14): Para que muestre filtrado por Grupo Forzoso
		 AND a.Empresa = @Empresa
		 AND a.Sucursal = @Sucursal
		 AND a.Periodo = @Periodo
		 --AND a.ConceptoCalificacion = @Concepto -- RPA (19/06/14): Para que muestre filtrado por Concepto Calificación Forzoso
	     AND mt.Clave IN('CE.CL','CE.ACL')-- RPA (19/06/14): Se agrega para traer solo calificación o ajuste calificación
	  GROUP BY a.Empresa, a.Renglon, a.Mov, a.MovID, a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Calificacion, d.CalificacionEval -- RPA (19/06/14): Se agrega para traer calificaciones y fecha
  END

  IF @MovTipo IN ('CE.ACP','CE.RCP')  
  BEGIN
     SELECT @Tipo = 'Cierre de Periodo'
	 IF EXISTS (SELECT * FROM CEAlumnoCalificacionAplica WHERE Estacion = @Estacion)
	 DELETE CEAlumnoCalificacionAplica WHERE Estacion = @Estacion

	  INSERT CEAlumnoCalificacionAplica(Estacion, Empresa,   AplicaRenglon, Aplica, AplicaID, CicloEscolar,   Programa,   SubPrograma,   Materia,   Alumno,   PlanEstudios,   Grupo,   NivelAcademico,   Sucursal,   Periodo,   ConceptoCalificacion,   Consecutivo,   FechaEmision,   Calificacion,   CalificacionEval) 
	  SELECT                           @Estacion, a.Empresa, a.Renglon,     a.Mov,  a.MovID,  a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Calificacion, d.CalificacionEval 
		FROM CEAplica2 a 
		JOIN CE c ON a.Mov = c.Mov AND a.MovID = c.MovID 
		JOIN CED d ON c.ID = d.ID AND a.Renglon = d.Renglon 
	   	JOIN MovTipo mt ON a.Mov = mt.Mov AND mt.Modulo = 'CE' 
	   WHERE a.CicloEscolar = @CicloEscolar
		 AND a.Materia = @Materia
		 AND a.SubMateria = @SubMateria
		 AND a.Grupo = @Grupo 
		 AND a.Empresa = @Empresa
		 AND a.Sucursal = @Sucursal
		 AND a.Periodo = @Periodo
		 --AND a.ConceptoCalificacion = @Concepto
	     AND mt.Clave IN('CE.CP','CE.ACP','CE.RCP')
	     AND c.Estatus  = 'CONCLUIDO'
         AND d.EstatusD = 'CONCLUIDO'
	  GROUP BY a.Empresa, a.Renglon, a.Mov, a.MovID, a.CicloEscolar, a.Programa, a.SubPrograma, a.Materia, a.Alumno, a.PlanEstudios, a.Grupo, a.NivelAcademico, a.Sucursal, a.Periodo, a.ConceptoCalificacion, a.Consecutivo, a.FechaEmision, d.Calificacion, d.CalificacionEval 
  END
END

GO
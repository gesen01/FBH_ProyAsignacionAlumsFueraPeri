SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='v' AND NAME='CECalificacionPeriodo')
DROP VIEW CECalificacionPeriodo
GO
CREATE VIEW CECalificacionPeriodo
WITH ENCRYPTION
AS
SELECT c.Materia,c.Empresa,d.Alumno,c.CicloEscolar,d.NivelAcademico,d.Programa
,d.PlanEstudios,ISNULL(d.SubPrograma,'')SubPrograma,c.Grupo,d.CalificacionEval Calificacion 
,d.Calificacion CalificacionN,c.Periodoasig,c.Mov+c.MovID Consecutivo
FROM CE c JOIN CED d ON c.ID = d.ID
JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo ='CE'
WHERE mt.Clave IN ('CE.CL','CE.ACL','CE.RCP')--('CE.CP','CE.ACP','CE.RCP')
AND c.Estatus ='CONCLUIDO'
AND d.EstatusD = 'CONCLUIDO'
GO
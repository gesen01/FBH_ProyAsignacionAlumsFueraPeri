SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='P' AND NAME='spCEVerificar')
DROP PROCEDURE spCEVerificar
GO
CREATE PROCEDURE spCEVerificar
@ID               	int,
@Accion			    char(20),
@Empresa          	char(5),
@Usuario				char(10),
@Modulo	      		char(5),
@Mov              	varchar(20),
@MovID			    varchar(20),
@MovTipo	      		char(20),
@SubMovTipo	      	char(20),
@MovMoneda			char(10),
@MovTipoCambio		float,
@FechaEmision		    datetime,
@Estatus				char(15),
@EstatusNuevo		    char(15),
@Alumno			    varchar(20),
@Condicion			varchar(50),
@Vencimiento		    datetime,
@Conexion				bit,
@SincroFinal		    bit,
@Sucursal				int,
@Autorizacion		    varchar(10)  OUTPUT,
@Autorizar            bit          OUTPUT,
@Ok               	int          OUTPUT,
@OkRef            	varchar(255) OUTPUT

AS BEGIN
DECLARE
@CicloEscolar           varchar(20),
@NivelAcademico         varchar(20),
@Programa               varchar(20),
@SubPrograma            varchar(20),
@SubProgramaD           varchar(20),
@PlanEstudios           varchar(20),
@PlanEstudiosD          varchar(20),
@Matricula              varchar(20),
@Grupo                  varchar(20),
@FechaNacimiento        datetime,
@InicioCiclo            datetime,
@Edad                   int,
@InicioAdmicion         datetime,
@FinAdmicion            datetime,
@Examen                 varchar(50),
@CalifMinima            float,
@Mensaje                int,
@Renglon                float,
@Materia                varchar(20),
@MateriaEmp             varchar(20),
@MateriaD               varchar(20),
@SubMateria             varchar(20),
@MateriaPre             varchar(20),
@GrupoD                 varchar(20),
@Nivel                  varchar(20),
@NivelEnc               varchar(20),
@NivelMateria           bit,
@Sesion                 varchar(20),
@Ficha                  varchar(20),
@CalificacionE          varchar(20),
@Calificacion           varchar(20),
@CalificacionEval       varchar(20),
@CalifRecuperacion      varchar(20),
@EstatusD               varchar(20),
@Sobrecupo		        bit,
@CfgExamenAdmicion      bit,
@MatriculaIDAlumno      bit,
@BloquearFaltaDocs      bit,
@BloquearAdeudosMov     bit,
@DocCompleta            bit,
@TotalCreditos          float,
@TotalCreditosAnt       float,
@MaxCreditos            float,
@MinCreditos            float,
@MaxMaterias            int,
@MinMaterias            int,
@Disponible             int,
@AlumnoD                varchar(20),
@Aplica                 varchar(20),
@AplicaID               varchar(20),
@AplicaRenglon          float	,
@AlumnoCambioD	        varchar(20),
@TablaEvaluacion  	    varchar(20),
@TablaEvaluacionCal	    varchar(20),
@MateriaA               varchar(20),
@Fecha                  datetime,
@HDesde                 varchar(20),
@HHasta                 varchar(20),
@PeriodoAsignacion      int,
@ConceptoCalificacion   varchar(50),
@NumCreditos            float,
@NumMaterias            int,
@FormaMateria           varchar(20),
@ProgramaActual         varchar(20),
@NivelAcademicoActual   varchar(20),
@EstatusAlumno          varchar(15),
@SinOrdenNivel          bit,
@OrdenNivelAcademico    int,
@ProgramaNuevo          varchar(20),
@NivelAcademicoNuevo    varchar(20),
@PlanEstudiosActual     varchar(10),
@CicloEscolarActual     varchar(20),
@SinOrdenPrograma       bit,
@OrdenPrograma          int,
@CalifMinimaPrograma    float,
@MateriasRepMax         int,
@VecesRepMax            int,
@CalificacionPlan       float,
@MateriasRep            int,
@CalificacionReconocida varchar(10),
@CalifMinimaMateria     bit,
@CalificacionMateria    varchar(20), 
@Origen                 varchar(20),
@OrigenID               varchar(20),
@Clave                  varchar(20),
@MovSolicitud           varchar(20),
@Escuela                varchar(10),
@TipoCalificacion       varchar(20),
@Beca                   varchar(50),
@CalificacionProm       varchar(20), 
@PromedioMinimo         float,
@NoMaterias             int,
@AplicaTodosProgramas   bit,
@CantidadMaxBeca        int,
@NoCreditos             float,
@CicloEscolarAnterior   varchar(20),
@NoReprobado            int,
@CantidadBeca           int,
@CantidadMateria        int,
@Creditos               float,
@Reprobados             int,
@MultiplesBecas         bit,
@ReprobadosAcum         int,
@TipoReprobado          varchar(20),
@NuevoIngreso           bit,
@FamEmpleado            bit,
@ServicioSocial         bit,
@ServicioBecario        bit,
@Ofertante              varchar(10),
@ProyectoSS             varchar(20),
@ProyectoSB             varchar(20),
@FechaInicio            datetime,
@FechaFin               datetime,
@FechaExamen            datetime,
@HorarioDesde           varchar(10),
@HorarioHasta           varchar(10),
@Espacio                varchar(20),
@HorasServicio          int,
@BloquearAdeudos        bit,
@MontoBloqueo			float,
@FacturaMultiple        bit,
@CteAlumno              varchar(10),
@PorcDescBeca           float,
@RenovarBecaSinCubrirSB bit,
@SumaBeca               float,
@SumaBecaActiva         float,
@CreditosCursando       float,
@MateriasCursando       int,
@MinCiclos              int,
@Ciclos                 int,
@IDOrigen               int,
@Horas                  int,
@ValidaCreditos         bit,
@ValidaMaterias         bit,
@CambioMatricula        bit ,
@CambioMatriculaCicloEscolar  bit,
@CambioMatriculaPrograma      bit,
@CambioMatriculaNivel         bit,
@MatriculaAlumno        varchar(20),
@CicloEscolarAlumno     varchar(20),
@ProgramaAlumno         varchar(10),
@NivelAlumno            varchar(20),
@MatriculaD             varchar(20),
@CicloEscolarD          varchar(20),
@ProgramaD              varchar(10),
@NivelAcademicoD        varchar(20),
@MovTipoOrigen          varchar(20),
@DefPersonal            varchar(10),
@CreditosElectivos      float,
@MateriasElectivas      int,
@TotalMaterias          int,
@SumaCreditos           float,
@CfgCreditos            float,
@Asistencia             varchar(10),
@CreditosPre            float,
@SumaCreditos2          float,
@FormaTitulacion        varchar(50),
@PermiteElectivas       bit ,
@AlumnoOrigen           varchar(20),
@SucursalCambio         int,
@SucursalAlumno         int,
@CambioMatriculaPlantel bit,
@AsignacionD            int,
@ToleranciaRedondeo     float,
@SaldoCliente           float,
@FormaCalificacion      varchar(20),
@AlumnosInscritosPermitidos int
DECLARE @Tabla Table
(Materia         varchar(20),
Fecha           datetime,
HoraInicio      varchar(20),
HoraFin         varchar(20)
)
DECLARE @Tabla2 Table
(Materia         varchar(20),
Fecha           datetime,
HoraInicio      varchar(20),
HoraFin         varchar(20)
)
DECLARE @Tabla3 Table
(Materia         varchar(20),
Creditos        float,
Periodo         int
)
SET DATEFIRST 1
SELECT @ToleranciaRedondeo = ec.CxcAutoAjusteMov
FROM EmpresaCfg ec
WHERE ec.Empresa = @Empresa
SELECT  @CicloEscolar           = CicloEscolar,
@NivelAcademico         = NivelAcademico ,
@Programa               = Programa,
@SubPrograma            = SubPrograma,
@PlanEstudios           = PlanEstudios,
@Matricula              = Matricula,
@Grupo                  = Grupo,
@Mensaje                = Mensaje,
@Materia                = Materia,
@PeriodoAsignacion      = PeriodoAsig,
@ConceptoCalificacion   = ConceptoCalificacion,
@NumCreditos            = NumCreditos,
@NumMaterias            = NumMaterias,
@SubMateria             = SubMateria,
@NivelEnc               = Nivel,
@Origen                 = Origen,
@OrigenID               = OrigenID,
@Escuela                = Escuela,
@TipoCalificacion       = TipoCalificacion,
@CalificacionProm       = CalificacionProm,
@Ofertante              = Ofertante,
@ProyectoSS             = ProyectoSS,
@ProyectoSB             = ProyectoSB,
@FechaExamen            = Fecha,
@HorarioDesde           = HorarioDesde,
@HorarioHasta           = HorarioHasta,
@Espacio                = Espacio,
@Horas                  = Horas,
@FormaTitulacion        = FormaTitulacion,
@CalificacionE          = CalificacionEval 
FROM  CE WHERE ID = @ID
SELECT @MatriculaIDAlumno = MatriculaIDAlumno, @CambioMatricula = CambioMatricula, @CambioMatriculaCicloEscolar=CambioMatriculaCicloEscolar,@CambioMatriculaPrograma=CambioMatriculaPrograma, @CambioMatriculaNivel =CambioMatriculaNivel,@CambioMatriculaPlantel = CambioMatriculaPlantel
FROM EmpresaCfgCE
WHERE Empresa = @Empresa
SELECT @CfgExamenAdmicion = ExamenAdmision,
@PermiteElectivas  = PermiteElectivasOtrosProgramas,
@MultiplesBecas    = MultiplesBecas,
@BloquearFaltaDocs = BloquearFaltaDocs,
@ServicioSocial    = ServicioSocial,
@BloquearAdeudos   = BloquearAdeudos,
@CfgCreditos       = Creditos,
@ServicioBecario   = ServicioBecario
FROM CEPlanEstudios
WHERE Empresa      = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa     = @Programa
SELECT @BloquearAdeudosMov = BloquearAdeudos, @MontoBloqueo = CEMontoAdeudos FROM MovTipo WHERE Mov = @Mov AND Clave = @MovTipo AND Modulo = 'CE'
SELECT @MovTipoOrigen = Clave FROM MovTipo WHERE Mov = @Origen AND Clave = @MovTipo AND Modulo = 'CE'
SELECT @FechaNacimiento = FechaNacimiento, @DocCompleta = DocumentacionCompleta,@EstatusAlumno=Estatus,@FacturaMultiple = FacturaMultiple,@CteAlumno =FacturarCte ,@MatriculaAlumno =Matricula,@CicloEscolarAlumno = CicloEscolar,@ProgramaAlumno = Programa ,@NivelAlumno = NivelAcademico,@SucursalAlumno =Sucursal
FROM CEAlumno WHERE Alumno = @Alumno
SELECT @Edad = EdadMinima,@MaxCreditos = LimiteCreditosMax,@MinCreditos = LimiteCreditosMin,@MaxMaterias = LimiteMateriasMax,@MinMaterias = LimiteMateriasMin  FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios AND Programa = @Programa AND Empresa = @Empresa
SELECT @DefPersonal = DefPersonal FROM Usuario WHERE Usuario = @Usuario
IF @Accion = 'CANCELAR' AND @EstatusNuevo = 'CANCELADO'
BEGIN
IF @Conexion = 0
IF EXISTS (SELECT * FROM MovFlujo WHERE Cancelado = 0 AND Empresa = @Empresa AND DModulo = @Modulo AND DID = @ID AND OModulo <> DModulo)
SELECT @Ok = 60070 
IF EXISTS (SELECT c.* FROM CE c JOIN MovTipo m ON c.Mov = m.Mov WHERE c.Origen = @Mov AND c.OrigenID = @MovID AND c.OrigenTipo = @Modulo AND c.Empresa = @Empresa AND c.Estatus IN ('PENDIENTE', 'CONCLUIDO') AND m.Clave <> 'CE.BI' )AND @MovTipo NOT IN ('CE.S','CE.IE') 
SELECT @Ok = 30151 
END
IF @Ok IS NULL
BEGIN
IF @Accion IN ('AFECTAR','GENERAR')
BEGIN
IF (SELECT CEAfectarMovControlFechas FROM Usuario WHERE Usuario = @Usuario) <> 1
BEGIN
DECLARE @FechaInicioCC datetime, @FechaFinCC datetime
IF @MovTipo IN ('CE.ASI','CE.BM','CE.B','CE.RM','CE.I','CE.IE','CE.NI','CE.CC') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
SELECT @FechaInicioCC = a.FechaInicio, @FechaFinCC = a.FechaFin,@OkRef = a.Mensaje
FROM  CECicloEscolarControlFechas a
JOIN  MovTipo b ON b.Modulo = 'CE' AND b.Mov = a.Mov
WHERE  a.Empresa      = @Empresa
AND  a.CicloEscolar = @CicloEscolar
AND  b.Clave = @MovTipo
IF GETDATE() < @FechaInicioCC OR GETDATE() > @FechaFinCC
SELECT @OK = 1000197, @OkRef = @OkRef 
END
IF @MovTipo IN ('CE.AAS','CE.ACL','CE.AS','CE.CL','CE.CP') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF @TipoCalificacion = 'Periodo'
SELECT @FechaInicioCC = a.FechaInicio,
@FechaFinCC = a.FechaFin,
@OkRef = a.Mensaje
FROM CECicloEscolarControlFechas a
JOIN MovTipo b ON b.Modulo = 'CE' AND b.Mov = a.Mov
WHERE a.Empresa      = @Empresa
AND a.CicloEscolar = @CicloEscolar
AND b.Clave        = @MovTipo
AND a.Periodo      = @PeriodoAsignacion
ELSE
SELECT @FechaInicioCC = a.FechaInicio,
@FechaFinCC = a.FechaFin,
@OkRef = a.Mensaje
FROM CECicloEscolarControlFechas a
JOIN MovTipo b ON b.Modulo = 'CE' AND b.Mov = a.Mov
WHERE a.Empresa      = @Empresa
AND a.CicloEscolar = @CicloEscolar
AND b.Clave        = @MovTipo
AND a.Periodo IS NULL
IF GETDATE() < @FechaInicioCC OR GETDATE() > @FechaFinCC
SELECT @OK = 1000197, @OkRef = @OkRef 
END
END
IF @MovTipo NOT IN ('CE.ASI','CE.CL','CE.ACL','CE.AS','CE.AAS','CE.C','CE.CP','CE.EP','CE.T','CE.RT','CE.CT','CE.ACP','CE.RCP') AND @Origen IS NOT NULL
BEGIN
SELECT @IDOrigen = ID FROM CE WHERE Mov = @Origen AND MovID = @OrigenID AND Empresa = @Empresa
SELECT @AlumnoOrigen = Alumno
FROM CE
WHERE ID = @IDOrigen
IF @Alumno <> @AlumnoOrigen
SELECT @Ok = 1000172 
END
IF @MovTipo = 'CE.RA' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.AC')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CEAcreditacion FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.EXI' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave IN('CE.EXI','CE.IT'))AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CEInter  FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)+' o '+(SELECT CEExtInter  FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.SPSS' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SS')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESerSocial FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.SPSB' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SBE')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESerBecario FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.ASS' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SPSS')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESolProySS FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.ASB' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SPSB')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESolProySB FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.HSS' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.ASS')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT  CEAsigSS FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.HSB' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.ASB')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT  CEAsigSB FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.ACSS' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.ASS')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT  CEHorasSS FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.ACSB' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.ASB')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT  CEHorasSB FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.LSS' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SS')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESerSocial FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.LSB' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SBE')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESerBecario FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.RT' AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.T')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT  CETesis FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.CT'AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.T')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CETesis FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF @MovTipo = 'CE.BR'AND @Origen NOT IN (SELECT Mov FROM MovTipo WHERE Modulo = 'CE' AND Clave ='CE.SB')AND @EstatusNuevo NOT IN ('CANCELADO','SINAFECTAR')
SELECT @OK = 1000155,@OkRef =  @OkRef+ ' '+(SELECT CESolBeca FROM EmpresaCfgMovCE WHERE Empresa = @Empresa)
IF NOT EXISTS (SELECT Alumno FROM CEAlumno WHERE Alumno = @Alumno)AND @MovTipo NOT IN('CE.ASI','CE.AS','CE.AAS','CE.CL','CE.ACL','CE.CES','CE.C','CE.CP','CE.EP','CE.T','CE.RT','CE.CT','CE.ACP','CE.RCP')
SELECT @Ok = 1000001
IF  (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno) NOT IN ('Alta','BajaTemporal') AND @MovTipo  IN('CE.AC','CE.ACSS','CE.ASS','CE.BA','CE.BI','CE.BT','CE.BM','CE.CC','CE.RCC','CE.EXT','CE.G','CE.HSS','CE.LSS','CE.PRM','CE.RA','CE.RI','CE.RM','CE.SI','CE.SPSS','CE.SS','CE.ACSB','CE.ASB','CE.HSB','CE.LSB','CE.SPSB','CE.SBE')
SELECT @Ok = 1000012
IF  (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno)NOT IN ('Alta','Intercambio') AND @MovTipo  IN('CE.EXI','CE.IT','CE.RE')
SELECT @Ok = 1000012
IF @BloquearAdeudos= 1 AND @BloquearAdeudosMov= 1 AND @Autorizacion IS NULL AND @Alumno IS NOT NULL AND @MovTipo NOT IN('CE.ASI','CE.AS','CE.AAS','CE.CL','CE.ACL','CE.CES','CE.C','CE.CP','CE.EP','CE.T','CE.RT','CE.CT','CE.ACP','CE.RCP','CE.HIS')
BEGIN
SELECT @FacturaMultiple = FacturaMultiple FROM CEAlumno WHERE Alumno = @Alumno
SET @CteAlumno = NULL
IF @FacturaMultiple = 0
SELECT @CteAlumno =FacturarCte
FROM CEAlumno
WHERE Alumno = @Alumno
SELECT @SaldoCliente = SUM(Saldo)
FROM CxcInfo
WHERE Cliente = @CteAlumno
AND DiasMoratorios > CASE WHEN Saldo > 0 THEN 0 ELSE -1 END
IF  @FacturaMultiple = 0 AND @Autorizacion IS NULL AND ISNULL(@SaldoCliente,0.0) > @ToleranciaRedondeo AND ISNULL(@SaldoCliente,0.0)>ISNULL(@MontoBloqueo, 0.0)
SELECT @Ok = 1000129 ,@OkRef = @OkRef+ ' ('+@CteAlumno+')'
IF @FacturaMultiple = 1
BEGIN
DECLARE crCuotasMovAlumCxc CURSOR FOR
SELECT Cliente
FROM CEAlumnoCxc
WHERE Alumno =@Alumno
OPEN crCuotasMovAlumCxc
FETCH NEXT FROM crCuotasMovAlumCxc INTO @CteAlumno
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
SELECT @SaldoCliente = SUM(Saldo) FROM CxcInfo WHERE Cliente = @CteAlumno AND DiasMoratorios > CASE WHEN Saldo > 0 THEN 0 ELSE -1 END
IF @BloquearAdeudos= 1 AND @BloquearAdeudosMov= 1 AND @FacturaMultiple = 1 AND @Autorizacion IS NULL AND ISNULL(@SaldoCliente,0.0) > @ToleranciaRedondeo AND ISNULL(@SaldoCliente,0.0)>ISNULL(@MontoBloqueo, 0.0) 
SELECT @Ok = 1000129 ,@OkRef = @OkRef+ ' ('+@CteAlumno+')'
FETCH NEXT FROM crCuotasMovAlumCxc INTO @CteAlumno
END
CLOSE crCuotasMovAlumCxc
DEALLOCATE crCuotasMovAlumCxc
END
IF @Ok = 1000129 SELECT @Autorizar = 1
END
IF @MovTipo IN ('CE.S','CE.A','CE.NI','CE.AC') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios)AND @PlanEstudios IS NOT NULL
SELECT @Ok = 1000007
IF NOT EXISTS (SELECT SubPrograma FROM CESubPrograma WHERE SubPrograma = @SubPrograma) AND @SubPrograma  NOT IN (NULL,'')
SELECT @Ok = 1000006
IF NOT EXISTS (SELECT Programa FROM CEPrograma WHERE Programa = @Programa )AND @Programa IS NOT NULL
SELECT @Ok = 1000005
IF NOT EXISTS (SELECT NivelAcademico FROM CENivelAcademico WHERE NivelAcademico = @NivelAcademico)AND @NivelAcademico IS NOT NULL
SELECT @Ok = 1000003
IF NOT EXISTS (SELECT CicloEscolar FROM CECicloEscolar WHERE CicloEscolar = @CicloEscolar ) AND @CicloEscolar IS NOT NULL
SELECT @Ok = 1000002
END
IF @MovTipo IN ('CE.A')AND @EstatusNuevo IN('PENDIENTE','BORRADOR')
BEGIN
SELECT @InicioCiclo = InicioCiclo,
@InicioAdmicion = InicioAdmision,
@FinAdmicion = FinAdmision
FROM CECicloEscolar
WHERE CicloEscolar = @CicloEscolar
AND Empresa = @Empresa
IF @FechaEmision NOT BETWEEN @InicioAdmicion AND @FinAdmicion
SELECT @Ok = 1000018
IF (SELECT DATEDIFF(YEAR,@FechaNacimiento,@InicioCiclo))< @Edad
SELECT @Ok = 1000017
IF NOT EXISTS (SELECT SubPrograma FROM CESubPrograma WHERE SubPrograma = @SubPrograma AND Programa = @Programa AND Empresa = @Empresa ) AND @SubPrograma NOT IN (NULL,'')
SELECT @Ok = 1000015
IF NOT EXISTS (SELECT * FROM CEPrograma WHERE NivelAcademico = @NivelAcademico AND Programa = @Programa AND Empresa = @Empresa  )
SELECT @Ok = 1000013
IF (SELECT Estatus  FROM CEAlumno WHERE Alumno = @Alumno) NOT IN ('Aspirante','Baja')
SELECT @Ok = 1000011
IF NOT EXISTS (SELECT Ficha FROM CED WHERE ID = @ID)
SELECT @Ok = 1000128
END
IF @MovTipo IN ('CE.AS') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF DATEDIFF(dd,GETDATE(),@FechaEmision) > 0
SELECT @Ok = 1000211
IF @Ok IS NULL AND DATEDIFF(dd,GETDATE(),@FechaEmision) = 0
AND EXISTS(SELECT * FROM CE WHERE Mov = @Mov AND Estatus = 'CONCLUIDO'
AND CicloEscolar = @CicloEscolar AND Materia = @Materia
AND Grupo = @Grupo AND TipoCalificacion = @TipoCalificacion
AND PeriodoAsig = @PeriodoAsignacion AND DATEDIFF(dd,FechaEmision,@FechaEmision) = 0)
SELECT @Ok = 1000212
IF @Ok IS NULL AND EXISTS (SELECT * FROM CEVacaciones WHERE Empresa = @Empresa
AND CicloEscolar = @CicloEscolar AND @FechaEmision BETWEEN InicioVacaciones AND FinVacaciones)
SELECT @Ok = 1000213
IF @Ok IS NULL AND @FechaEmision IN (select Fecha from DiaFestivo where EsLaborable = 0)
SELECT @Ok = 1000213
END
IF @MovTipo IN ('CE.BI') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus = 'PENDIENTE' AND m.Clave = 'CE.RM' AND d.EstatusD ='Cursando')SELECT @Ok = 1000032
IF (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno)='Baja'
SELECT @OK = 1000053
IF (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno) NOT IN ('Alta','BajaTemporal')
SELECT @OK = 1000054
END
IF @MovTipo IN ('CE.BA') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno)='Baja'
SELECT @OK = 1000053
IF (SELECT Estatus FROM CEAlumno WHERE Alumno = @Alumno) NOT IN ('Alta','BajaTemporal')
SELECT @OK = 1000054
IF NOT EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus = 'PENDIENTE' AND m.Clave = 'CE.RM' AND d.EstatusD ='Cursando')
SELECT @Ok = 1000033
END
IF @MovTipo IN ('CE.NI','CE.I','CE.PRM','CE.RM','CE.IE','CE.CEX') AND @EstatusNuevo IN('PENDIENTE','CONFIRMAR')
BEGIN
IF  @BloquearFaltaDocs = 1 AND @DocCompleta = 0
SELECT @Ok = 1000030
IF (SELECT DATEDIFF(YEAR,@FechaNacimiento,@InicioCiclo)) < @Edad
SELECT @Ok = 1000017
IF ISNULL(@Matricula,'') = ''
SELECT @Ok = 1000031
IF @MovTipo IN ('CE.PRM','CE.RM') AND NOT EXISTS (SELECT Matricula FROM CEAlumno WHERE Alumno = @Alumno AND Matricula = @Matricula)
SELECT @Ok = 1000010
IF @MatriculaIDAlumno = 1  AND @Alumno <> @Matricula
SELECT @Ok = 1000022
IF @PlanEstudios IS NOT NULL
AND NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios AND Programa = @Programa AND Estatus = 'Activo')
SELECT @Ok = 1000024
IF @PlanEstudios IS NOT NULL
AND NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios AND Programa = @Programa)
SELECT @Ok = 1000023
IF ISNULL(@SubPrograma,'') <> ''
AND NOT EXISTS (SELECT SubPrograma FROM CESubPrograma WHERE SubPrograma = @SubPrograma AND Programa = @Programa AND Empresa = @Empresa AND Estatus = 'Activo')
SELECT @Ok = 1000016
IF NOT EXISTS (SELECT * FROM CEPrograma WHERE NivelAcademico = @NivelAcademico AND Programa = @Programa AND Empresa = @Empresa AND Estatus = 'Activo')
SELECT @Ok = 1000014
IF @NivelAcademico IS NOT NULL AND NOT EXISTS (SELECT NivelAcademico FROM CENivelAcademico WHERE NivelAcademico = @NivelAcademico AND Estatus = 'Activo' )
SELECT @Ok = 1000004
IF (SELECT DuracionFlexible FROM CEPlanEstudios WHERE Empresa = @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa) <> 1 AND @Ok IS NULL
IF (SELECT NumCiclo FROM CE WHERE ID = @ID) > (SELECT NumeroCiclos FROM CEPlanEstudios WHERE Empresa = @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa)
BEGIN
SELECT @Ok = 1000195, @OkRef = 'Numero de Ciclos en en el Plan de Estudios: ' +  (SELECT CAST(NumeroCiclos AS varchar(10)) FROM CEPlanEstudios WHERE Empresa = @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa)
END
IF @CfgExamenAdmicion = 1
BEGIN
IF @MovTipo IN ('CE.NI','CE.I')
AND NOT EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus IN ('PENDIENTE','CONCLUIDO') AND m.Clave = 'CE.A' AND d.EstatusD = 'Aprobado' )
BEGIN
SELECT @Ok = 1000021
END
IF @MovTipo = 'CE.NI'
AND NOT EXISTS ( SELECT * FROM CE c LEFT JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus IN('PENDIENTE','CONCLUIDO') AND m.Clave = 'CE.A' AND c.CicloEscolar =  @CicloEscolar AND c.NivelAcademico = @NivelAcademico)
BEGIN
SELECT @Ok = 1000020
END
IF @MovTipo='CE.NI'
AND NOT EXISTS (SELECT * FROM CE c LEFT JOIN CED d ON c.ID = d.ID
JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
JOIN CESesionAdmision S ON d.Sesion = S.ID AND d.Examen = S.Examen AND c.CicloEscolar = S.CicloEscolar
JOIN CEExamenAdmisionReservado R ON S.Examen = R.Examen AND S.CicloEscolar = R.CicloEscolar AND d.Alumno = R.Alumno AND d.Ficha = R.Ficha AND c.Empresa = R.Empresa
JOIN CEExamenAdmisionPrograma P ON S.Examen = P.Examen AND S.CicloEscolar = P.CicloEscolar
WHERE c.Alumno = @Alumno AND c.Estatus IN ('PENDIENTE','CONCLUIDO') AND m.Clave = 'CE.A' AND c.CicloEscolar =  @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND (d.EstatusD ='Aprobado' OR d.EstatusD IS NULL) AND P.Programa = @Programa)
BEGIN
SELECT @Ok = 1000196
END
IF @MovTipo= 'CE.PRM'
AND NOT EXISTS (SELECT * FROM CE c LEFT JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus IN ('PENDIENTE','CONCLUIDO') AND m.Clave IN('CE.I','CE.NI') AND c.CicloEscolar= @CicloEscolar AND c.NivelAcademico = @NivelAcademico)
AND NOT EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus IN ('PENDIENTE','CONCLUIDO') AND m.Clave = 'CE.A' AND d.EstatusD = 'Aprobado')
BEGIN
SELECT @Ok = 1000125
END
END ELSE IF @CfgExamenAdmicion = 0
BEGIN
IF @MovTipo= 'CE.PRM' AND NOT EXISTS (SELECT * FROM CE c LEFT JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno AND c.Estatus IN('PENDIENTE','CONCLUIDO') AND m.Clave IN('CE.I','CE.NI') AND c.CicloEscolar= @CicloEscolar AND c.NivelAcademico = @NivelAcademico)
BEGIN
SELECT @Ok = 1000125
END
END
IF @MovTipo IN ('CE.I') AND @EstatusNuevo = 'CONFIRMAR'
BEGIN
IF @EstatusAlumno NOT IN ('Alta','Baja')
SELECT @Ok = 1000094
IF @CambioMatricula = 0 AND  @MatriculaAlumno <> @Matricula
SELECT @Ok = 1000138
IF @CambioMatriculaPlantel = 1 AND @MatriculaAlumno = @Matricula AND @CambioMatricula = 1 AND @Sucursal <> @SucursalAlumno
SELECT @Ok = 1000139
IF  @CambioMatriculaCicloEscolar  = 1 AND @MatriculaAlumno = @Matricula   AND @CicloEscolarAlumno <> @CicloEscolar AND @CambioMatricula = 1 AND @MatriculaIDAlumno = 0
SELECT @Ok = 1000139
IF  @CambioMatriculaPrograma  = 1 AND @MatriculaAlumno = @Matricula   AND @ProgramaAlumno <> @Programa  AND @CambioMatricula = 1 AND @MatriculaIDAlumno = 0
SELECT @Ok = 1000139
IF  @CambioMatriculaNivel  = 1 AND @MatriculaAlumno = @Matricula   AND @NivelAlumno <> @NivelAcademico  AND @CambioMatricula = 1 AND @MatriculaIDAlumno = 0
SELECT @Ok = 1000139
END
IF EXISTS (SELECT * FROM CEMatriculaAlumno WHERE Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Matricula = @Matricula AND Alumno <> @Alumno )AND @MovTipo IN ('CE.I') AND @EstatusNuevo ='CONFIRMAR'
SELECT @Ok = 1000152
IF EXISTS (SELECT * FROM CEMatriculaAlumno WHERE Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Matricula = @Matricula AND Alumno <> @Alumno )AND @MovTipo IN ('CE.NI') AND @EstatusNuevo ='PENDIENTE'
SELECT @Ok = 1000152
IF @MovTipo IN ('CE.I','CE.NI') AND @EstatusNuevo IN( 'PENDIENTE','CONFIRMAR')
BEGIN
SELECT  @ProgramaActual       = Programa,
@NivelAcademicoActual = NivelAcademico,
@EstatusAlumno        = Estatus,
@PlanEstudiosActual   = PlanEstudio,
@CicloEscolarActual   = CicloEscolar
FROM  CEAlumno
WHERE  Alumno = @Alumno
SELECT  @SinOrdenNivel       = SinOrden,
@OrdenNivelAcademico = Orden
FROM  CENivelAcademico
WHERE  Empresa        = @Empresa
AND  NivelAcademico = @NivelAcademicoActual
SELECT  @SinOrdenPrograma = SinOrden,
@OrdenPrograma    = Orden
FROM  CEPrograma
WHERE  Empresa        = @Empresa
AND  NivelAcademico = @NivelAcademicoActual
AND  Programa       = @ProgramaActual
SELECT  @MaxCreditos                = LimiteCreditosMax,
@MinCreditos                = LimiteCreditosMin,
@MaxMaterias                = LimiteMateriasMax,
@MinMaterias                = LimiteMateriasMin,
@AlumnosInscritosPermitidos = AlumnosInscritosPermitidos
FROM  CEPLanEstudios
WHERE  Empresa      = @Empresa
AND  PlanEstudios = @PlanEstudios
AND  Programa     = @Programa
SELECT @ValidaCreditos= dbo.fnCEValidarCreditosCuota (@Empresa,@PlanEstudios,@Programa,@CicloEscolar,@Mov)
SELECT @ValidaMaterias= dbo.fnCEValidarMateriaCuota (@Empresa,@PlanEstudios,@Programa,@CicloEscolar,@Mov)
IF ISNULL(@NumCreditos,0) >  @MaxCreditos AND @ValidaCreditos = 1
SELECT @Ok = 1000037
IF ISNULL(@NumCreditos,0) < @MinCreditos AND @ValidaCreditos = 1
SELECT @Ok = 1000039
IF ISNULL(@NumMaterias,0) >  @MaxMaterias AND @ValidaMaterias = 1
SELECT @Ok = 1000038
IF ISNULL(@NumMaterias,0) < @MinMaterias AND @ValidaMaterias = 1
SELECT @Ok = 1000040
IF @MovTipo IN ('CE.NI') AND @AlumnosInscritosPermitidos IS NOT NULL
AND (SELECT  COUNT(DISTINCT Alumno)
FROM  CEAlumnoMateriasGrupoCursando
WHERE  Empresa      = @Empresa
AND  PlanEstudios = @PlanEstudios
AND  Programa     = @Programa ) >= @AlumnosInscritosPermitidos

SELECT @Ok = 1000209
IF @Ok IS NULL
AND EXISTS (SELECT * FROM CE c JOIN MovTipo m ON m.Modulo = 'CE' AND m.clave IN ('CE.I','CE.NI') AND c.Mov = m.Mov
WHERE c.Empresa = @Empresa AND c.Alumno = @Alumno AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.Programa = @Programa AND c.Estatus IN ('CONCLUIDO','PENDIENTE'))
BEGIN
SELECT @OK = 1000183,
@OkRef = 'Revise los movimientos: ' + STUFF((SELECT DISTINCT ', ' + c.Mov + ' ' + c.MovID + CHAR(10)
FROM CE c JOIN MovTipo m ON m.Modulo = 'CE' AND m.clave IN ('CE.I','CE.NI') AND c.Mov = m.Mov
WHERE c.Empresa = @Empresa
AND c.Alumno = @Alumno
AND c.CicloEscolar = @CicloEscolar
AND c.NivelAcademico = @NivelAcademico
AND c.Programa = @Programa
AND c.Estatus IN ('CONCLUIDO','PENDIENTE')
AND c.ID <> @ID FOR XML PATH('')),1,1,'')
END
IF @MovTipo IN ('CE.I') AND @EstatusAlumno ='Alta' AND @Programa <> @ProgramaActual
BEGIN

IF @NivelAcademico = @NivelAcademicoActual AND @EstatusAlumno = 'Alta' AND @SinOrdenPrograma = 0
BEGIN
SELECT @ProgramaNuevo = Programa
FROM CEPrograma
WHERE Orden = @OrdenPrograma + 1
AND Empresa = @Empresa
AND NivelAcademico = @NivelAcademicoActual
IF @Programa <> @ProgramaNuevo

SELECT @Ok = 1000078
END
IF @NivelAcademico <> @NivelAcademicoActual AND @EstatusAlumno ='Alta' AND @SinOrdenNivel =0 AND @MovTipo IN ('CE.I')
BEGIN
SELECT @NivelAcademicoNuevo = NivelAcademico
FROM CENivelAcademico
WHERE Empresa = @Empresa
AND Orden = @OrdenNivelAcademico+1
IF @NivelAcademico <> @NivelAcademicoNuevo
SELECT @Ok = 1000079
END
IF @EstatusAlumno ='Alta' AND @MovTipo IN ('CE.I') AND @SinOrdenPrograma = 0 AND @EstatusNuevo IN ('PENDIENTE')
AND EXISTS(SELECT * FROM CECalificacionPlanEstudios WHERE Empresa = @Empresa AND Sucursal = @Sucursal AND Alumno = @Alumno AND CicloEscolar = @CicloEscolarActual AND NivelAcademico = @NivelAcademicoActual AND Programa = @ProgramaActual AND PlanEstudios = @PlanEstudiosActual)
BEGIN
SELECT @CalifMinimaPrograma = CalifMinimaPrograma,
@MateriasRepMax = MateriasRepMax,
@VecesRepMax = VecesRepMax
FROM CEPLanEstudios
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudiosActual
AND Programa = @ProgramaActual
SELECT @CalificacionPlan = Calificacion
FROM CECalificacionPlanEstudios
WHERE Empresa = @Empresa
AND Sucursal = @Sucursal
AND Alumno = @Alumno
AND CicloEscolar = @CicloEscolarActual
AND NivelAcademico = @NivelAcademicoActual
AND Programa = @ProgramaActual
AND PlanEstudios = @PlanEstudiosActual
IF ISNULL(@CalificacionPlan,0.0) < @CalifMinimaPrograma AND @MovTipo IN ('CE.I')
SELECT @Ok = 1000080
SELECT @MateriasRep = COUNT(*)
FROM CEPlanEstudiosMateriasReprobadas
WHERE Empresa = @Empresa
AND Sucursal = @Sucursal
AND Alumno = @Alumno
AND CicloEscolar = @CicloEscolarActual
AND NivelAcademico = @NivelAcademicoActual
AND Programa = @ProgramaActual
AND PlanEstudios = @PlanEstudiosActual
IF  ISNULL(@MateriasRep,0) >  @MateriasRepMax AND @MovTipo IN ('CE.I')
SELECT @Ok=1000081
END
END
END
IF @MovTipo IN ('CE.PRM','CE.RM') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF @MovTipo = 'CE.RM' AND @Ok IS NULL
IF EXISTS (SELECT * FROM CEPlanEstudiosCuotasRecurrentes
WHERE  Empresa             = @Empresa
AND  PlanEstudios        = @PlanEstudios
AND  Programa            = @Programa
AND  CicloEscolar        = @CicloEscolar
AND  ISNULL(Sucursal,'') = CASE WHEN ISNULL(Sucursal,'') = '' THEN '' ELSE @Sucursal END
AND  Tipo                = 'Por Materias Porcentaje')
IF ((SELECT ISNULL(NombreCuotaRecIE,'') FROM CE WHERE ID = @ID) = '')
SELECT @Ok = 1000185
INSERT @Tabla3(Materia,Creditos,Periodo)
SELECT m.Materia,p.Creditos,m.NumPeriodo
FROM CEAlumnoMateriasGrupoCursando m JOIN CEPLanEstudiosMaterias p ON m.Empresa = p.Empresa AND m.PlanEstudios = p.PlanEstudios AND m.Programa = p.Programa AND m.Materia = p.Materia 
WHERE m.Alumno = @Alumno
AND m.Empresa = @Empresa
AND m.PlanEstudios = @PlanEstudios
AND m.Programa = @Programa
AND m.CicloEscolar = @CicloEscolar
AND m.NivelAcademico = @NivelAcademico
AND m.Sucursal = @Sucursal
GROUP BY m.Alumno,m.Materia,p.Creditos,m.NumPeriodo
UNION ALL
SELECT d.Materia,p.Creditos,a.Periodo
FROM CE c JOIN CED d ON c.ID = d.ID
JOIN CEPLanEstudiosMaterias p ON c.Empresa = p.Empresa AND c.PlanEstudios = p.PlanEstudios AND c.Programa = p.Programa AND d.Materia = p.Materia 
JOIN CEAsignacionMateriaGrupo a ON c.Empresa = a.Empresa AND a.CicloEscolar=c.CicloEscolar AND  a.PlanEstudios = c.PlanEstudios AND a.Programa = c.Programa AND d.Materia = a.Materia AND d.Grupo = a.Grupo AND a.Asignacion = d.Asignacion 
WHERE c.ID = @ID
GROUP BY d.Materia,p.Creditos,a.Periodo
IF @PermiteElectivas = 1
INSERT @Tabla3 (Materia,Creditos,Periodo)
SELECT d.Materia,p.Creditos,a.periodo
FROM CE c JOIN CED d ON c.ID = d.ID
JOIN CEPLanEstudiosMaterias p  ON p.Materia =d.Materia AND p.Empresa = c.Empresa AND p.PlanEstudios <> c.PlanEstudios AND  p.Programa<>c.Programa
JOIN CEAsignacionMateriaGrupo a ON c.Empresa = a.Empresa AND a.CicloEscolar=c.CicloEscolar AND d.Materia = a.Materia  AND a.Asignacion = d.Asignacion
JOIN CEMateria m ON d.Materia = m.Materia AND c.Empresa = m.Empresa
WHERE p.Empresa=@Empresa
AND p.PlanEstudios<>@PlanEstudios
AND p.Programa<>@Programa
AND c.CicloEscolar = @CicloEscolar
AND m.Electiva = 1
GROUP BY d.Materia,p.Creditos,a.periodo
IF @SubMovTipo ='CE.CRM'
DELETE @Tabla3 WHERE Materia IN (SELECT MateriaCambio FROM CED WHERE ID = @ID)
SELECT @MaxCreditos = LimiteCreditosMax,
@MaxMaterias = LimiteMateriasMax,
@MinCreditos = LimiteCreditosMin,
@MinMaterias = LimiteMateriasMin
FROM CEPLanEstudios
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa = @Programa
SELECT @CreditosCursando = SUM(Creditos),
@MateriasCursando = COUNT(Materia)
FROM @Tabla3
GROUP BY Materia
IF ISNULL(@CreditosCursando,0)>ISNULL(@MaxCreditos,0) AND @CfgCreditos=1
SELECT @Ok = 1000037
IF ISNULL(@MateriasCursando,0)>ISNULL(@MaxMaterias,0)
SELECT @Ok = 1000038
END
END
IF @MovTipo IN ('CE.C') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios AND Programa = @Programa AND Estatus = 'Activo' )AND @PlanEstudios IS NOT NULL AND @Programa IS NOT NULL
SELECT @Ok = 1000024
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios AND Programa = @Programa )AND @PlanEstudios IS NOT NULL AND @Programa IS NOT NULL
SELECT @Ok = 1000023
IF NOT EXISTS (SELECT SubPrograma FROM CESubPrograma WHERE SubPrograma = @SubPrograma AND Programa = @Programa AND Empresa = @Empresa AND Estatus = 'Activo'  ) AND @SubPrograma NOT IN (NULL,'')AND @Programa IS NOT NULL
SELECT @Ok = 1000016
IF NOT EXISTS (SELECT * FROM CEPrograma WHERE NivelAcademico = @NivelAcademico AND Programa = @Programa AND Empresa = @Empresa AND Estatus = 'Activo' )AND @Programa IS NOT NULL AND @NivelAcademico IS NOT NULL
SELECT @Ok = 1000014
IF NOT EXISTS (SELECT NivelAcademico FROM CENivelAcademico WHERE NivelAcademico = @NivelAcademico AND Estatus = 'Activo' )AND @NivelAcademico IS NOT NULL
SELECT @Ok = 1000004
END
IF @MovTipo IN ('CE.ASI') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
EXEC spCEVerificarAsignacion @ID, @Accion, @Usuario, @Empresa, @Ok OUTPUT, @OkRef OUTPUT
END
IF @MovTipo IN ('CE.AS','CE.ASS','CE.CL','CE.ACL') AND @EstatusNuevo = 'CONCLUIDO' AND @Ok IS NULL
BEGIN
IF ISNULL(@DefPersonal,'') <> ''
AND NOT EXISTS (SELECT * FROM CEAsignacionMaestroHorario  WHERE Materia = @Materia AND Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Grupo = @Grupo AND ISNULL(Nivel,'') = ISNULL(@Nivel,'') AND Maestro = @DefPersonal)
BEGIN
SELECT @OK = 1000156
END
SELECT @NivelMateria = Nivel,
@FormaMateria = FormaMateria
FROM CEMateria
WHERE Materia = @Materia
AND Empresa = @Empresa
IF ISNULL(@ConceptoCalificacion,'') = ''
SELECT @Ok = 1000068
IF @EstatusNuevo = 'CONCLUIDO'
AND @ConceptoCalificacion NOT IN (SELECT ConceptoCalificacion FROM CEConceptoCalificacion) AND NOT @MovTipo IN ('CE.AS','CE.ASS')
SELECT @Ok = 1000068
IF @FormaMateria = 'Agrupada'
BEGIN
IF @SubMateria IS NULL
SELECT @Ok = 1000070
IF NOT EXISTS (SELECT MateriaGrupo FROM CEMateriaGrupo WHERE Empresa = @Empresa AND Materia = @Materia AND MateriaGrupo = @SubMateria)AND @SubMateria IS NOT NULL
SELECT @Ok = 1000071
END
IF @NivelMateria= 1
BEGIN
IF @NivelEnc IS NULL
SELECT @Ok = 1000072
IF NOT EXISTS (SELECT Nivel FROM CEMateriaNivel WHERE Empresa = @Empresa AND Materia = @Materia AND Nivel = @NivelEnc)AND @NivelEnc IS NOT NULL
SELECT @Ok = 1000073
END
IF (SELECT CONVERT(int,Periodo) FROM CEPLanEstudiosMaterias WHERE Materia = @Materia AND Empresa = @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND ISNULL(SubPrograma,'') = ISNULL(@SubPrograma,''))>@PeriodoAsignacion
SELECT @Ok = 1000101
IF @TipoCalificacion ='Periodo' AND @PeriodoAsignacion IS NULL
SELECT @Ok = 1000100
IF @TipoCalificacion IS NULL
SELECT @Ok = 1000099
END
IF @ServicioSocial = 0
AND @MovTipo IN('CE.ACSS','CE.ASS','CE.HSS','CE.LSS','CE.SPSS','CE.SS') AND @EstatusNuevo IN('CONCLUIDO','BORRADOR','PENDIENTE')
BEGIN
SELECT @OK= 1000114
END
IF @MovTipo IN('CE.CC') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
SELECT @CreditosElectivos = CreditosElectivos,
@MateriasElectivas = MateriasElectivas
FROM CEPLanEstudios
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa = @Programa
SELECT @TotalMaterias = ISNULL(COUNT(Materia),0),
@SumaCreditos=ISNULL(SUM(Creditos),0)
FROM CEAlumnoMateriasProgramaAprobadas
WHERE TipoMateria  = 'Electiva'
AND Empresa      = @Empresa
AND Alumno       = @Alumno
AND PlanEstudios = @PlanEstudios
AND Programa     = @Programa
IF EXISTS(SELECT Materia FROM CEAlumnoMateriasGrupoCursando WHERE Alumno = @Alumno AND CicloEscolar = @CicloEscolar AND NivelAcademico = @NivelAcademico AND Programa = @Programa AND PlanEstudios = @PlanEstudios EXCEPT SELECT  Materia FROM  CED WHERE ID = @ID)
SELECT @OK = 1000067 , @OkRef = @OkRef+ ' ('+(SELECT TOP 1 Materia FROM (SELECT Materia FROM CEAlumnoMateriasGrupoCursando WHERE Alumno = @Alumno  AND CicloEscolar = @CicloEscolar AND NivelAcademico = @NivelAcademico AND Programa = @Programa AND PlanEstudios = @PlanEstudios  EXCEPT SELECT  Materia FROM  CED WHERE ID = @ID)As t)+')'
IF EXISTS (SELECT * FROM CE c JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE mt.Clave IN ('CE.CC') AND c.Estatus IN('PENDIENTE','CONCLUIDO') AND c.Empresa = @Empresa AND c.Alumno = @Alumno  AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.Programa = @Programa AND c.PlanEstudios = @PlanEstudios AND c.SubPrograma = @SubPrograma)
SELECT @OK = 1000066
IF EXISTS(SELECT  Materia,Asignacion FROM  CEAlumnoMateriasGrupoCursando  WHERE Empresa = @Empresa AND Programa = @Programa AND PlanEstudios = @PlanEstudios AND Alumno = @Alumno  EXCEPT SELECT Materia,Asignacion FROM CED WHERE ID = @ID)
SELECT @Ok = 1000087, @OkRef = @OkRef + ' ('+(SELECT TOP 1 Materia FROM ( SELECT  Materia,Asignacion  FROM  CEAlumnoMateriasGrupoCursando  WHERE Empresa = @Empresa AND Programa = @Programa AND PlanEstudios = @PlanEstudios AND Alumno = @Alumno   EXCEPT SELECT Materia,Asignacion  FROM CED WHERE ID = @ID)As t)+')'
END
IF @MovTipo IN ('CE.EXT') AND @EstatusNuevo = 'BORRADOR'
BEGIN
SELECT @VecesRepMax = VecesRepMax
FROM CEPLanEstudios
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa = @Programa
IF(SELECT COUNT(*) FROM  CEPlanEstudiosExtraordinario WHERE Alumno = @Alumno AND Empresa = @Empresa AND Sucursal = @Sucursal AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND EstatusD = 'Reprobado' AND Materia = @Materia)>= @VecesRepMax
SELECT @OK= 1000082 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
IF(SELECT Veces FROM CEAlumnoMateriasVecesCursadas WHERE Alumno = @Alumno AND PlanEstudios = @PlanEstudios AND Materia = @Materia)>= @VecesRepMax
SELECT @OK= 1000082 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
IF NOT EXISTS (SELECT * FROM CEPlanEstudiosMateriasReprobadas WHERE Alumno = @Alumno AND Empresa = @Empresa AND Sucursal = @Sucursal AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND Materia = @Materia)
SELECT @OK= 1000085 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
END
IF @MovTipo IN('CE.EXT') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @VecesRepMax = VecesRepMax
FROM CEPLanEstudios
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa = @Programa
IF(SELECT Veces FROM CEAlumnoMateriasVecesCursadas WHERE Alumno = @Alumno AND PlanEstudios = @PlanEstudios AND Materia = @Materia)>= @VecesRepMax
SELECT @OK= 1000082 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
IF(SELECT COUNT(*) FROM  CEPlanEstudiosExtraordinario WHERE Alumno = @Alumno AND Empresa = @Empresa AND Sucursal = @Sucursal AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND EstatusD = 'Reprobado' AND Materia = @Materia)>= @VecesRepMax
SELECT @OK= 1000082 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
IF EXISTS (SELECT * FROM CEPlanEstudiosExtraordinario WHERE Alumno = @Alumno AND Empresa = @Empresa AND Sucursal = @Sucursal AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND EstatusD = 'Aprobadoi' AND Materia = @Materia)
SELECT @OK= 1000083 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
IF NOT EXISTS (SELECT * FROM CEPlanEstudiosMateriasReprobadas WHERE Alumno = @Alumno AND Empresa = @Empresa AND Sucursal = @Sucursal AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND Materia = @Materia)
SELECT @OK= 1000085 , @OkRef = @OkRef+ ' Materia('+@Materia+')'
END
IF @MovTipo IN ('CE.CC','CE.RCC','CE.A','CE.NI','CE.PRM','CE.RM','CE.BA','CE.BI','CE.C','CE.G','CE.RI','CE.RE','CE.HIS') AND @EstatusNuevo <> 'CANCELADO'
BEGIN
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudios) OR @PlanEstudios IS  NULL
SELECT @Ok = 1000007
IF NOT EXISTS (SELECT Programa FROM CEPrograma WHERE Programa = @Programa )OR @Programa IS  NULL
SELECT @Ok = 1000005
IF NOT EXISTS (SELECT NivelAcademico FROM CENivelAcademico WHERE NivelAcademico = @NivelAcademico)OR @NivelAcademico IS  NULL
SELECT @Ok = 1000003
END
IF @EstatusNuevo <> 'CANCELADO'
AND @MovTipo IN ('CE.CP','CE.CC','CE.RCC','CE.EXT','CE.A','CE.NI','CE.PRM','CE.RM','CE.CL','CE.ACL','CE.AS','CE.AAS','CE.BA','CE.BI','CE.C','CE.G','CE.RI','CE.RE','CE.ACP','CE.RCP')
BEGIN
IF NOT EXISTS (SELECT CicloEscolar FROM CECicloEscolar WHERE CicloEscolar = @CicloEscolar ) OR ISNULL(@CicloEscolar,'') = ''
SELECT @Ok = 1000002
END
IF @MovTipo IN ('CE.G') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @SinOrdenPrograma = SinOrden,
@OrdenPrograma = Orden
FROM CEPrograma
WHERE Empresa = @Empresa
AND NivelAcademico = @NivelAcademico
AND Programa = @Programa
SELECT @CreditosElectivos = CreditosElectivos,
@MateriasElectivas = MateriasElectivas,
@CalificacionPlan  = CalifMinimaPrograma
FROM CEPLanEstudios
WHERE Empresa      = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa     = @Programa
SELECT @TotalMaterias = ISNULL(COUNT(Materia),0),
@SumaCreditos  = ISNULL(SUM(Creditos),0)
FROM CEAlumnoMateriasProgramaAprobadas
WHERE TipoMateria   = 'Electiva'
AND Empresa       = @Empresa
AND Alumno        = @Alumno
AND PlanEstudios  = @PlanEstudios
IF @SinOrdenPrograma =0
AND (SELECT MAX(Orden) FROM CEPrograma WHERE Empresa = @Empresa AND NivelAcademico = @NivelAcademico) <> @OrdenPrograma
SELECT @Ok = 1000086
IF EXISTS(SELECT Materia FROM CEPlanEstudiosExtraordinario  WHERE Alumno = @Alumno AND NivelAcademico = @NivelAcademico AND Programa = @Programa AND EstatusD = 'Reprobado'
EXCEPT
SELECT Materia FROM CEPlanEstudiosExtraordinario  WHERE Alumno = @Alumno AND NivelAcademico = @NivelAcademico AND Programa = @Programa AND EstatusD = 'Aprobado')
SELECT @OK = 1000087
IF ISNULL(@SumaCreditos,0) <ISNULL(@CreditosElectivos,0) AND @CfgCreditos=1
SELECT @Ok = 1000157
IF ISNULL(@TotalMaterias,0) <ISNULL(@MateriasElectivas,0)
SELECT @Ok =1000158
IF EXISTS(SELECT p.Materia FROM CEPLanEstudiosMaterias p
JOIN CENumCicloAlumno  n ON  n.Empresa =p.Empresa AND  n.PlanEstudios = p.PlanEstudios AND n.Programa = p.Programa    AND n.Alumno = @Alumno
WHERE p.Empresa= @Empresa AND p.PlanEstudios = @PlanEstudios AND p.Programa = @Programa
AND p.TipoMateria IN ('Fija','Flexible')
AND ISNULL(p.SubPrograma,'') = CASE
WHEN EXISTS(SELECT * FROM CEPLanEstudiosMaterias WHERE Empresa = p.Empresa AND PlanEstudios = p.PlanEstudios AND Programa = p.Programa  AND Materia = p.Materia AND SubPrograma = n.SubPrograma) THEN n.SubPrograma ELSE '' END
GROUP BY p.Materia
EXCEPT SELECT  Materia FROM  CEAlumnoMateriasProgramaAprobadas WHERE Empresa= @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND Alumno = @Alumno )
SELECT @OK= 1000093 , @OkRef = @OkRef+ ' Materia('+(SELECT TOP 1 Materia FROM (SELECT p.Materia FROM CEPLanEstudiosMaterias p
JOIN CENumCicloAlumno  n ON  n.Empresa =p.Empresa AND  n.PlanEstudios = p.PlanEstudios AND n.Programa = p.Programa    AND n.Alumno = @Alumno
WHERE p.Empresa= @Empresa AND p.PlanEstudios = @PlanEstudios AND p.Programa = @Programa
AND p.TipoMateria IN ('Fija','Flexible')
AND ISNULL(p.SubPrograma,'') = CASE
WHEN EXISTS(SELECT * FROM CEPLanEstudiosMaterias WHERE Empresa = p.Empresa AND PlanEstudios = p.PlanEstudios AND Programa = p.Programa  AND Materia = p.Materia AND SubPrograma = n.SubPrograma) THEN n.SubPrograma ELSE '' END
GROUP BY p.Materia
EXCEPT SELECT  Materia FROM  CEAlumnoMateriasProgramaAprobadas WHERE Empresa= @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND Alumno = @Alumno ) As t)+')'
IF ISNULL(@CalificacionPlan,0.0) > ISNULL(@CalificacionE,0.0)
SELECT @Ok = 1000170
IF @Ok IS NULL
EXEC spCETitulacionVerifRequisitos  @ID,@Alumno,@Empresa,@Accion,@Usuario,@PlanEstudios,@FormaTitulacion,@Ok	OUTPUT,@OkRef OUTPUT
IF NOT EXISTS (SELECT * FROM CETitulacionCalificacion WHERE ID = @ID)
SELECT @Ok = 1000168
END
IF @MovTipo IN ('CE.IT')
BEGIN
SELECT @Clave = mt.Clave
FROM CE c
JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE'
WHERE c.Mov = @Origen AND c.MovID = @OrigenID AND c.Empresa = @Empresa
SELECT @MovSolicitud = CESolInter FROM EmpresaCfgMovCE WHERE Empresa = @Empresa
IF @Clave <> 'CE.SI'
SELECT @OK = 1000092, @OkRef = @OkRef + @MovSolicitud
END
IF @MovTipo IN ('CE.RE')
BEGIN
IF NULLIF(@Escuela,'') IS NULL
SELECT @OK = 1000009
IF NOT EXISTS(SELECT * FROM CEEscuela WHERE Escuela = @Escuela)
SELECT @OK = 1000009
END
IF @MovTipo IN ('CE.B','CE.BR') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF @MultiplesBecas = 0 AND (SELECT COUNT(Beca) FROM CED WHERE ID = @ID)>1
SELECT @Ok = 1000109
IF @MultiplesBecas = 0 AND EXISTS(SELECT * FROM CEBecasActivas WHERE Empresa = @Empresa AND Alumno = @Alumno AND CicloEscolar=@CicloEscolar)
SELECT @Ok = 1000109
END
IF @MovTipo IN ('CE.SB') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF @MultiplesBecas = 0 AND (SELECT COUNT(Beca) FROM CED WHERE ID = @ID)>1
SELECT @Ok = 1000109
IF @MultiplesBecas = 0 AND EXISTS(SELECT * FROM CEBecasActivas WHERE Empresa = @Empresa AND Alumno = @Alumno AND CicloEscolar=@CicloEscolar)
SELECT @Ok = 1000109
END
IF @MovTipo IN ('CE.ACSS','CE.SPSS','CE.HSS','CE.ASS') AND @EstatusNuevo IN('BORRADOR','PENDIENTE','CONCLUIDO')
BEGIN
IF (SELECT Estatus FROM CESSEmpresaOferta WHERE Ofertante = @Ofertante AND Oferta = @ProyectoSS)<>'Activo'
SELECT @Ok =1000117  ,@OkRef = @OkRef+ ' ('+@Ofertante+') Proyecto('+@ProyectoSS+')'
IF NOT EXISTS (SELECT * FROM CESSEmpresaOferta WHERE Ofertante = @Ofertante AND Oferta = @ProyectoSS)
SELECT @OK= 1000122 , @OkRef = @OkRef+ ' ('+@Ofertante+') Proyecto('+@ProyectoSS+')'
IF NOT EXISTS (SELECT * FROM CESSEmpresa WHERE Ofertante = @Ofertante)
SELECT @OK= 1000120 , @OkRef = @OkRef+ '('+@Ofertante+')'
IF (SELECT Estatus FROM  CESSEmpresa WHERE Ofertante = @Ofertante)<> 'Activo'
SELECT @OK= 1000121 , @OkRef = @OkRef+ '('+@Ofertante+')'
END
IF @MovTipo IN ('CE.SS') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
SELECT @HorasServicio = HorasServicio,
@MinCiclos = CicloMinSS,
@MinMaterias = MinMatSS,
@CreditosPre = CreditosServicios
FROM CEPLanEstudios
WHERE PlanEstudios = @PlanEstudios
AND Programa = @Programa
AND Empresa = @Empresa
SELECT @SumaCreditos2 = SUM(Creditos)
FROM CEAlumnoMateriasProgramaAprobadas
WHERE Alumno = @Alumno
AND Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
IF ISNULL(@SumaCreditos2,0) < ISNULL(@CreditosPre,0) AND @CfgCreditos=1
SELECT @Ok = 1000167
SELECT @CantidadMateria = COUNT(Materia)
FROM CEAlumnoMateriasCursadas
WHERE Empresa = @Empresa
AND Alumno = @Alumno AND Forma <> 'NA'
SELECT @Ciclos = COUNT(CicloEscolar)
FROM CEAlumnoMateriasCursadas
WHERE Empresa = @Empresa
AND Alumno = @Alumno
AND Forma <> 'NA'
IF ISNULL(@Ciclos,0) < ISNULL(@MinCiclos,0)
SELECT @Ok = 1000130
IF ISNULL(@CantidadMateria,0) < ISNULL(@MinMaterias,0)
SELECT @Ok = 1000131
IF @HorasServicio IS NULL
SELECT @OK= 1000123
END
IF @MovTipo IN ('CE.ASS') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF (SELECT ISNULL(Disponible,0) FROM CESSEmpresaOfertaDisponible WHERE Ofertante = @Ofertante AND Oferta = @ProyectoSS)<1
SELECT @Ok =1000115, @OkRef = @OkRef+ ' ('+@Ofertante+') Proyecto('+@ProyectoSS+')'
END
IF @MovTipo IN ('CE.HSS') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @FechaInicio = FechaInicio,
@FechaFin = FechaFin
FROM CESSEmpresaOfertaDisponible
WHERE Ofertante = @Ofertante
AND Oferta = @ProyectoSS
IF @FechaEmision NOT BETWEEN @FechaInicio AND @FechaFin
SELECT @Ok = 1000116, @OkRef = @OkRef+ ' ('+@Ofertante+') Proyecto('+@ProyectoSS+')'
IF @Horas IS NULL
SELECT @Ok =1000132
END
IF @MovTipo IN ('CE.LSS') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @HorasServicio = HorasServicio
FROM CEPLanEstudios
WHERE PlanEstudios = @PlanEstudios
AND Programa = @Programa
AND Empresa = @Empresa
IF (SELECT ISNULL(SUM(Horas),0) FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno
AND c.PlanEstudios = @PlanEstudios
AND c.Programa = @Programa
AND c.Empresa = @Empresa
AND m.Clave = 'CE.ACSS'
AND c.Estatus = 'CONCLUIDO' )< ISNULL(@HorasServicio,0)
BEGIN
SELECT @Horas = ISNULL(SUM(Horas),0) FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno
AND c.PlanEstudios = @PlanEstudios
AND c.Programa = @Programa
AND c.Empresa = @Empresa
AND m.Clave = 'CE.ACSS'
AND c.Estatus = 'CONCLUIDO'
SELECT @Ok = 1000124, @OkRef = @OkRef + ' Horas Cubiertas: ' + Convert(varchar(20), @Horas) + ' Horas Necesarias: ' + Convert(varchar(20), @HorasServicio)
END
END
IF @MovTipo IN ('CE.ASB') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF (SELECT ISNULL(Disponible,0) FROM CEServicioBecarioOfertaDisponible WHERE Empresa = @Empresa AND Oferta = @ProyectoSB)<1
SELECT @Ok =1000205, @OkRef = @OkRef + @ProyectoSB
IF @Ok IS NULL AND NOT EXISTS (SELECT * FROM CEBecasActivas
WHERE  Empresa      = @Empresa
AND  Alumno       = @Alumno
AND  CicloEscolar = @CicloEscolar
AND  Programa     = @Programa)
SELECT @Ok = 1000210
END
IF @MovTipo IN ('CE.ASB') AND @EstatusNuevo = 'PENDIENTE'
IF (SELECT ISNULL(Disponible,0) FROM CEServicioBecarioOfertaDisponible WHERE Empresa = @Empresa AND Oferta = @ProyectoSB)<1
SELECT @Ok =1000205, @OkRef = @OkRef + @ProyectoSB
IF @MovTipo IN ('CE.HSB') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @FechaInicio = FechaInicio,
@FechaFin = FechaFin
FROM CEServicioBecarioOfertaDisponible
WHERE Empresa = @Empresa
AND Oferta = @ProyectoSB
IF ISNULL(@FechaInicio,'') <> '' AND ISNULL(@FechaFin,'') <> ''
IF @FechaEmision NOT BETWEEN @FechaInicio AND @FechaFin
SELECT @Ok = 1000206, @OkRef = @OkRef + @ProyectoSB
IF @Horas IS NULL
SELECT @Ok = 1000132
END
IF @MovTipo IN ('CE.LSB') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @HorasServicio = Horas
FROM CE a
JOIN Movtipo  b ON a.Mov = b.Mov AND Clave = 'CE.SBE'
WHERE a.Empresa = @Empresa
AND a.Alumno = @Alumno
AND a.CicloEscolar = @CicloEscolar
AND a.Estatus = 'PENDIENTE'
IF (SELECT ISNULL(SUM(Horas),0) FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno
AND c.PlanEstudios = @PlanEstudios
AND c.Programa = @Programa
AND c.Empresa = @Empresa
AND m.Clave = 'CE.ACSB'
AND c.Estatus = 'CONCLUIDO' ) < ISNULL(@HorasServicio,0)
BEGIN
SELECT @Horas = ISNULL(SUM(Horas),0)
FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'
WHERE c.Alumno = @Alumno
AND c.PlanEstudios = @PlanEstudios
AND c.Programa = @Programa
AND c.Empresa = @Empresa
AND m.Clave = 'CE.ACSB'
AND c.Estatus = 'CONCLUIDO'
SELECT @Ok = 1000203, @OkRef = @OkRef + ' Horas cubiertas: ' + Convert(varchar(20), @Horas) + ' Horas necesarias: ' + Convert(varchar(20), @HorasServicio)
END
END
IF @MovTipo IN ('CE.EP','CE.RT','CE.CT') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF EXISTS (SELECT * FROM CEAsignacionEspacioHorario WHERE Empresa = @Empresa AND Espacio = @Espacio AND Fecha = @FechaExamen AND HoraInicio >=@HorarioDesde AND HoraFin <= @HorarioHasta AND Estatus = 'RESERVADO'
OR Empresa = @Empresa AND Espacio = @Espacio AND Fecha = @FechaExamen AND @HorarioDesde >=HoraInicio AND @HorarioHasta <= HoraFin AND Estatus = 'RESERVADO'
OR Empresa = @Empresa AND Espacio = @Espacio  AND Fecha = @FechaExamen AND HoraInicio BETWEEN @HorarioDesde AND dbo.fnRestarHoras(@HorarioHasta,'00:01') AND Estatus = 'RESERVADO'
OR Empresa = @Empresa AND Espacio = @Espacio  AND Fecha = @FechaExamen AND HoraFin BETWEEN dbo.fnSumarHoras(@HorarioDesde,'00:01') AND @HorarioHasta AND Estatus = 'RESERVADO'
)
SELECT @Ok = 1000044, @OkRef = @OkRef+ 'Espacio: ('+@Espacio+') '+'Fecha:('+CONVERT(varchar,@FechaExamen)+' A las '+@HorarioDesde+')'
IF NULLIF(@FechaExamen,'') IS NULL
SELECT @Ok = 1000118
IF NULLIF(@Espacio,'') IS NULL
SELECT @Ok = 1000075
IF NULLIF(@HorarioDesde,'') IS NULL
SELECT @Ok = 1000119
IF NULLIF(@HorarioHasta,'') IS NULL
SELECT @Ok = 1000119
IF @MovTipo = 'CE.EP' AND NOT EXISTS (SELECT * FROM CEPersonalMov WHERE ID = @ID)
SELECT @Ok = 1000076
END
IF @Ok IS NOT NULL RETURN
IF @MovTipo IN ('CE.RIT','CE.BM','CE.B','CE.A','CE.AC','CE.PRM','CE.RM','CE.AS' ,'CE.AAS','CE.CL','CE.ACL','CE.C' ,'CE.RI','CE.RE','CE.BB' ,'CE.EP','CE.CT','CE.IE','CE.CEX','CE.ACP','CE.RCP','CE.RCC','CE.HIS','CE.CP','CE.CC','CE.BR')
AND NOT EXISTS (SELECT * FROM CED WHERE ID = @ID)
BEGIN
SELECT @Ok = 1000127
END
IF @MovTipo = 'CE.CP' AND @EstatusNuevo ='CONCLUIDO' AND @Ok IS NULL
BEGIN
DECLARE
@IDV int,
@RenglonV float,
@AlumnoV varchar(20),
@RIDV int,
@ConceptoCalificacionV varchar(50)
DECLARE @TablaVadidaConseptosCalif AS TABLE (
ID int,
Renglon float,
Alumno varchar(20),
RID int,
ConceptoCalificacion varchar(50),
ExisteConceptoCalif bit
)
DECLARE crValidarConceptosCalif CURSOR FOR
SELECT C.ID,D.Renglon,D.Alumno,P.RID,P.ConceptoCalificacion
FROM CE C
LEFT OUTER JOIN CED D ON C.ID = D.ID
LEFT OUTER JOIN CECierrePeriodoPromedio P ON C.ID = P.ID AND D. Renglon =P.Renglon
WHERE C.ID = @ID
OPEN crValidarConceptosCalif
FETCH NEXT FROM crValidarConceptosCalif INTO @IDV, @RenglonV, @AlumnoV, @RIDV, @ConceptoCalificacionV
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO @TablaVadidaConseptosCalif
SELECT @IDV ,@RenglonV ,@AlumnoV ,@RIDV ,@ConceptoCalificacionV, NULL AS ExisteConceptoCalif
IF EXISTS(SELECT * FROM CECierrePeriodoPromedioDetalle WHERE RID=@RIDV AND ID =@IDV AND Renglon =@RenglonV)
UPDATE @TablaVadidaConseptosCalif SET ExisteConceptoCalif = 1 WHERE RID=@RIDV AND ID =@IDV AND Renglon =@RenglonV
ELSE
UPDATE @TablaVadidaConseptosCalif SET ExisteConceptoCalif = 0 WHERE RID=@RIDV AND ID =@IDV AND Renglon =@RenglonV
FETCH NEXT FROM crValidarConceptosCalif INTO @IDV, @RenglonV, @AlumnoV, @RIDV, @ConceptoCalificacionV
END
CLOSE crValidarConceptosCalif
DEALLOCATE crValidarConceptosCalif
IF (SELECT COUNT(ExisteConceptoCalif) FROM @TablaVadidaConseptosCalif WHERE ExisteConceptoCalif =0) >= 1
BEGIN

--select * from @TablaVadidaConseptosCalif--prb
DELETE FROM CED WHERE ID = @ID
SELECT @Ok = 1000190, @OkRef= 'Faltan los conceptos: '+ STUFF((SELECT DISTINCT ', ' + ConceptoCalificacion FROM @TablaVadidaConseptosCalif WHERE ExisteConceptoCalif =0 FOR XML PATH('')),1,1,'')
END
END
IF @MovTipo = 'CE.CC' AND @EstatusNuevo ='PENDIENTE' AND @Ok IS NULL
BEGIN
DECLARE
@IDVC int,
@RenglonVC float,
@AlumnoVC varchar(20),
@RIDVC int,
@ConceptoCalificacionVC varchar(50),
@MateriaVC varchar(20),
@PeriodoVC int
DECLARE @TablaVadidaCierrePeriodo AS TABLE (
ID int,
Renglon float,
Alumno varchar(20),
RID int,
ConceptoCalificacion varchar(50),
Materia varchar(20),
Periodo int,
ExisteConceptoCalif bit
)
DECLARE crValidarCierrePeriodo CURSOR FOR
SELECT C.ID,D.Renglon,C.Alumno,P.RID,P.ConceptoCalificacion,P.Periodo,P.Materia
FROM CE C
LEFT OUTER JOIN CED D ON C.ID = D.ID
LEFT OUTER JOIN CECierreCicloPromedio P ON C.ID = P.ID AND D. Renglon =P.Renglon
WHERE C.ID = @ID
OPEN crValidarCierrePeriodo
FETCH NEXT FROM crValidarCierrePeriodo INTO @IDVC ,@RenglonVC ,@AlumnoVC ,@RIDVC ,@ConceptoCalificacionVC, @PeriodoVC,@MateriaVC
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO @TablaVadidaCierrePeriodo
SELECT @IDVC ,@RenglonVC ,@AlumnoVC ,@RIDVC ,@ConceptoCalificacionVC, @MateriaVC,@PeriodoVC,NULL AS ExisteConceptoCalif
IF EXISTS(SELECT * FROM CECierreCicloPromedioDetalle WHERE RID=@RIDVC AND ID =@IDVC AND Renglon =@RenglonVC)
UPDATE @TablaVadidaCierrePeriodo SET ExisteConceptoCalif = 1 WHERE RID=@RIDVC AND ID =@IDVC AND Renglon =@RenglonVC
ELSE
UPDATE @TablaVadidaCierrePeriodo SET ExisteConceptoCalif = 0 WHERE RID=@RIDVC AND ID =@IDVC AND Renglon =@RenglonVC
FETCH NEXT FROM crValidarCierrePeriodo INTO  @IDVC ,@RenglonVC ,@AlumnoVC ,@RIDVC ,@ConceptoCalificacionVC, @PeriodoVC,@MateriaVC
END
CLOSE crValidarCierrePeriodo
DEALLOCATE crValidarCierrePeriodo
IF (SELECT COUNT(ExisteConceptoCalif) FROM @TablaVadidaCierrePeriodo WHERE ExisteConceptoCalif =0) >= 1
BEGIN
DELETE FROM CED WHERE ID = @ID
DECLARE @TablaAux table(PeridoMateria varchar(255))
INSERT INTO  @TablaAux
SELECT DISTINCT 'Del periodo '+ CAST(PERIODO as varchar(2))+':'+ STUFF((SELECT DISTINCT ', ' + Materia FROM @TablaVadidaCierrePeriodo sub WHERE (sub.Periodo = cat.Periodo) and ExisteConceptoCalif =0 GROUP BY Periodo,Materia FOR XML PATH ('')),1,2,'') AS Materias
FROM @TablaVadidaCierrePeriodo cat WHERE ExisteConceptoCalif =0 GROUP BY Periodo,Materia 
SELECT @Ok = 1000192, @OkRef= STUFF((SELECT DISTINCT ' ' + PeridoMateria + CHAR(10) FROM @TablaAux FOR XML PATH('')),1,0,'')
END
END
IF @MovTipo IN ('CE.CEX','CE.TEX') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF NOT EXISTS(SELECT * FROM CEInfoAlumno WHERE Empresa = @Empresa AND @Alumno = Alumno AND EstatusPrograma = 'CURSANDO')
SELECT @OK = 1000182
END
DECLARE @ObtenerCuotasMovAlumno TABLE (NombreCuota varchar(50))
INSERT INTO @ObtenerCuotasMovAlumno
EXEC spCEObtenerCuotasMovAlumno @Empresa, @Mov, @CicloEscolar, @Programa, @PlanEstudios, @Alumno
IF (SELECT dbo.fnCEPestanaCuotas(@Mov)) = 1 AND @Accion <> 'CANCELAR' AND @Ok IS NULL
AND EXISTS (SELECT * FROM @ObtenerCuotasMovAlumno) AND @MovTipo NOT IN ('CE.IE','CE.CEX')
BEGIN
IF ((SELECT ISNULL(NombreCuotaIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000184
IF ((SELECT ISNULL(FechaInicioIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000186
IF ((SELECT ISNULL(FechaFinIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000187
IF (SELECT FechaInicioIE FROM CE WHERE ID = @ID) > (SELECT FechaFinIE FROM CE WHERE ID = @ID) AND @Ok IS NULL
SELECT @OK = 1000180
END
IF @MovTipo IN ('CE.IE','CE.CEX') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
IF ((SELECT ISNULL(NombreCuotaRecIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000185
IF @MovTipo IN ('CE.IE','CE.CEX') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF ((SELECT ISNULL(NombreCuotaIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000184
IF ((SELECT ISNULL(NombreCuotaRecIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000185
IF ((SELECT ISNULL(FechaInicioIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000186
IF ((SELECT ISNULL(FechaFinIE,'') FROM CE WHERE ID = @ID) = '') AND @Ok IS NULL
SELECT @Ok = 1000187
IF (SELECT FechaInicioIE FROM CE WHERE ID = @ID) > (SELECT FechaFinIE FROM CE WHERE ID = @ID) AND @Ok IS NULL
SELECT @OK = 1000180
END
IF @MovTipo IN ('CE.IE','CE.CEX') AND @Accion = 'CANCELAR' AND @Estatus = 'CONCLUIDO' AND @Ok IS NULL
BEGIN
IF (SELECT TOP 1 ID FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE' AND m.Clave IN ('CE.IE','CE.CEX') WHERE c.Alumno = @Alumno AND c.Estatus = 'CONCLUIDO' ORDER BY ID DESC) <> @ID
SELECT @OK = 60190, @OkRef = 'Cancele primero el Movimiento de ' + (SELECT TOP 1 m.Mov + ' ' + c.MovID FROM CE c JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE' AND m.Clave IN ('CE.IE','CE.CEX') WHERE c.Alumno = @Alumno AND c.Estatus = 'CONCLUIDO' ORDER BY ID DESC) + '.'
END
IF @MovTipo IN ('CE.IE') AND @Accion <> 'CANCELAR' AND @Ok IS NULL
BEGIN
IF EXISTS (SELECT d.Materia FROM CE c JOIN CED d ON c.ID = d.ID WHERE c.Empresa = @Empresa AND c.Alumno = @Alumno AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.Programa = @Programa AND EstatusD = 'CURSANDO') 
SELECT @OK = 1000183, @OkRef = @OkRef + 'Si requiere modificar esta Inscripción realice un Movimiento de Cambio.'
END
IF (SELECT UtilizarEste FROM EmpresaConcepto WHERE Empresa = @Empresa AND Modulo = 'CE' AND Mov IN (SELECT Mov FROM MovTipo WHERE Empresa = @Empresa AND Modulo = 'CE' AND Clave = @MovTipo)) = 1 AND @Ok IS NULL
UPDATE CE SET Concepto = (SELECT Concepto FROM EmpresaConcepto WHERE Empresa = @Empresa AND Modulo = 'CE' AND Mov IN (SELECT Mov FROM MovTipo WHERE Empresa = @Empresa AND Modulo = 'CE' AND Clave = @MovTipo)) WHERE ID = @ID
IF (SELECT Requerido FROM EmpresaConcepto WHERE Empresa = @Empresa AND Modulo = 'CE' AND Mov IN (SELECT Mov FROM MovTipo WHERE Empresa = @Empresa AND Modulo = 'CE' AND Clave = @MovTipo)) = 1 AND @Ok IS NULL
IF (SELECT Concepto FROM CE WHERE ID = @ID) NOT IN (select Concepto from EmpresaConceptoValidar WHERE Empresa = @Empresa AND Modulo = 'CE' AND Mov IN (SELECT Mov FROM MovTipo WHERE Empresa = @Empresa AND Modulo = 'CE' AND Clave = @MovTipo))
SELECT @Ok = 20485, @OkRef = RTRIM(@Mov)
DECLARE crVerificarDetalle CURSOR FOR
SELECT Renglon, Materia, Grupo, Nivel, Examen, Sesion, Ficha,	Calificacion, CalificacionEval, EstatusD,	Sobrecupo, Alumno, Aplica, AplicaID, AplicaRenglon, AlumnoCambio, TablaEvaluacion,CalificacionReconocida,Beca,Matricula,CicloEscolar,Programa,NivelAcademico,Asistencia,SucursalDestino,Asignacion, PlanEstudios,SubPrograma,CalifRecuperacion, FormaCalificacion
FROM CED d
WHERE d.ID = @ID
OPEN crVerificarDetalle
FETCH NEXT FROM crVerificarDetalle INTO @Renglon, @MateriaD, @GrupoD,	@Nivel,	@Examen,	@Sesion,	@Ficha,	@Calificacion, @CalificacionEval, @EstatusD,	@Sobrecupo,@AlumnoD	,@Aplica,@AplicaID,@AplicaRenglon,@AlumnoCambioD,@TablaEvaluacion,@CalificacionReconocida,@Beca,@MatriculaD,  @CicloEscolarD, @ProgramaD,@NivelAcademicoD,@Asistencia,@SucursalCambio,@AsignacionD,@PlanEstudiosD, @SubProgramaD,@CalifRecuperacion, @FormaCalificacion
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
IF @BloquearAdeudos= 1 AND @BloquearAdeudosMov= 1 AND @Autorizacion IS NULL AND @AlumnoD IS NOT NULL
BEGIN
SELECT @FacturaMultiple = FacturaMultiple FROM CEAlumno WHERE Alumno = @AlumnoD
SET @CteAlumno = NULL
IF @FacturaMultiple = 0
SELECT @CteAlumno =FacturarCte
FROM CEAlumno
WHERE Alumno = @AlumnoD
SELECT @SaldoCliente = SUM(Saldo)
FROM CxcInfo
WHERE Cliente = @CteAlumno
AND DiasMoratorios > CASE WHEN Saldo > 0 THEN 0 ELSE -1 END
IF  @FacturaMultiple = 0 AND @Autorizacion IS NULL  AND ISNULL(@SaldoCliente,0.0) > @ToleranciaRedondeo AND ISNULL(@SaldoCliente,0.0)>ISNULL(@MontoBloqueo, 0.0)
SELECT @Ok = 1000129, @OkRef = @OkRef + ' (' + @CteAlumno + ') Alumno (' + @AlumnoD + ')'
IF @FacturaMultiple = 1
BEGIN
DECLARE crCuotasMovAlumCxc CURSOR FOR
SELECT Cliente FROM CEAlumnoCxc WHERE Alumno =@Alumno
OPEN crCuotasMovAlumCxc
FETCH NEXT FROM crCuotasMovAlumCxc INTO @CteAlumno
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
SELECT @SaldoCliente = SUM(Saldo)
FROM CxcInfo WHERE Cliente = @CteAlumno
AND DiasMoratorios > CASE WHEN Saldo > 0 THEN 0 ELSE -1 END
IF @BloquearAdeudos= 1 AND @BloquearAdeudosMov= 1 AND @FacturaMultiple = 1 AND @Autorizacion IS NULL AND ISNULL(@SaldoCliente,0.0) > @ToleranciaRedondeo AND ISNULL(@SaldoCliente,0.0)>ISNULL(@MontoBloqueo, 0.0) 
SELECT @Ok = 1000129 ,@OkRef = @OkRef+ ' ('+@CteAlumno+') Alumno ('+@AlumnoD+')'
FETCH NEXT FROM crCuotasMovAlumCxc INTO @CteAlumno
END
CLOSE crCuotasMovAlumCxc
DEALLOCATE crCuotasMovAlumCxc
END
IF @Ok = 1000129 SELECT @Autorizar = 1
END
IF @MovTipo IN('CE.RI') AND @AlumnoD <> @Alumno
SELECT @Ok = 1000050
IF @MovTipo IN ('CE.A','CE.AC')
BEGIN
IF @EstatusNuevo = 'BORRADOR' AND @Alumno <> @AlumnoD
SELECT  @Ok = 1000174  ,@OkRef = @OkRef+ ' ('+@AlumnoD+')'
IF  @EstatusNuevo = 'PENDIENTE'
BEGIN
IF ISNULL(@Calificacion,'') = ''
SELECT @Ok = 1000026
IF ISNULL(@Examen,'') = ''
SELECT @Ok = 1000027
IF ISNULL(@Sesion,'') = ''
SELECT @Ok = 1000028
IF ISNULL(@Ficha,'') = ''
SELECT @Ok = 1000029
END
IF  @EstatusNuevo = 'BORRADOR'
BEGIN
IF ISNULL(@Examen,'') = ''
SELECT @Ok = 1000027
IF ISNULL(@Sesion,'') = ''
SELECT @Ok = 1000028
IF ISNULL(@Ficha,'')  = ''
SELECT @Ok = 1000029
END
END
IF @MovTipo IN ('CE.PRM','CE.RM') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
SELECT @CreditosPre = CreditosPreReq
FROM CEPlanEstudiosMaterias
WHERE Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
AND Programa = @Programa
AND Materia=@MateriaD
SELECT @SumaCreditos2 = SUM(Creditos)
FROM CEAlumnoMateriasProgramaAprobadas
WHERE Alumno = @Alumno
AND Empresa = @Empresa
AND PlanEstudios = @PlanEstudios
IF ISNULL(@SumaCreditos2,0) < ISNULL(@CreditosPre,0) AND @CfgCreditos=1
SELECT @Ok = 1000166, @OkRef = @OkRef+ ' ('+@MateriaD+')'
SELECT @IDOrigen = ID FROM CE WHERE Mov = @Origen AND MovID = @OrigenID AND Empresa = @Empresa
SELECT @NivelMateria = Nivel FROM CEMateria WHERE Materia = @MateriaD AND Empresa = @Empresa
IF @NivelMateria= 1
BEGIN
IF @Nivel IS NULL
SELECT @Ok = 1000072
IF NOT EXISTS (SELECT Nivel FROM CEMateriaNivel WHERE Empresa = @Empresa AND Materia = @MateriaD AND Nivel = @Nivel)AND @Nivel IS NOT NULL
SELECT @Ok = 1000073
END
IF (SELECT COUNT(Materia) FROM CED WHERE ID = @ID AND Materia = @MateriaD) > 1
SELECT @Ok = 1000077, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF @MovTipo = 'CE.PRM' AND @EstatusNuevo = 'PENDIENTE' AND @MovTipoOrigen <> 'CE.PRM'
IF EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE c.Estatus IN ('PENDIENTE','CONCLUIDO') AND d.Materia = @MateriaD AND c.Empresa = @Empresa AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.PlanEstudios = @PlanEstudios AND c.Programa = @Programa AND c.Alumno = @Alumno AND mt.Clave ='CE.PRM' AND d.EstatusD NOT IN('CANCELADO','BAJA') AND d.Grupo = @GrupoD) 
SELECT @Ok = 1000077, @OkRef = @OkRef+ 'La materia '+@MateriaD+ ' grupo ' + @GrupoD +' esta en el movimiento de PreRegistro ' + (SELECT c.MovID FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE c.Estatus IN ('PENDIENTE','CONCLUIDO') AND d.Materia = @MateriaD AND c.Empresa = @Empresa AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.PlanEstudios = @PlanEstudios AND c.Programa = @Programa AND c.Alumno = @Alumno AND mt.Clave ='CE.PRM' AND d.EstatusD NOT IN('CANCELADO','BAJA') AND d.Grupo = @GrupoD) + '. Si realizo un movimiento de baja para esta materia cancele el movimiento de baja para recuperarla o verifique si el grupo de la materia en este movimiento es correcto.'
IF @MovTipo = 'CE.PRM' AND @EstatusNuevo = 'PENDIENTE' AND @MovTipoOrigen = 'CE.PRM'
IF EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE c.Estatus IN ('PENDIENTE','CONCLUIDO') AND d.Materia = @MateriaD AND c.Empresa = @Empresa AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademico AND c.PlanEstudios = @PlanEstudios AND c.Programa = @Programa AND c.Alumno = @Alumno AND mt.Clave ='CE.PRM' AND d.EstatusD NOT IN('CANCELADO','BAJA') AND d.Materia NOT IN (SELECT Materia FROM CED WHERE ID = @IDOrigen AND EstatusD = 'PENDIENTE'))
SELECT @Ok = 1000077, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF EXISTS (SELECT Materia FROM CEAlumnoMateriasPrograma WHERE Materia = @MateriaD AND Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND NivelAcademico = @NivelAcademico AND PlanEstudios = @PlanEstudios AND Programa = @Programa AND Alumno = @Alumno AND Nivel = @Nivel AND Grupo = @GrupoD)
SELECT  @Ok = 1000034, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF (SELECT Nivel FROM CEMateria WHERE Empresa = @Empresa  AND  Materia = @MateriaD)=1 AND NULLIF(@Nivel,'') IS NULL
SELECT  @Ok = 1000036, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF NOT EXISTS (SELECT * FROM  CEMateriaGrupoCupo WHERE  Materia = @MateriaD AND Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Grupo = ISNULL(@GrupoD,@Grupo))
SELECT @Ok=1000008, @OkRef = @OkRef+ ' ('+ISNULL(@GrupoD,@Grupo)+')'
IF EXISTS(SELECT * FROM CEMateriaPrerequisitos WHERE Materia = @MateriaD AND Empresa = @Empresa)
BEGIN
DECLARE crVerificarPreRReq CURSOR FOR
SELECT MateriaPre
FROM CEMateriaPrerequisitos
WHERE Materia = @MateriaD AND Empresa = @Empresa
OPEN crVerificarPreRReq
FETCH NEXT FROM crVerificarPreRReq INTO  @MateriaPre
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
IF NOT EXISTS (SELECT Materia FROM CEAlumnoMateriasProgramaAprobadas WHERE Materia = @MateriaPre AND Empresa = @Empresa  AND Alumno = @Alumno)
SELECT  @Ok = 1000035, @OkRef = @OkRef+ ' ('+@MateriaD+') Materia PreRequisito ('+@MateriaPre+')'
FETCH NEXT FROM crVerificarPreRReq INTO  @MateriaPre
IF @@ERROR <> 0 SELECT @Ok = 1
END
CLOSE crVerificarPreRReq
DEALLOCATE crVerificarPreRReq
END
IF (SELECT Nivel FROM CEMateria WHERE Materia = @MateriaD AND Empresa = @Empresa)=1
BEGIN
IF @Nivel IS NULL
SELECT @OK = 1000048 ,@OkRef = @OkRef+ ' ('+@MateriaD+')'
IF NOT EXISTS(SELECT * FROM CEMateriaNivel WHERE Materia = @MateriaD AND Empresa = @Empresa AND Nivel = @Nivel)
SELECT @Ok  = 1000047 ,@OkRef = @OkRef+ ' ('+@MateriaD+') Nivel('+@Nivel+')'
END
IF @MovTipo = 'CE.RM'
BEGIN
INSERT @Tabla (Materia,Fecha,HoraInicio,HoraFin)
SELECT         Materia,Fecha,HoraInicio,HoraFin
FROM        CEAsignacionEspacioHorario
WHERE Empresa = @Empresa AND Cicloescolar = @CicloEscolar AND Grupo = @GrupoD AND Materia = @MateriaD  AND Asignacion = @AsignacionD
IF NOT EXISTS(SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo m ON c.Mov = m.Mov AND m.Modulo = 'CE'  WHERE m.Clave = 'CE.PRM' AND c.Estatus ='PENDIENTE' AND d.Materia = @MateriaD AND  d.EstatusD ='PENDIENTE'AND c.Alumno = @Alumno)
SELECT @Ok = 1000153 ,@OkRef = @OkRef+ ' ('+@MateriaD+')'
SELECT @Disponible = Disponible
FROM CEMateriaGrupoDisponible
WHERE Empresa = @Empresa
AND CicloEscolar = @CicloEscolar
AND Materia = @MateriaD
AND Grupo = @GrupoD
AND ISNULL(Nivel,'') = ISNULL(@Nivel,'')
AND Sucursal = @Sucursal
IF @Disponible < 1 AND @Sobrecupo = 0
SELECT @Ok = 1000154, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF @Disponible < 1 AND @Sobrecupo = 1 AND @Autorizacion IS NULL
SELECT @Ok = 1000194, @OkRef = @OkRef+ ' ('+@MateriaD+')'
IF @Ok = 1000194
SELECT @Autorizar = 1
END
END
IF @MovTipo IN ('CE.AS','CE.AAS','CE.CL','CE.ACL','CE.ACP','CE.RCP') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NOT EXISTS (SELECT * FROM CEAlumnoMateriasGrupoCursando WHERE NivelAcademico = @NivelAcademicoD AND Programa = @Programad AND Empresa = @Empresa  AND CicloEscolar = @CicloEscolar AND Grupo = @Grupo AND Alumno = @AlumnoD AND Sucursal = @Sucursal)
SELECT @Ok = 1000049, @OkRef = @OkRef+ ' ('+@AlumnoD+')'
IF NULLIF(@Asistencia,'') NOT IN ('Si','No','Ret.') AND @MovTipo IN ('CE.AS','CE.ASS','CE.ASB')
SELECT @Ok = 1000161 ,@OkRef = @OkRef+ 'Alumno ('+@AlumnoD+')'
IF NULLIF(@Calificacion,'') IS NULL AND @MovTipo IN ('CE.CL','CE.ACL','CE.ACP')
SELECT @Ok = 1000163, @OkRef = @OkRef+ 'Alumno ('+@AlumnoD+')'
IF NULLIF(@CalificacionEval,'') IS NULL AND @MovTipo IN ('CE.CL','CE.ACL','CE.ACP')
SELECT @Ok = 1000163, @OkRef = 'Verifique que la calificación del Alumno ' + @AlumnoD + ' se encuentra en las opciones de calificación'
IF NULLIF(@CalifRecuperacion,'') IS NULL AND @MovTipo IN ('CE.RCP')
SELECT @Ok = 1000163 ,@OkRef = @OkRef+ 'Alumno ('+@AlumnoD+')'
IF @MovTipo IN('CE.ASS','CE.ACL','CE.ACP','CE.ASB')
BEGIN
IF (SELECT Estatus FROM CE WHERE Mov = @Aplica AND MovID = @AplicaID AND Empresa = @Empresa ) <> 'CONCLUIDO'
SELECT @Ok = 1000052, @OkRef = @OkRef+ 'Mov. ('+@Aplica+' '+@AplicaID+')'
IF NOT EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID WHERE c.Mov = @Aplica AND c.MovID = @AplicaID AND c.Empresa = @Empresa AND d.Alumno = @AlumnoD AND d.EstatusD = 'CONCLUIDO' AND c.Estatus = 'CONCLUIDO')
SELECT @Ok = 1000050, @OkRef = @OkRef+ ' ('+@AlumnoD+')'
IF EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID WHERE c.Mov = @Aplica AND c.MovID = @AplicaID AND c.Empresa = @Empresa AND d.Alumno = @AlumnoD AND d.EstatusD = 'CANCELADO' AND c.Estatus = 'CONCLUIDO')
SELECT @Ok = 1000051, @OkRef = @OkRef+ ' ('+@Aplica+' '+@AplicaID+')'+' Alumno('+@AlumnoD+')'
END
IF @MovTipo IN('CE.ACL','CE.ACL','CE.ACP','CE.RCP','CE.HIS')AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @TablaEvaluacionCal = Calificacion FROM TablaEvaluacion WHERE TablaEvaluacion = @TablaEvaluacion
IF @TablaEvaluacion <> 'Numerica' AND @TablaEvaluacionCal = 'Cerrado' AND NOT EXISTS (SELECT * FROM TablaEvaluacionD WHERE TablaEvaluacion = @TablaEvaluacion AND Nombre = @CalifRecuperacion) AND @MovTipo IN ('CE.RCP')
SELECT @OK = 1000060
IF @TablaEvaluacion <> 'Numerica' AND @TablaEvaluacionCal = 'Cerrado' AND NOT EXISTS (SELECT * FROM TablaEvaluacionD WHERE TablaEvaluacion = @TablaEvaluacion AND Nombre = @Calificacion) AND @MovTipo NOT IN ('CE.RCP')
SELECT @OK = 1000060
IF (@TablaEvaluacion = 'Numerica' OR @TablaEvaluacionCal = 'Abierto') AND ISNUMERIC(@CalifRecuperacion)= 0 AND @MovTipo IN ('CE.RCP','CE.HIS')
SELECT @OK = 1000060
IF (@TablaEvaluacion = 'Numerica' OR @TablaEvaluacionCal = 'Abierto') AND ISNUMERIC(@Calificacion)= 0 AND @MovTipo NOT IN ('CE.RCP','CE.HIS')
SELECT @OK = 1000060
END
END
IF @MovTipo IN ('CE.C') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF EXISTS (SELECT * FROM CE c JOIN CED d ON c.ID = d.ID JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE'
WHERE c.Alumno = @AlumnoCambioD AND c.Estatus IN ('PENDIENTE') AND mt.Clave IN ('CE.PRE','CE.RM'))
SELECT @Ok = 1000173 ,@OkRef = @OkRef+ ' Alumno  ('+@AlumnoCambioD+')'
IF  (@MatriculaD IS NULL) OR (@MatriculaD = '') AND @MatriculaIDAlumno = 0 AND @CambioMatricula = 1 
BEGIN
IF(SELECT Sucursal FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @SucursalCambio  AND @SucursalCambio IS NOT NULL AND @CambioMatriculaPlantel  = 1
SELECT @Ok = 1000031
IF(SELECT CicloEscolar FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @CicloEscolarD  AND @CicloEscolarD IS NOT NULL AND @CambioMatriculaCicloEscolar = 1
SELECT @Ok = 1000031
IF (SELECT Programa FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @ProgramaD AND @ProgramaD IS NOT NULL AND @CambioMatriculaPrograma  = 1
SELECT @Ok = 1000031
IF (SELECT NivelAcademico FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @NivelAcademicoD AND @NivelAcademicoD IS NOT NULL AND @CambioMatriculaNivel  = 1
SELECT @Ok = 1000031
END
IF @MatriculaD IS NOT NULL
BEGIN
IF @MatriculaIDAlumno = 1  AND @AlumnoCambioD <> ISNULL(@MatriculaD,@AlumnoCambioD)
SELECT @Ok = 1000022
IF @CambioMatricula = 0 AND  (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @MatriculaD
SELECT @Ok = 1000138
IF @CicloEscolarD IS NOT NULL
IF  @CambioMatriculaCicloEscolar  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD
AND (SELECT CicloEscolar FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @CicloEscolarD  AND @CicloEscolarD IS NOT NULL
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @ProgramaD IS NOT NULL
IF  @CambioMatriculaPrograma  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT Programa FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @ProgramaD
SELECT @Ok = 1000139  ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @NivelAcademicoD IS NOT NULL
IF  @CambioMatriculaNivel  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT NivelAcademico FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @NivelAcademicoD
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @SucursalCambio IS NOT NULL
IF  @CambioMatriculaPlantel  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT Sucursal FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @SucursalCambio
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF EXISTS (SELECT * FROM CEMatriculaAlumno WHERE Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Matricula = @MatriculaD)
SELECT @Ok = 1000152, @OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
END
END
IF @MovTipo IN ('CE.CA') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF  (@MatriculaD IS NULL) OR (@MatriculaD = '') AND @MatriculaIDAlumno = 0 AND @CambioMatricula = 1 
BEGIN
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudiosD AND Programa = @ProgramaD AND Estatus = 'Activo' )AND @PlanEstudiosD IS NOT NULL AND @ProgramaD IS NOT NULL
SELECT @Ok = 1000202
IF NOT EXISTS (SELECT PlanEstudios FROM CEPLanEstudios WHERE PlanEstudios = @PlanEstudiosD AND Programa = @ProgramaD )AND @PlanEstudiosD IS NOT NULL AND @ProgramaD IS NOT NULL
SELECT @Ok = 1000201
IF NOT EXISTS (SELECT SubPrograma FROM CESubPrograma WHERE SubPrograma = @SubPrograma AND Programa = @ProgramaD AND Empresa = @Empresa AND Estatus = 'Activo'  ) AND @SubPrograma NOT IN (NULL,'')AND @ProgramaD IS NOT NULL
SELECT @Ok = 1000200
IF NOT EXISTS (SELECT * FROM CEPrograma WHERE NivelAcademico = @NivelAcademicoD AND Programa = @ProgramaD AND Empresa = @Empresa AND Estatus = 'Activo' )AND @ProgramaD IS NOT NULL AND @NivelAcademicoD IS NOT NULL
SELECT @Ok = 1000199
IF NOT EXISTS (SELECT NivelAcademico FROM CENivelAcademico WHERE NivelAcademico = @NivelAcademicoD AND Estatus = 'Activo' )AND @NivelAcademicoD IS NOT NULL
SELECT @Ok = 1000198
IF(SELECT Sucursal FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @SucursalCambio  AND @SucursalCambio IS NOT NULL AND @CambioMatriculaPlantel  = 1
SELECT @Ok = 1000031
IF(SELECT CicloEscolar FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @CicloEscolarD  AND @CicloEscolarD IS NOT NULL AND @CambioMatriculaCicloEscolar = 1
SELECT @Ok = 1000031
IF (SELECT Programa FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @ProgramaD AND @ProgramaD IS NOT NULL AND @CambioMatriculaPrograma  = 1
SELECT @Ok = 1000031
IF (SELECT NivelAcademico FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @NivelAcademicoD AND @NivelAcademicoD IS NOT NULL AND @CambioMatriculaNivel  = 1
SELECT @Ok = 1000031
END
IF @MatriculaD IS NOT NULL
BEGIN
IF @MatriculaIDAlumno = 1  AND @AlumnoCambioD <> ISNULL(@MatriculaD,@AlumnoCambioD)
SELECT @Ok = 1000022
IF @CambioMatricula = 0 AND  (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @MatriculaD
SELECT @Ok = 1000138
IF @CicloEscolarD IS NOT NULL
IF  @CambioMatriculaCicloEscolar  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD
AND (SELECT CicloEscolar FROM CEAlumno WHERE Alumno = @AlumnoCambioD)  <> @CicloEscolarD  AND @CicloEscolarD IS NOT NULL
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @ProgramaD IS NOT NULL
IF  @CambioMatriculaPrograma  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT Programa FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @ProgramaD
SELECT @Ok = 1000139  ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @NivelAcademicoD IS NOT NULL
IF  @CambioMatriculaNivel  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT NivelAcademico FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @NivelAcademicoD
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF @SucursalCambio IS NOT NULL
IF  @CambioMatriculaPlantel  = 1 AND (SELECT Matricula FROM CEAlumno WHERE Alumno = @AlumnoCambioD) = @MatriculaD   AND
(SELECT Sucursal FROM CEAlumno WHERE Alumno = @AlumnoCambioD) <> @SucursalCambio
SELECT @Ok = 1000139 ,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
IF EXISTS (SELECT * FROM CEMatriculaAlumno WHERE Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Matricula = @MatriculaD)
SELECT @Ok = 1000152,@OkRef = @OkRef+ 'Alumno  ('+@AlumnoCambioD+')'
END
END
IF @MovTipo IN ('CE.RE') AND @EstatusNuevo IN ('CONCLUIDO','PENDIENTE')
BEGIN
IF @CalifMinimaMateria = 1
SELECT @CalificacionMateria = CalificacionMinima FROM CEMateria WHERE Empresa = @Empresa AND Materia = @Materia
ELSE
SELECT  @CalificacionMateria = CalifMinimaMateria FROM CEPLanEstudios WHERE Empresa = @Empresa AND PlanEstudios = @PlanEstudios AND Programa = @Programa
IF EXISTS (SELECT * FROM CEAlumnoMateriasProgramaAprobadas  WHERE  Alumno = @Alumno AND Materia = @MateriaD AND PlanEstudios = @PlanEstudios AND Programa = @Programa)
SELECT @Ok = 1000083, @OkRef = @OkRef+ ' (' + @MateriaD + ')'
IF  dbo.fnCalificacion(@TablaEvaluacion,@CalificacionReconocida) < @CalificacionMateria
SELECT @Ok = 1000084, @OkRef = @OkRef + ' (' + @MateriaD + ')'
END
IF @MovTipo IN ('CE.RI') AND @EstatusNuevo IN ('CONCLUIDO','PENDIENTE')
BEGIN
IF EXISTS (SELECT * FROM CEAlumnoMateriasProgramaAprobadas  WHERE  Alumno = @Alumno AND Materia = @MateriaD AND PlanEstudios = @PlanEstudios AND Programa = @Programa)
SELECT @Ok = 1000083, @OkRef = @OkRef + ' (' + @MateriaD + ')'
END
--IGGR
--09/11/2023. IGGR. Esta validación se omite para que no impida la asignacion de alumnos al movimiento de calificaciones y calificaciones Extenporaneas
/*IF @MovTipo IN('CE.CL','CE.AS','CE.CP') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF  EXISTS(SELECT Alumno FROM CEAlumnoMateriasGrupoCursando WHERE Materia = @Materia AND Grupo = @Grupo AND CicloEscolar = @CicloEscolar AND NivelAcademico = @NivelAcademicoD AND Programa = @ProgramaD AND PlanEstudios = @PlanEstudiosD AND Sucursal = @Sucursal UNION SELECT  Alumno FROM  CED WHERE ID = @ID)
SELECT @OK= 1000063, @OkRef = @OkRef + ' (' + (SELECT TOP 1 Alumno FROM (SELECT Alumno FROM CEAlumnoMateriasGrupoCursando WHERE Materia = @Materia AND Grupo = @Grupo AND CicloEscolar = @CicloEscolar AND NivelAcademico = @NivelAcademicoD AND Programa = @ProgramaD AND PlanEstudios = @PlanEstudiosD AND Sucursal = @Sucursal EXCEPT SELECT  Alumno FROM  CED WHERE ID = @ID)As t) + ')'
END*/
IF @MovTipo IN('CE.CP') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @NivelMateria = Nivel,
@FormaMateria = FormaMateria
FROM CEMateria
WHERE Materia = @Materia
AND Empresa = @Empresa
IF @FormaMateria <> 'Agrupada'
AND EXISTS (SELECT * FROM CE c JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE mt.Clave = 'CE.CP' AND c.Estatus = 'CONCLUIDO' AND c.Empresa = @Empresa AND c.Materia = @Materia AND c.Grupo = @Grupo AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademicoD AND c.Programa = @ProgramaD AND c.PlanEstudios = @PlanEstudiosD  AND c.PeriodoAsig = @PeriodoAsignacion)
SELECT @OK= 1000065
IF @FormaMateria = 'Agrupada'
BEGIN
IF @SubMateria IS NULL
SELECT @Ok = 1000070
IF NOT EXISTS (SELECT MateriaGrupo FROM CEMateriaGrupo WHERE Empresa = @Empresa AND Materia = @Materia AND MateriaGrupo = @SubMateria)AND @SubMateria IS NOT NULL
SELECT @Ok = 1000071
IF EXISTS (SELECT * FROM CE c JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE mt.Clave = 'CE.CP' AND c.Estatus = 'CONCLUIDO' AND c.Empresa = @Empresa AND c.Materia = @Materia AND c.Grupo = @Grupo AND c.CicloEscolar = @CicloEscolar AND c.NivelAcademico = @NivelAcademicoD AND c.Programa = @ProgramaD AND c.PlanEstudios = @PlanEstudiosD  AND c.PeriodoAsig = @PeriodoAsignacion AND c.SubMateria = @SubMateria )
SELECT @OK= 1000065
END
IF @NivelMateria= 1
BEGIN
IF @NivelEnc IS NULL
SELECT @Ok = 1000072
IF NOT EXISTS (SELECT Nivel FROM CEMateriaNivel WHERE Empresa = @Empresa AND Materia = @Materia AND Nivel = @NivelEnc)AND @NivelEnc IS NOT NULL
SELECT @Ok = 1000073
END
IF (SELECT CONVERT(int,Periodo) FROM CEPLanEstudiosMaterias WHERE Materia = @Materia AND Empresa = @Empresa AND PlanEstudios = @PlanEstudiosD AND Programa = @ProgramaD AND ISNULL(SubPrograma,'') = ISNULL(@SubPrograma,''))>@PeriodoAsignacion
SELECT @Ok = 1000101
IF @PeriodoAsignacion IS NULL
SELECT @Ok = 1000100
END
IF @MovTipo IN ('CE.CP') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NOT EXISTS(SELECT * FROM CEAlumnoMateriasProgramaCursando WHERE Empresa = @Empresa AND Materia = @Materia AND Alumno = @AlumnoD AND NivelAcademico = @NivelAcademicoD AND Programa = @ProgramaD  AND PlanEstudios = @PlanEstudiosD AND Grupo = @Grupo)
SELECT @Ok = 1000095, @OkRef = @OkRef + ' (' + @AlumnoD + ')'
IF NULLIF(@Calificacion,'') IS NULL
SELECT @Ok = 1000096, @OkRef = @OkRef + ' (' + @AlumnoD + ')'
END
IF @MovTipo IN ('CE.CC') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
IF NULLIF(@Calificacion,'') IS NULL
SELECT @Ok = 1000098 ,@OkRef = @OkRef + ' (' + @MateriaD + ')'
END
IF @MovTipo IN ('CE.EXT') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NULLIF(@Calificacion,'') IS NULL
SELECT @Ok = 1000097
END
IF (@MovTipo IN ('CE.B') AND @EstatusNuevo = 'CONCLUIDO') OR (@MovTipo IN ('CE.SB') AND @EstatusNuevo = 'PENDIENTE')
BEGIN
DECLARE @BecasCascada bit = (SELECT BecasCascada FROM EmpresaCfgCE WHERE Empresa = @Empresa)
DECLARE @DescBeca  Table (Beca varchar(50), Porc float)
DECLARE @DescBeca2 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca3 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca4 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca5 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca6 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca7 Table (Beca varchar(50), Porc float)
DECLARE @DescBeca8 Table (Beca varchar(50), Porc float)
SELECT  @PromedioMinimo         = PromedioMinimo,
@NoMaterias             = NoMaterias,
@AplicaTodosProgramas   = AplicaTodosProgramas,
@CantidadMaxBeca        = CantidadMax,
@NoCreditos             = NoCreditos,
@NoReprobado            = NoReprobado,
@NuevoIngreso           = NuevoIngreso,
@TipoReprobado          = TipoReprobado,
@FamEmpleado            = FamEmpleado,
@PorcDescBeca           = PorcdeDesc,
@HorasServicio          = HorasServicioBecario,
@RenovarBecaSinCubrirSB = RenovarBecaSinCubrirSB
FROM  CEBecaCiclo
WHERE  Empresa = @Empresa
AND  Ciclo   = @CicloEscolar
AND  Beca    = @Beca
SELECT  @CicloEscolarAnterior = CicloAnterior
FROM  CECicloEscolar
WHERE  Empresa = @Empresa AND CicloEscolar = @CicloEscolar
IF EXISTS (SELECT *
FROM CE a
JOIN Movtipo  b ON a.Mov = b.Mov AND Clave = 'CE.SBE'
WHERE a.Empresa      = @Empresa
AND a.Alumno       = @Alumno
AND a.CicloEscolar = @CicloEscolar
AND a.Estatus      = 'PENDIENTE')
UPDATE CE SET Horas = @HorasServicio
FROM CE a
JOIN Movtipo  b ON a.Mov = b.Mov AND Clave = 'CE.SBE'
WHERE a.Empresa      = @Empresa
AND a.Alumno       = @Alumno
AND a.CicloEscolar = @CicloEscolar
AND a.Estatus      = 'PENDIENTE'
IF @RenovarBecaSinCubrirSB = 0 
IF EXISTS (SELECT * FROM CE a
JOIN Movtipo b ON a.Mov = b.Mov AND Clave IN ('CE.SBE')
WHERE Empresa        =  @Empresa
AND CicloEscolar   <> @CicloEscolar
AND NivelAcademico =  @NivelAcademico
AND Programa       =  @Programa
AND PlanEstudios   =  @PlanEstudios
AND Alumno         =  @Alumno
AND Estatus        =  'PENDIENTE')
SELECT @Ok = 1000208 
IF @ServicioBecario = 1 AND @Ok IS NULL 
IF NOT EXISTS (SELECT * FROM CE a
JOIN Movtipo b ON a.Mov = b.Mov AND Clave IN ('CE.SPSB')
WHERE Empresa        = @Empresa
AND CicloEscolar   = @CicloEscolar
AND NivelAcademico = @NivelAcademico
AND Programa       = @Programa
AND PlanEstudios   = @PlanEstudios
AND Alumno         = @Alumno
AND Estatus        IN('CONCLUIDO','PENDIENTE'))
SELECT @Ok    = 1000207, 
@OkRef = @OkRef + @CicloEscolar
IF ((SELECT CubreAdmision FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreAdmision = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Admisión'
END
IF ((SELECT CubreInscripcion FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca2(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca2
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreInscripcion = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Inscripción'
END
IF ((SELECT CubreColegiatura FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca3(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca3
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreColegiatura = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Colegiatura'
END
IF ((SELECT CubreServicioSocial FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca4(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca4
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreServicioSocial = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Servicio Social'
END
IF ((SELECT CubreTitulacion FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca5(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca5
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreTitulacion = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126, @OkRef = ' Beca('+@Beca+') Cubre Titulación'
END
IF ((SELECT CubreExtraordinario FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT @DescBeca6(Beca,Porc)
SELECT @Beca,@PorcDescBeca
SELECT @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM @DescBeca6
SELECT @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM CEBecasActivas a
JOIN CEBecaCiclo b ON a.Beca = b.Beca
WHERE a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreExtraordinario = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Examen Extraordinario'
END
IF ((SELECT CubreCuotasAdicionales FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT  @DescBeca7(Beca,Porc)
SELECT  @Beca,@PorcDescBeca
SELECT  @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM  @DescBeca7
SELECT  @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM  CEBecasActivas a
JOIN  CEBecaCiclo b ON a.Beca = b.Beca
WHERE  a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreCuotasAdicionales = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Adicionales'
END
IF ((SELECT CubreOtros FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1 OR (SELECT CubreTodo FROM CEBecaCiclo WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca) = 1) AND @BecasCascada <> 1 AND @Ok IS NULL
BEGIN
INSERT  @DescBeca8(Beca,Porc)
SELECT  @Beca,@PorcDescBeca
SELECT  @SumaBeca = ISNULL(SUM(Porc),0.0)
FROM  @DescBeca8
SELECT  @SumaBecaActiva =  ISNULL(SUM(a.PorcdeDesc),0.0)
FROM  CEBecasActivas a
JOIN  CEBecaCiclo b ON a.Beca = b.Beca
WHERE  a.Empresa = @Empresa AND b.Empresa = @Empresa AND a.Alumno = @Alumno AND a.CicloEscolar = @CicloEscolar AND b.Ciclo = @CicloEscolar AND (b.CubreOtros = 1 OR b.CubreTodo = 1)
IF (@SumaBeca + @SumaBecaActiva) > 100
SELECT @Ok = 1000126 ,@OkRef = ' Beca('+@Beca+') Cubre Otros'
END
SELECT @CantidadBeca = COUNT(*) FROM CEBecasActivas WHERE Empresa = @Empresa AND CicloEscolar = @CicloEscolar  AND Beca = @Beca
SELECT @CantidadMateria = COUNT(*)  FROM CEAlumnoMateriasCursadas  WHERE Alumno = @Alumno AND Forma <> 'NA'
SELECT @Creditos = ISNULL(SUM(p.Creditos),0)  FROM CEAlumnoMateriasCursadas a  JOIN CEPLanEstudiosMaterias p ON a.Empresa = p.Empresa AND p.PlanEstudios = a.PlanEstudios AND p.Programa = a.Programa AND a.Materia = p.Materia WHERE a.Alumno = @Alumno AND a.Forma <> 'NA'
SELECT @Reprobados = COUNT(*) FROM CECalificacionCierreCiclo
WHERE Alumno = @Alumno AND CicloEscolar =  @CicloEscolarAnterior AND EstatusD = 'Reprobado'
SELECT @ReprobadosAcum = COUNT(*) FROM CECalificacionCierreCiclo
WHERE Alumno = @Alumno AND EstatusD = 'Reprobado'
IF NOT EXISTS (SELECT * FROM CE c JOIN MovTipo mt ON c.Mov = mt.Mov AND mt.Modulo = 'CE' WHERE  c.Alumno = @Alumno AND mt.Clave IN ('CE.CC','CE.RCC') AND c.Estatus IN('PENDIENTE','CONCLUIDO'))AND @NuevoIngreso = 0 AND @Ok IS NULL
SELECT @Ok = 1000111,@OkRef = ' Beca('+@Beca+')'
IF @AplicaTodosProgramas = 0 AND NOT EXISTS (SELECT * FROM CEBecaCicloPrograma WHERE Empresa = @Empresa AND Ciclo = @CicloEscolar AND Beca = @Beca AND Programa = @Programa) AND @Ok IS NULL
SELECT @Ok = 1000102 ,@OkRef =' Beca('+@Beca+')'+' Programa('+@Programa+')'
IF @CantidadMaxBeca IS NOT NULL
IF ISNULL(@CantidadBeca,0)+1 >  ISNULL(@CantidadMaxBeca,0) AND @Ok IS NULL
SELECT @Ok = 1000103,@OkRef = ' Beca('+@Beca+')'
IF  ISNULL(@CalificacionProm,0.0) < ISNULL(@PromedioMinimo,0.0) AND @NuevoIngreso = 1 AND  @MovTipo = 'CE.B' AND @Ok IS NULL
SELECT @Ok = 1000104,@OkRef = ' Beca('+@Beca+')'
IF ISNULL(@CantidadMateria,0) < ISNULL(@NoMaterias,0) AND @Ok IS NULL
SELECT @Ok = 1000105,@OkRef = ' Beca('+@Beca+')'
IF ISNULL(@Creditos,0) < ISNULL(@NoCreditos,0) AND @MovTipo IN ('CE.B') AND @CfgCreditos=1 AND @Ok IS NULL
SELECT @Ok = 1000106,@OkRef = ' Beca('+@Beca+')'
IF ISNULL(@Reprobados,0) > ISNULL(@NoReprobado,0) AND @TipoReprobado = 'Ciclo Anterior' AND @Ok IS NULL
SELECT @Ok = 1000107,@OkRef = ' Beca('+@Beca+')'
IF ISNULL(@ReprobadosAcum,0) > ISNULL(@NoReprobado,0) AND @TipoReprobado = 'Acumulado' AND @Ok IS NULL
SELECT @Ok = 1000107,@OkRef = ' Beca('+@Beca+')'
IF  NOT EXISTS (SELECT * FROM CEBecaCiclo WHERE Beca = @Beca AND Empresa = @Empresa AND Ciclo = @CicloEscolar)
SELECT @Ok = 1000112,@OkRef = @OkRef+ ' Beca('+@Beca+')'
IF  NOT EXISTS (SELECT * FROM CEBeca WHERE Beca = @Beca AND Empresa = @Empresa) AND @Ok IS NULL
SELECT @Ok = 1000110,@OkRef = ' Beca('+@Beca+')'
IF @NuevoIngreso = 0 AND  @MovTipo = 'CE.B' AND @Ok IS NULL
BEGIN
SELECT @CalificacionProm = CalificacionEval FROM CECalificacionPlanEstudios WHERE Empresa = @Empresa AND Alumno = @Alumno AND CicloEscolar = @CicloEscolarAnterior
IF  ISNULL(@CalificacionProm,0.0) < ISNULL(@PromedioMinimo,0.0)
SELECT @Ok = 1000104,@OkRef = ' Beca('+@Beca+')'
END
IF @FamEmpleado = 1 AND NOT EXISTS (SELECT * FROM CEAlumno a JOIN CEFamilia f ON a.Familia = f.Familia
JOIN CEFamiliaIntegrantes i ON i.Familia = f.Familia
JOIN CEContactoFamilia c ON c.Familia = f.Familia
JOIN CEContacto co ON co.Contacto = c.Contacto
WHERE a.Alumno = @Alumno AND co.Personal IN (SELECT Personal FROM Personal /*WHERE Estatus = 'ALTA'*/)  ) AND @Ok IS NULL
SELECT @Ok = 1000113, @OkRef = ' Beca('+@Beca+')' + ' Alumno('+@Alumno+')'
IF NULLIF(@Beca,'') IS NULL
SELECT @Ok = 1000110
END
IF @MovTipo IN ('CE.BB') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NOT EXISTS (SELECT * FROM CEBecasActivas WHERE Alumno = @Alumno AND Empresa = @Empresa AND CicloEscolar = @CicloEscolar AND Beca = @Beca)
SELECT @Ok = 1000108,@OkRef = @OkRef+ ' Beca('+@Beca+')'
END
IF @MovTipo IN ('CE.EP','CE.CT') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
IF NULLIF(@Calificacion,'')IS NULL
SELECT @Ok = 1000026,@OkRef = @OkRef+ ' Alumno('+@AlumnoCambioD+')'
END
IF @MovTipo IN ('CE.BM') AND @EstatusNuevo = 'CONCLUIDO'
BEGIN
SELECT @IDOrigen = ID  FROM CE WHERE Mov = @Aplica AND MovID = @AplicaID AND Empresa = @Empresa
IF (SELECT Estatus FROM CE WHERE ID = @IDOrigen )IN ('CANCELADO','CONCLUIDO')
SELECT @OK = 1000055,@OkRef = @OkRef+ ' Materia('+@MateriaD+')'
IF (SELECT EstatusD FROM CED WHERE ID = @IDOrigen AND Renglon = @AplicaRenglon )IN ('CANCELADO','CONCLUIDO')
SELECT @OK = 1000055,@OkRef = @OkRef+ ' Materia('+@MateriaD+')'
END
IF  (SELECT Estatus FROM CEAlumno WHERE Alumno = @AlumnoD) NOT IN ('Alta') AND @MovTipo  IN('CE.AS','CE.AAS' ,'CE.CL','CE.ACL','CE.CP','CE.ACP','CE.RCP')
SELECT @Ok = 1000012
IF  (SELECT Estatus FROM CEAlumno WHERE Alumno = @AlumnoCambioD)NOT IN ('Alta') AND @MovTipo  IN('CE.EP','CE.T','CE.RT','CE.CT')
SELECT @Ok = 1000012
IF @MovTipo IN ('CE.HIS') AND @EstatusNuevo IN('CONCLUIDO') AND @Ok IS NULL 
BEGIN
IF @MateriaD IN (SELECT Materia FROM CEAlumnoMateriasProgramaAprobadas WHERE Alumno = @Alumno) OR @MateriaD IN (SELECT Materia FROM CEAlumnoMateriasProgramaReprobadas WHERE Alumno = @Alumno) SELECT @Ok = 1000034 , @OkRef = @OkRef + @MateriaD
IF @Calificacion      IN (NULL,'') AND @Ok IS NULL SELECT @Ok = 1000026 , @OkRef = @OkRef + @MateriaD
IF @EstatusD          IN (NULL,'') AND @Ok IS NULL SELECT @Ok = 1000188, @OkRef = @OkRef + @MateriaD
IF @FormaCalificacion IN (NULL,'') AND @Ok IS NULL SELECT @Ok = 1000189, @OkRef = @OkRef + @MateriaD
END
FETCH NEXT FROM crVerificarDetalle INTO @Renglon, @MateriaD, @GrupoD,	@Nivel,	@Examen,	@Sesion,	@Ficha,	@Calificacion, @CalificacionEval, @EstatusD,	@Sobrecupo,@AlumnoD	,@Aplica,@AplicaID,@AplicaRenglon,@AlumnoCambioD,@TablaEvaluacion,@CalificacionReconocida,@Beca,@MatriculaD,  @CicloEscolarD, @ProgramaD,@NivelAcademicoD,@Asistencia,@SucursalCambio,@AsignacionD,@PlanEstudiosD, @SubProgramaD, @CalifRecuperacion, @FormaCalificacion
IF @@ERROR <> 0 SELECT @Ok = 1
END
CLOSE crVerificarDetalle
DEALLOCATE crVerificarDetalle
END
IF @MovTipo IN ('CE.RM','CE.PRM') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
INSERT @Tabla2 (Materia,Fecha,HoraInicio,HoraFin)
SELECT         Materia,Fecha,HoraInicio,HoraFin
FROM  CEAlumnoHorario
WHERE Empresa = @Empresa AND Cicloescolar = @CicloEscolar AND Alumno = @Alumno AND Estatus = 'RESERVADO' AND Sucursal = @Sucursal  AND Materia NOT IN (SELECT MateriaCambio FROM CED WHERE ID = @ID)
DECLARE crHorarioAlumno CURSOR FOR
SELECT Materia,Fecha,HoraInicio,HoraFin
FROM @Tabla
ORDER BY Fecha,Materia
OPEN crHorarioAlumno
FETCH NEXT FROM crHorarioAlumno INTO @MateriaA,@Fecha, @HDesde, @HHasta
WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
BEGIN
IF EXISTS (SELECT * FROM @Tabla2 WHERE  Fecha = @Fecha AND HoraInicio >=@HDesde AND HoraFin <= @HHasta AND Materia <> @MateriaA
OR Fecha = @Fecha AND @HDesde >=HoraInicio AND @HHasta <= HoraFin AND Materia <> @MateriaA
OR  Fecha = @Fecha AND HoraInicio BETWEEN @HDesde AND dbo.fnRestarHoras(@HHasta,'00:01') AND Materia <> @MateriaA
OR  Fecha = @Fecha AND HoraFin BETWEEN dbo.fnSumarHoras(@HDesde,'00:01') AND @HHasta AND Materia <> @MateriaA)
BEGIN
SELECT @MateriaEmp = Materia FROM @Tabla2 WHERE  Fecha = @Fecha AND HoraInicio >=@HDesde AND HoraFin <= @HHasta AND Materia <> @MateriaA
OR Fecha = @Fecha AND @HDesde >=HoraInicio AND @HHasta <= HoraFin AND Materia <> @MateriaA
OR  Fecha = @Fecha AND HoraInicio BETWEEN @HDesde AND dbo.fnRestarHoras(@HHasta,'00:01') AND Materia <> @MateriaA
OR  Fecha = @Fecha AND HoraFin BETWEEN dbo.fnSumarHoras(@HDesde,'00:01') AND @HHasta AND Materia <> @MateriaA
SELECT @OK = 1000064, @OkRef = @OkRef+ 'La Materia '+@MateriaA+' y la Materia ' + @MateriaEmp + ' Se empalman el '+ CASE CONVERT(varchar,DATEPART(dw, CONVERT(varchar,@Fecha))) WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN 'Miércoles' WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sábado' WHEN 7 THEN 'Domingo' END  + ' de '+@HDesde+' a '+@HHasta
END
ELSE
INSERT @Tabla2 (Materia,Fecha,HoraInicio,HoraFin)
SELECT  @MateriaA,@Fecha, @HDesde, @HHasta
FETCH NEXT FROM crHorarioAlumno INTO  @MateriaA,@Fecha, @HDesde, @HHasta
IF @@ERROR <> 0 SELECT @Ok = 1
END
CLOSE crHorarioAlumno
DEALLOCATE crHorarioAlumno
END
IF @Ok IS NULL AND (SELECT CEHorarioAlumnoRegMat FROM CEPLanEstudios WHERE Empresa = @Empresa AND Programa = @Programa AND PlanEstudios = @PlanEstudios) = 1
BEGIN
IF @MovTipo IN ('CE.RM') AND @EstatusNuevo = 'PENDIENTE'
BEGIN
DECLARE @FechaInicioSes   datetime,
@FechaFinSes      datetime,
@HoraInicioSes    datetime,
@HoraFinSes       datetime,
@HoraLimiteSes    datetime,
@HoraLimiteSes2   varchar(20),
@HoraInicio		varchar(20),
@HoraFin			varchar(20),
@InicioSes        datetime,
@FinSes           datetime,
@MensajeFechaSes  varchar(11),
@MensajeHoraSes   varchar(10),
@CicloRegMat      varchar(20),
@AlumnoRegMat		bit = 0;
SELECT  @FechaInicioSes = SR.FechaInicio,
@HoraInicioSes  = SR.HoraInicio,
@HoraInicio	  = SR.HoraInicio,
@FechaFinSes    = SR.FechaFin,
@HoraFinSes     = SR.HoraFin,
@HoraFin		  = SR.HoraFin,
@HoraLimiteSes  = SR.Horalimite,
@HoraLimiteSes2 = SR.Horalimite,
@CicloRegMat    = H.CicloEscolar,
@AlumnoRegMat	  = 1
FROM  CEAlumno A
JOIN CESesionAlumnoRegMaterias SA ON A.Alumno = SA.Alumno
JOIN CESesionRegistroMaterias SR ON SA.Clave   = SR.Clave AND SA.Sesion  = SR.Sesion
JOIN CEAsignacionEspacioHorario AE ON SA.Clave = AE.Materia AND SR.FechaInicio = AE.Fecha AND SR.HoraInicio = AE.HoraInicio AND SR.HoraFin = AE.HoraFin AND AE.Estatus ='RESERVADO'
JOIN CEHorarioAlumnoRegMaterias H ON SR.Clave = H.Clave
JOIN CENivelAcademicoRegMaterias NR ON H.Clave = NR.Clave AND A.NivelAcademico = NR.NivelAcademico
WHERE  A.Alumno = @Alumno AND H.CicloEscolar = @CicloEscolar AND H.Plantel = @Sucursal AND NR.NivelAcademico = @NivelAcademico
IF @CicloEscolar = @CicloRegMat AND @AlumnoRegMat = 1
BEGIN
IF @FechaInicioSes IS NOT NULL
SET @InicioSes = @FechaInicioSes + @HoraInicioSes
IF (@HoraLimiteSes2 IS NOT NULL) OR (@HoraLimiteSes2 <> '') OR (@HoraLimiteSes2 <> '00:00')
SET @FinSes = @FechaFinSes + @HoraLimiteSes
IF (@HoraLimiteSes2 IS NULL) OR (@HoraLimiteSes2 = '') OR (@HoraLimiteSes2 = '00:00')
SET @FinSes = @FechaFinSes + @HoraFinSes
IF GETDATE() < @InicioSes
BEGIN
SELECT @MensajeFechaSes = LEFT(b.FechaInicio,11)
FROM CESesionAlumnoRegMaterias a
JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion WHERE Alumno = @Alumno
SELECT @MensajeHoraSes = b.HoraInicio
FROM CESesionAlumnoRegMaterias a
JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion
WHERE Alumno = @Alumno
SELECT @Ok = 1000178, @OkRef = @MensajeFechaSes +' con hora inicio ' + @MensajeHoraSes + ' y hora fin ' + @HoraFin
END
IF @Ok IS NULL
BEGIN
IF (@HoraLimiteSes2 IS NOT NULL ) AND (@HoraLimiteSes2 <> '') OR (@HoraLimiteSes2 <> '00:00')
BEGIN
IF GETDATE() > @FinSes
BEGIN
SELECT @MensajeFechaSes = LEFT(b.FechaFin,11)
FROM CESesionAlumnoRegMaterias a
JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion
WHERE Alumno = @Alumno
SELECT @MensajeHoraSes = b.HoraLimite
FROM CESesionAlumnoRegMaterias a
JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion
WHERE Alumno = @Alumno
SELECT @Ok = 1000179, @OkRef = @MensajeFechaSes + ' a las '+ @MensajeHoraSes + ' horas. con la hora inicio ' + @HoraInicio
END
END
END
IF @Ok IS NULL
BEGIN
IF (@HoraLimiteSes2 IS NULL) OR (@HoraLimiteSes2 = '') OR (@HoraLimiteSes2 = '00:00')
BEGIN
IF GETDATE() > @FinSes
BEGIN
SELECT @MensajeFechaSes =  LEFT(b.FechaFin,11)
FROM CESesionAlumnoRegMaterias a JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion
WHERE Alumno = @Alumno
SELECT @MensajeHoraSes = b.HoraFin
FROM CESesionAlumnoRegMaterias a
JOIN CESesionRegistroMaterias b ON b.Clave = a.Clave AND b.Sesion = a.Sesion
WHERE Alumno = @Alumno
SELECT @Ok = 1000179, @OkRef = @MensajeFechaSes + ' a las ' + @MensajeHoraSes + ' horas. con la hora inicio ' + @HoraInicio
END
END
END
END
ELSE
SELECT @Ok = 1000177 
END
END
END
RETURN
END
GO

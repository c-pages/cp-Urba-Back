/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale
	
##########################################################################################################################
	
	Plugin Batiment - les structures du plug --------------------
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	- gerer les unité des parametre (pour le calcul ou  l'affichage des longueurpar ex..)
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/


struct str_plan (
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="str_plan",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		a,
		b,
		c,
		d,
		normal ,
		
		fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
			
-- 			debug "creerFrom_2vecs_et_1Point"
			---le vec normal du plan-----
			local norm1 = normalize _vec1
			local norm2 = normalize _vec2		
			normal =  cross    norm2 	norm1
			
			--- definition equation ---------
			a = normal.x
			b = normal.y
			c = normal.z		
			d = -( a*_point.x + b*_point.y + c*_point.z )
			
-- 			debug "a" var:a
-- 			debug "b" var:b
-- 			debug "c" var:c
-- 			debug "d" var:d
		),
		fn projeter_point_verticalement 		_pt 	=(
-- 			debug "projeter_point_verticalement"
			local result = copy _pt
			result.z =  -( a*_pt.x + b*_pt.y + d ) / c
			result
			
		),
		

		fn get_intersection_segment	_segPt1		_segPt2			=(
			
			local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

			local ptResult 	= [0,0,0]
			ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
			ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
			ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
			
			ptResult
			
		),
		fn coupe_segment	_segPt1		_segPt2			=(
			
			local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
			-- debug-------
-- 			point pos:pointIntersect isSelected:true
			
			local vecSeg 	= _segPt2 - _segPt1
			local vecInter = pointIntersect - _segPt1
			
			if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
				true
			else
				false
			
		)
		
		
		
		
)


----------- Creation des geometries----------------------------------------------------------------------
struct geo (

	
	fn vider =(
		if (polyop.getNumFaces delegate) >0 do (
			local listeDesFaces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.deleteFaces delegate	listeDesFaces		delIsoVerts:true
			polyop.deleteIsoVerts delegate
		)
	),
	fn creerFace  		_listeDesPoints  =(
		
		local verts = polyop.getNumEdges delegate
		
		-- les vertex --
		for pt in  _listeDesPoints do (
			polyop.createVert delegate	pt
		)
		
		-- les edges --
		for i = 1 to _listeDesPoints.count do (
			local j= i+1
			if j > _listeDesPoints.count do j = 1
			polyop.createEdge delegate (verts+i) (verts+j)
		)
-- 				polyop.createEdge delegate (verts+i) (verts+i+1)
-- 			polyop.createEdge delegate (verts+_listeDesPoints.count) (verts+1)
		
		-- la face --
		local listeVertexPrFace = #()
		for i = 1 to _listeDesPoints.count  do 
			append listeVertexPrFace ( verts+i )
		
		
		polyop.createPolygon delegate  listeVertexPrFace
		
	),
	fn creerFaceVerticale 	pt1 	pt2 	z 	hauteur	=(
		
		local verts = polyop.getNumEdges delegate
		
		polyop.createVert delegate	[pt2.x, pt2.y, z]	
		polyop.createVert delegate	[pt1.x, pt1.y, z]
		polyop.createVert delegate	[pt1.x, pt1.y, z + hauteur]
		polyop.createVert delegate	[pt2.x, pt2.y, z + hauteur]
		
		polyop.createEdge delegate (verts+1) (verts+2)
		polyop.createEdge delegate (verts+2) (verts+3)
		polyop.createEdge delegate (verts+3) (verts+4)
		polyop.createEdge delegate (verts+4) (verts+1)
		
		polyop.createPolygon delegate  #((verts+4),(verts+3),(verts+2),(verts+1))
		
	),
	fn creerFacesContour	ptsContours	 altitude 		hauteur =(
		
		local facesDuContour =#()
		local listePts = #()
		
		if hauteur <0 then
			listePts = for i = ptsContours.count to 1 by -1 collect ptsContours[i]
		else listePts = ptsContours
		
		for i_pt = 1 to listePts.count do	 (
			local pt_1 = listePts[i_pt]
			local pt_2 
		
			if i_pt == listePts.count then
				pt_2 = listePts[1]
			else pt_2 =  listePts[i_pt + 1 ]
			
			local nvlFace = geo.creerFaceVerticale 		pt_1		pt_2 	altitude 	hauteur
			if nvlFace != undefined do
				appendIfUnique facesDuContour	nvlFace
		)
		
		facesDuContour
	)
) --- fin struct geo

struct get (
	
	----- Poly -------------------
	fn surface 	=(
		polyop.getFaceArea  delegate 1
	),
	
	
	----- Shape -------------------
	fn edge_lePlusGrand			_trace 	=(
		local longueurEdgeMax = 0
		local	resultPts = #()
		for i = 1 to _trace.count do (
			local j = i+1
			if j > _trace.count  do j = 1
			local pt 			= _trace[	i ]
			local pt_suivant	= _trace[	j ]
			local longueurEdge = distance	pt	pt_suivant
			if longueurEdge > longueurEdgeMax do (
				longueurEdgeMax = longueurEdge
				resultPts = #(pt, pt_suivant)
			)
		)
		resultPts
	),
	fn mtrx_axePrincipal  			_trace  	=(
		
		local ptsEdgeLePlusLong 	= get.edge_lePlusGrand	_trace
		
		local axeVecteur 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])
		local axeMtrx				=  ( matrixFromNormal		axeVecteur )
		
		if axeMtrx.row1	==	[0,0,-1]  then 				
			axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
		 else if axeMtrx.row1	==	[0,0,1] do
			axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
		
		axeMtrx		
	),
	fn BB_axePrincipal				_trace  		_mtrxAxe  	=(
		
-- 			local mtrxAxePrincipal	=	get.mtrx_axePrincipal 	_spline	_idSpline
		
		local pt1 = _trace[1] * inverse _mtrxAxe
		local xMin = xMax = pt1.x
		local yMin = yMax = pt1.y
		local zMin = zMax = pt1.z
		
		for i = 2 to _trace.count do (
			local pt = _trace[i] * inverse _mtrxAxe
			if pt.x < xMin 		do xMin 		= pt.x
			if pt.x > xMax 	do xMax 	= pt.x
			if pt.y < yMin 		do yMin 	= pt.y
			if pt.y > yMax 	do YMax 	= pt.y
			if pt.z < zMin 		do zMin 		= pt.z
			if pt.z > zMax 	do zMax 	= pt.z
		)
		
		#([xMin, yMin, zMin]*  _mtrxAxe, [xMax, yMax, zMax]*  _mtrxAxe)
		
	),
	
	
	
	fn pointLePlusHautsurY 	shp 	spline	=(
		local maxi = -10000000000000000 
		local result_id = 0
		for i = 1 to numKnots shp 	spline do (
			local pt = getKnotPoint shp 	spline 	i
			if  pt.y > maxi do ( 
				maxi = pt.y
				result_id = i
			)
		)
		
-- 			debug "pointLePlusHautsurY"	var:result_id
		result_id
	),
	fn est_sensPositif 			shp	idSpline =(
		
		local result 			= true
		local id_pointHaut 	= get.pointLePlusHautsurY  	shp	idSpline 
		
		local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
		local	id_pt_ori 	= id_pointHaut 		---- le point origine
		local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
		
		-- Boucler limite nombre des points
		if id_pt_1 < 1 do id_pt_1 = numKnots shp	idSpline 
		if id_pt_2 > numKnots shp	idSpline  do id_pt_2 = 1
		
		local	pt_1 		= getKnotPoint shp 	idSpline 	id_pt_1
		local	pt_ori 	= getKnotPoint shp 	idSpline 	id_pt_ori
		local	pt_2 		= getKnotPoint shp 	idSpline 	id_pt_2

		local	vec1 =  normalize ( pt_1 - pt_ori )
		local	vec2 =  normalize ( pt_2 - pt_ori )
		
		if vec2.x > vec1.X do result = not result
		
		result
		
	),
	
	
	
	fn orientation_axeP  	_this		_vec 		=(
		
		local mtrx_Direction = _this.mtrx_axePrincipal.rotationpart as matrix3
		local vec_direction = [0,0,1] * mtrx_Direction
		
		local vec1_dir = normalize _vec	
		
		local valTest =  abs  (dot  vec_direction	vec1_dir ) 
		
		if valTest	 > cos 45 then 
			#parallele
		else 
			#perpendiculaire
		 
	)
	
	
) ---- fin struct GET ------------------

----------- Creation des batiments----------------------------------------------------------------------
struct construire (
	
	
	------------ FACADES-------------------------
	fn ssBassement  	_this		&z	=(
		
		geo.creerFacesContour	 	_this.trace		z 	ep_ssBassement
		z += ep_ssBassement
		
		geo.creerFacesContour	 	_this.trace		z 	ep_dalle
		z += ep_dalle
		
		
	),
	fn RdC 				_this		&z	=(
		
		--- un etage ---
-- 			local styleFacade = m_urba.facades.presets.get_parIdUnique 		_presetBat.rdc_facade
-- 			creer_etage	_nodeBat	z 	_presetBat.niveaux_hauteur	styleFacade
-- 			z += _presetBat.niveaux_hauteur
		
		geo.creerFacesContour	 _this.trace		z 	_this.niveaux_hauteur			
		z += _this.niveaux_hauteur	
		
	),
	fn etages 			_this		&z			=(
		
		local niveaux_hauteur	= _this.niveaux_hauteur
		local niveaux_nbre		= _this.niveaux_nbre
		
		local facesDunEtage =#()
		
		if niveaux_nbre != 0 do (
			
			--- creation de l'etage modele ---------------------
			--- plancher ---
			if ep_dalle  != 0 do (
				local nvlsFaces = geo.creerFacesContour	_this.trace	z 	ep_dalle
				facesDunEtage  += nvlsFaces
				z += ep_dalle
			) 
			
			local nvlsFaces = geo.creerFacesContour	_this.trace	z 	niveaux_hauteur
			facesDunEtage  += nvlsFaces		
			z += niveaux_hauteur
			
			
			--- on copie l'etage x fois ----
			for i = 2 to niveaux_nbre do (
				local vertsfin = polyop.getNumEdges delegate
				polyop.detachFaces delegate	 facesDunEtage delete:false	
				local vertsABouger = #{(vertsfin+1)..(polyop.getNumEdges delegate)}
				polyop.moveVert 	delegate 	vertsABouger [0,0, ( niveaux_hauteur + ep_dalle ) *  (i-1) ]
				z += ep_dalle
				z += niveaux_hauteur
			)
			
		)
		
		
	),
	
	
	
	
	
	------------ TOITURES-------------------------
	
	fn toitPentes 		_this		&z	_nbrePentes	=(
		
		
		local	 mtrx_axeP	=	_this.mtrx_axePrincipal
		local	 BB_axeP	=	_this.BB_axePrincipal
		translate mtrx_axeP	BB_axeP[1]
		
		
		local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		local hauteur 		= largeur * tan _this.toit_pente		--	largeur /2 --* random .3 1.5
		
		local nvlsFaces 	= #()
		case _nbrePentes of (
			1: ( ---------- 1 PENTE ----------------------------------------------------------------------------------------------------
					--- gestion de l'angle de la pente .... ----
-- 						hauteur = hauteur/4
					
					local pt_0 = (  [0,0,0]  *  mtrx_axeP )
					local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
					local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
					
				
					local vec1 = pt_1 - pt_0
					local vec2 = pt_2 - pt_0
					
					local pt_Origine = pt_0
					pt_Origine.z =  z + _this.toit_hauteur
-- 						point pos:pt_Origine	 isSelected:true
				
					local plan_pente = str_plan ()
					plan_pente.creerFrom_2vecs_et_1Point	vec1	vec2		pt_Origine
					
					local pointsPente = #()
					local pointsMurs   =#()
					for i = 1 to  _this.trace.count do (
						
						local j = i+1
						if j >  _this.trace.count  do j = 1
						
						
						--- point Mur ----
						local pt 			= 	_this.trace[i]	
						append pointsMurs  pt		
						
						
						
						local pt_result = plan_pente.projeter_point_verticalement 	pt
-- 						pt_result.z += _this.toit_hauteur
						append pointsPente  pt_result
						
					)
					
					--- creation de la face du dessus ----
					append nvlsFaces ( geo.creerFace  	pointsPente )
					
					---- creation des raccord mur ----------
					for i = 1 to pointsMurs.count  do (
						
						local j = i+1
						if j >  pointsMurs.count  do j = 1
						
						local ptMur1 		= pointsMurs[i]
						local ptMur2 		= pointsMurs[j]
						local ptPente3 	= pointsPente[j]
						local ptPente4	= pointsPente[i]
						
						local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
						append nvlsFaces ( geo.creerFace  	pointsRaccord )
					)
				
			)
			2: (---------- 2 PENTES ----------------------------------------------------------------------------------------------------
				
				
					--- Plan de la Pente 1  ----
					local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP )
					local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP )
					local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )	
				
					local vecP1_1 = pt_P1_1 - pt_P1_0
					local vecP1_2 = pt_P1_2 - pt_P1_0
					
					local pt_Origine = pt_P1_0
					pt_Origine.z =  z + _this.toit_hauteur
					local plan_pente1 = str_plan ()
					plan_pente1.creerFrom_2vecs_et_1Point	vecP1_1		vecP1_2		pt_Origine
				
				
				
					--- Plan de la Pente 1  ----
					local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP )
					local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP )
					local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP )			
				
					local vecP2_1 = pt_P2_1 - pt_P2_0
					local vecP2_2 = pt_P2_2 - pt_P2_0
					
					local pt_Origine = pt_P2_0
					pt_Origine.z =  z + _this.toit_hauteur
					local plan_pente2 = str_plan ()
					plan_pente2.creerFrom_2vecs_et_1Point	vecP2_1		vecP2_2		pt_Origine
				
					--- Plan verticale faitage ------
					local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP )
					local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP )
					local pt_F_2	=	pt_F_0 + [0,0,100]				
					
					local vec_F_1 = pt_F_1 - pt_F_0
					local vec_F_2 = pt_F_2 - pt_F_0				
					
					local pt_Origine = pt_F_0
					pt_Origine.z =  z 
					
					local plan_verticaleFaitage = str_plan ()
					plan_verticaleFaitage.creerFrom_2vecs_et_1Point	vec_F_1		vec_F_2		pt_Origine
					
					
					
					---- creation des liste des points-----------
					local pointsPente = #()
					local pointsPente1 = #()
					local pointsPente2 = #()
					local pointsMurs   =#()
					for i = 1 to  _this.trace.count do (
						
						local j = i+1
						if j >  _this.trace.count  do j = 1
						
						
						--- point Mur ----
						local pt 			= 	_this.trace[i]	
						pt.z = z
						append pointsMurs  pt		
						
						--- point pente ----
						local pt_pente1 = plan_pente1.projeter_point_verticalement 	pt
						local pt_pente2 = plan_pente2.projeter_point_verticalement 	pt
						if pt_pente1.z < pt_pente2.z then (
							append pointsPente  	pt_pente1
							append pointsPente1 	pt_pente1
							
						) else  (
							append pointsPente  	pt_pente2
							append pointsPente2  	pt_pente2
						)
						
						--- point mur - faitage ----
						local pt_suivant 	= 	_this.trace[j]	
						pt_suivant.z = z
						local intersect = plan_verticaleFaitage.coupe_segment	pt 	pt_suivant							
						if intersect do (
							local pt_faitage_mur = plan_verticaleFaitage.get_intersection_segment 	pt 	pt_suivant
							append pointsMurs  	pt_faitage_mur
							local pt_faitage_pente = plan_pente1.projeter_point_verticalement 	pt_faitage_mur
							append pointsPente  pt_faitage_pente
							
							
							append pointsPente1 	pt_faitage_pente
							append pointsPente2 	pt_faitage_pente
						)
						
						
						
					)
					
					
					
					
					--------- creation des geometries ---------------------
					--- les murs ----
					for i = 1 to pointsMurs.count  do (
						
						local j = i+1
						if j > pointsMurs.count do j = 1
						
						local ptMur1 		= pointsMurs[ i ]
						local ptMur2 		= pointsMurs[ j ]
						local ptPente3 	= pointsPente[ j ]
						local ptPente4	= pointsPente[ i ]
						
						local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
						append nvlsFaces ( geo.creerFace  	pointsRaccord )
					) 
					
					
					--- les pentes -----
					append nvlsFaces ( geo.creerFace  		pointsPente1 )
					append nvlsFaces ( geo.creerFace  		pointsPente2 )
					
					
			)
		)
	),
	
	fn acrotere		_this		_face		= (
		
		--- les murs -----
		polyop.bevelFaces delegate 	#(_face) 	0 	-ep_mur
		local faceAExtruder = #{_face+1..(polyop.getNumFaces delegate)} as array
		polyop.extrudeFaces  delegate 	faceAExtruder 	_this.toit_hauteur
		
		--- la couvertine  -----
		polyop.bevelFaces delegate 	faceAExtruder		0 	ep_couvertine
		polyop.extrudeFaces delegate 	faceAExtruder		ep_couvertine
		
	),
	
	fn toit 		_this		&z =(
		case _this.toit_type of (
			1: (	---- PLAT	----
				local trace = for pt in _this.trace collect [pt.x,pt.y,z]
				geo.creerFace		trace
			)
			2: (	---- ACROTERE	----
				
				local trace 		= _this.trace
				
				--- dalle ---
				if ep_dalle  != 0 do (
					geo.creerFacesContour	_this.trace 	z 	ep_dalle
					z += ep_dalle
				) 
				
				--- creation de la facette globale-----
				local trace 		= for pt in _this.trace collect [pt.x,pt.y,z]
				local faceDuToit 	= geo.creerFace		trace
				
				construire.acrotere	_this	faceDuToit
				
			)
			3: (	---- 1 PAN	----
				construire.toitPentes			_this		&z  1
			)
			4: (	---- 2 PANS	----
				construire.toitPentes			_this		&z  2
			)
		)
	)			
	
) ---- fin struct construire ------------------

struct optimiser (
	fn ortho 	_this		=(
		
		local mtrx_AP = _this.mtrx_axePrincipal
		
		--- les pignons --
		for i = 1 to _this.trace.count do (
			local j = i + 1
			if j > _this.trace.count do j = 1
			local pt = _this.trace[i]	* inverse  mtrx_AP 
			local pt_suivant = _this.trace[j] *  inverse mtrx_AP 
			
			local estPignon = findItem _this.idtrace_pignons i != 0 
			if not estPignon then (
				
				local moyenneX = ( pt_suivant.x - pt.x ) /2					
				local vec_moyenne = [moyenneX,0,0] * _this.seuil_ortho / 100
				pt 			= _this.trace[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= _this.trace[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				_this.trace[i] = pt *   mtrx_AP 
				_this.trace[j] = pt_suivant  *   mtrx_AP 
			) 
		)
		--- les Gouttereaux  --
		for i = 1 to _this.trace.count do (
			local j = i + 1
			if j > _this.trace.count do j = 1
			local pt = _this.trace[i]	* inverse  mtrx_AP 
			local pt_suivant = _this.trace[j] *  inverse mtrx_AP 
			
			local estPignon = findItem _this.idtrace_pignons i != 0 
			if  estPignon then (
				
				local moyenneZ = ( pt_suivant.z - pt.z ) /2					
				local vec_moyenne = [0,0,moyenneZ] * _this.seuil_ortho / 100
				pt 			= _this.trace[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= _this.trace[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				_this.trace[i] = pt *   mtrx_AP 
				_this.trace[j] = pt_suivant  *   mtrx_AP 
			) 
		)
		
-- 			result
	),
	fn souder 		_this	=(
-- 			local _this.trace =  	_trace
-- 			debug "souder"
-- 			debug "nbre de point avant :" var:_this.trace.count
		local i = 1
		while i <=_this.trace.count do (
			local j= i+1
			if j > _this.trace.count  do j =1
			local pt 			= _this.trace[i]
			local ptSuivant 	= _this.trace[j]
			if distance pt ptSuivant <= _this.seuil_souder do (
				deleteitem _this.trace j
				_this.trace[i] = ( pt + ptSuivant ) / 2
				i = 1
			)
			i+=i
		)
-- 			debug "nbre de point apres :" var:_this.trace.count
-- 			result
	),
	fn optimiser 	_this	=(
-- 			local result =  	_trace
		local i = 1
		while i <= _this.trace.count do (
			
			local h = i - 1
			if h < 1  do h = _this.trace.count
			local j= i+1
			if j > _this.trace.count  do j =1
			local ptDAvant 	= _this.trace[h]
			local pt 			= _this.trace[i]
			local ptSuivant 	= _this.trace[j]
			
			local vec1 = normalize (ptDAvant - pt)
			local vec2 = normalize (ptSuivant - pt)
			
			local anglePt = acos(dot vec1 vec2)			
			if 	anglePt >= 180 - _this.seuil_optimiser  then (
				deleteitem _this.trace i
				i = 0
			)
			
			i +=1
		)

		result
	)
)























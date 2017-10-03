







----------- Construction des batiments----------------------------------------------------------------------
struct str_construire (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | str_construire",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
		geo_ptr,		
		modeles_import 					=#(),
	
	
		fn get_hauteurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local hauteur = BB[2].z -  BB[1].z 
			hauteur
		),
		fn get_largeurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local largeur = BB[2].x -  BB[1].x 
			largeur
		),
		fn get_angle_vecteur 	vec	=(
			
			local result = 0
			local angle_tan = atan ( vec.y / vec.x )
			
			if vec.x >=0 then (
				if vec.y >= 0 then 	result = angle_tan
				else 	result = 360 + angle_tan
			) else (		
				if vec.y >= 0 then 	result = 180 + angle_tan
				else result = 180 + angle_tan
			)
			
			result
		),		
	
	
		------------ FACADES-------------------------
		fn ssBassement  	_this		&z	=(
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_ssBassement
			z += ep_ssBassement
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_dalle
			z += ep_dalle
			
		),
		fn RdC 					_this		&z	=(
			
			geo_ptr.creerFacesContour	 _this.trace_courant		z 	_this.niveaux_hauteur			
			z += _this.niveaux_hauteur	
			
		),
		
		fn creer_sequence		_pt1		_pt2			&z 		_facade		_this			=(
-- 			debug "creer sequence()"
			local normDir						=	normalize ( _pt2 - _pt1)
			local rot 							= get_angle_vecteur		normDir
			local longueur_sequence 	= 0
			local sequence 					= _facade.sequence 						
			for composant 	in sequence do	
				longueur_sequence += composant.longueur
			
			local longueurFacade = distance _pt1 _pt2
			

			local pt1 			= 	_pt1
			local pt2		
			local nbrRepetitions 		
			local longueur_restant 			
			local longueur_espacement 	
			
			
			local b_espacer = false
			case _facade.mode of (
					1:  	(	--- Repeter ----
						nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2	
					)
					2: 	(	--- Etirer ----
						nbrRepetitions				= 1						
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2	

					)
					3: 	(	--- Centrer ----					
						nbrRepetitions				= 1		
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2				
					)
					4:	(	--- Espacer ----	
						nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / ( nbrRepetitions +1 )
						b_espacer = true
					)						
				)
			
				
				
				--- le premier espacement --------
				pt2		=	pt1 + normDir * longueur_espacement						
				geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this.niveaux_hauteur 
				pt1 = pt2
				
				for i = 1 to nbrRepetitions do (
					--- la sequence --------
					for composant in sequence do (
						--- choix du model ----
						local ids_modelsTmp = #()
						for i = 1 to composant.modeles.count do
							append ids_modelsTmp 	i
						
						local longueurAvantFin = distance _pt2	pt1
						
						---- si on a pas de model -----
						if ids_modelsTmp.count == 0  then (
							pt2		=	pt1 + normDir * composant.longueur						
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this.niveaux_hauteur 
							pt1 = pt2
							
						) else if longueurAvantFin <  composant.longueur then (
							pt2		=	_pt2					
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this.niveaux_hauteur 
							pt1 = pt2
						
						
						) else (
							
							
							---- on tire au hasare le modele parmis ceux qui restent ------------
							local probaTotal = 0
							for id in ids_modelsTmp do 
								probaTotal += composant.modeles_probas[id]
							local tirage = random  1.  probaTotal
							local modeleTmp_idUnique
							local trouve = false
							local id = 1
							local probacourant = 0
							while not trouve and probacourant <= probaTotal	do (
								probacourant += composant.modeles_probas[id]
								if tirage < probacourant do (
									trouve = true
									modeleTmp_idUnique = composant.modeles[id].id
								)
								id += 1
							)					
							debug "tirage" var:tirage
							debug "probaTotal" var:probaTotal
							debug "modeleTmp_idUnique" var:modeleTmp_idUnique
							
							
-- 							local modeleTmp_idUnique  	= modelsTmp[1]
							local modeleTmp_id				=	_this.facades.get_modele_idParam		modeleTmp_idUnique		_this
							local modele_node 				= modeles_import[modeleTmp_id]
							local hauteur_modele 			= get_hauteurNodeModele modele_node
							local largeur_modele 			= get_largeurNodeModele modele_node
							
							
							local nv_modele 		= copy modele_node
							
							rotate nv_modele (angleaxis rot [0,0,1])
							nv_modele.pos 				= pt1
							nv_modele.pos.z 				= z
							
							local facesDuNodeAvant 	= polyop.getNumFaces delegate
							delegate.attach	nv_modele		modele_node
							-----	facette du dessus -----
							pt2 = pt1 + normDir * largeur_modele
							
							local hauteurQuiReste = 	_this.niveaux_hauteur 	- hauteur_modele
							
							local nvlFace = geo_ptr.creerFaceVerticale 	pt1 	pt2 	( z + hauteur_modele )		hauteurQuiReste	
							
							pt1 = pt2
							
							
							
							
						)
					
					) --- fin de la sequence -----
				
					if b_espacer do (
						pt2		=	pt1 + normDir * longueur_espacement						
						geo_ptr.creerFaceVerticale 		pt1		pt2 	z 		_this.niveaux_hauteur 
						pt1 = pt2
		
					)
					
				)  --- fin de la repetition
				
				--- le dernier espacement --------
				pt2		=	pt1 + normDir * longueur_espacement						
				geo_ptr.creerFaceVerticale 		pt1		_pt2 	z 		_this.niveaux_hauteur 
				
-- 			) else 
-- 				geo_ptr.creerFaceVerticale 		_pt1		_pt2 	z 		_this.niveaux_hauteur 
	
			
		),
		
		
		fn etages 				_this				&z	=(
			
			
			local facesDunEtage =#()
			
			
			
			for n_etage = 0 to _this.niveaux_nbre  do (
				
				local facades_possibles =#()
				
				--- on filtre par etages ---------------
				for fcade in _this.facades.facades_total 		do (					
					if fcade.etages_use_min then (
						if n_etage	>= fcade.etages_nbre_min  do (
							if fcade.etages_use_max then (
								if n_etage <= fcade.etages_nbre_max   do 	
									append facades_possibles fcade
							)	else (
								append facades_possibles fcade
							)
						)
					) else (
						append facades_possibles fcade
					)
				)
			
				
-- 					debug "facades_possibles" var:facades_possibles
				---- si on  a pas de facades ------
				if 	facades_possibles.count == 0 then (
					---- on remplis avec murs pleins ------------
					local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	_this.niveaux_hauteur 
					facesDunEtage  += nvlsFaces		
					z += _this.niveaux_hauteur
					
					
				---- sinon on a des facades -----------
				) else (
					
					
					local listePts = _this.trace_courant
					
					for i_pt = 1 to listePts.count do	 (
						
						local facadesTmp =  facades_possibles
												
						--- on chope les deux points du segment de la facade ---
						local pt_1 = listePts[i_pt]
						local pt_2 
						if i_pt == listePts.count then
							pt_2 = listePts[1]
						else pt_2 =  listePts[i_pt + 1 ]
						
						--- si c'est un pignon -----
						if _this.trace.est_pignon	i_pt	_this then (
							
							facadesTmp = for facde in facades_possibles where facde.murs != 2	collect  facde
							
						---  c'est un gouttereau -----
						) else (
							
							facadesTmp = for facde in facades_possibles where facde.murs != 3	collect  facde
							
						)
							
						
						if facadesTmp.count >0 then (
-- 							debug "on a une facade"
							local facadeTmp = facadesTmp[1]
							creer_sequence		pt_1		pt_2			&z 	facadeTmp		_this	
						) else (
-- 							debug "on dessine pas de sequence"
							geo_ptr.creerFaceVerticale 		pt_1		pt_2 	z 	_this.niveaux_hauteur
						)
						
					)
					z += _this.niveaux_hauteur
				)
				
				
				
				
				--- dalle plancher ---
				if ep_dalle  != 0 do (
					local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	ep_dalle
					facesDunEtage  += nvlsFaces
					z += ep_dalle
				) 
				
			) --- fin boucle etages -------------
				
				
			
			
		),
		
		------------ TOITURES-------------------------		
		fn toitPentes 		_this		&z	_nbrePentes	=(
			
			local	 mtrx_axeP	=	_this.axeP_mtrx
			local	 BB_axeP	=	_this.axeP_BB
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
						for i = 1 to  _this.trace_courant.count do (
							
							local j = i+1
							if j >  _this.trace_courant.count  do j = 1
							
							--- point Mur ----
							local pt 			= 	_this.trace_courant[i]	
							append pointsMurs  pt		
							
							local pt_result = plan_pente.projeter_point_verticalement 	pt
	-- 						pt_result.z += _this.toit_hauteur
							append pointsPente  pt_result
							
						)
						
						--- creation de la face du dessus ----
						append nvlsFaces ( geo_ptr.creerFace  	pointsPente )
						
						---- creation des raccord mur ----------
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j >  pointsMurs.count  do j = 1
							
							local ptMur1 		= pointsMurs[i]
							local ptMur2 		= pointsMurs[j]
							local ptPente3 	= pointsPente[j]
							local ptPente4	= pointsPente[i]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							append nvlsFaces ( geo_ptr.creerFace  	pointsRaccord )
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
						for i = 1 to  _this.trace_courant.count do (
							
							local j = i+1
							if j >  _this.trace_courant.count  do j = 1
							
							
							--- point Mur ----
							local pt 			= 	_this.trace_courant[i]	
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
							local pt_suivant 	= 	_this.trace_courant[j]	
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
							append nvlsFaces ( geo_ptr.creerFace  	pointsRaccord )
						) 
						
						
						--- les pentes -----
						append nvlsFaces ( geo_ptr.creerFace  		pointsPente1 )
						append nvlsFaces ( geo_ptr.creerFace  		pointsPente2 )
						
						
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
		fn toit 				_this		&z =(
			case _this.toit_type of (
				1: (	---- PLAT	----
					local trace_courant = for pt in _this.trace_courant collect [pt.x,pt.y,z]
					geo_ptr.creerFace		trace_courant
				)
				2: (	---- ACROTERE	----
					
-- 					local trace_courant 		= _this.trace_courant
					
					/* --- dalle ---
					if ep_dalle  != 0 do (
						geo_ptr.creerFacesContour	_this.trace_courant 	z 	ep_dalle
						z += ep_dalle
					)  */
					
					--- creation de la facette globale-----
					local trace_courant 		= for pt in _this.trace_courant collect [pt.x,pt.y,z]
					local faceDuToit 	= geo_ptr.creerFace		trace_courant
					
					acrotere	_this	faceDuToit
					
				)
				3: (	---- 1 PAN	----
					toitPentes			_this		&z  1
				)
				4: (	---- 2 PANS	----
					toitPentes			_this		&z  2
				)
			)
		),		
		
		
		fn importer_modeles		_this		=(
			
			modeles_import =#()
			for modele in _this.facades.modeles_total	 do (
				--- nouveau node -----
				local 	nvNode = convertToPoly (mesh ())
				append 	modeles_import		nvNode
				polyop.deleteFaces	nvNode	(#{1..25} as array)				
				_this.facades.scan.creer_objet		modele	ndDest:nvNode
			)
		),
		fn retirer_modelesImports	=(			
			for modele in modeles_import	 do delete modele
			modeles_import =#()
		),
		
		
		
		fn batiment 	_this =(
			
			---- creation de la surface de base -------
			geo_ptr.vider ()
			
			importer_modeles		_this	
			
			local zCourant = -( ep_ssBassement + ep_dalle )
			
			ssBassement 	_this	&zCourant
			etages			_this	&zCourant
			toit				_this	&zCourant
			
			retirer_modelesImports ()
			
			redrawViews () 
		)
	
	
) ---- fin struct construire ------------------


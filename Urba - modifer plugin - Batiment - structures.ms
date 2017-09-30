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






------------------------------------------------------------------------------------------------------------------------------------------------------
--------- STRUCTURES Datas --------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------

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


struct str_datasMgr (
	private
		separateur_params 	="§",
		separateur_mutation 	= ":",
		separateur_mutationTab 		= "%",
		separateur_items 		= ";",
	public
		fn get_datas_string 		_element	=(
			local txtResult = ""
			local propNames = getPropNames _element
			for param in propNames do (
				
			format "param  %\n" param
				local prop = ( getProperty  _element 	param )
				local type = classof prop
			format "type  %\n" type
				case type of (
					MAXScriptFunction:	()
					string:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
					array: (
						local tabString = ""
						for item in prop do (
							tabString += item as string + separateur_items
			format "	item  %\n" item
							
						)
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					default:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				)
			)
			format "txtResult  %\n" txtResult
			txtResult
			
		),
		fn set_datas_string 		_datas_string 	_element =(
			local datasTab = filterString _datas_string 		separateur_params
			local i =1
			local propNames = getPropNames _element
			for datas in datasTab do (
				local dataTab= filterString datas 	separateur_mutation
				local propNom = dataTab[1]
				local type = classof ( getProperty _element propNom  )
				case type of (
					MAXScriptFunction:	()
					string:						(
						local data  = dataTab[2]
						if data   == undefined do data =""
						setProperty _element propNom data
						i+= 1
					)
					array: (
						if dataTab.count >1 do (
							local datas  = filterString	dataTab[2] 	separateur_items
							local tabResult =#()
							for data in datas do
								append tabResult ( data)
							setProperty _element 	propNom 	tabResult
						)
						i+= 1
					)
					default:						(
						if dataTab[2] != undefined do  (
							local data  = execute dataTab[2]
							setProperty _element propNom data
						)
						i+= 1
					)
				)
			)
			_element
		)
)

------------------------------------------------------------------------------------------------------------------------------------------------------
--------- STRUCTURES Grandes fonctions -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
---- manager des facades -----
struct 	str_facades (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | str_facades",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	private
		dialog,
		dialog_pos = [500,500],
		dialog_estOuvert = false,
		
		datasMgr = str_datasMgr (),
		
		params_aEnregistrer = #(	#nom, #etages_nbre_min, #etages_nbre_max, #longueur_min, #longueur_max, #murs, #repeter, #etirer, #sequence	),
	
		presets 	= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\façades\\"		)	\
														fichier_categorie:		"Urba - Façades"	\
														fichier_extension:		"fcd"	\
														params_aEnregistrer:	params_aEnregistrer,
		
	public
		facade_courante 			= str_facade (),
		id_courant = 0,
		composant_courant 	,
		
		fn actualiser		_this =(
			_this.facades_items[id_courant] = (datasMgr.get_datas_string  facade_courante)
			_this.actualiser_rollouts ()
		),
		
		fn charger 		 _this =(
			presets.charger  facade_courante
			actualiser		_this 
		),
		fn enregistrer 	 =(
			presets.enregistrer  facade_courante
		),
		
		
		
		fn get_composants 				_this		=(
			local result =#()
			for comp in _this.facades_composants 	do (
				local nvComposant =   str_facade_composant ()
				datasMgr.set_datas_string		comp	nvComposant
				append result nvComposant
			)
			
			debug "get_composants" var:result
			result
		),
		
		fn get_composant			_id	_this	=(
			local result
			local composants = get_composants 				_this	
			for compo in composants do
				if compo.id == _id do result = compo
			debug "get_composant		_id	" var:_id	
			debug "get_composant" var:result
			result
		),
		
		fn get_sequence 				_this		=(
			local result =#()
			local composants = get_composants 				_this	
			for id_comp in facade_courante.sequence 	do (				
				append result (get_composant	id_comp	_this	)
			)
			result
		),
		fn get_items 				_this	=(
			local result =#()
			for comp in _this.facades_items 	do (
				local nvlFacade =   str_facade ()
				datasMgr.set_datas_string		comp	nvlFacade
				append result nvlFacade
			)
			result
		),
		fn creer 						_this	=(
			local nvlFacade = str_facade ()
			append _this.facades_items (datasMgr.get_datas_string  nvlFacade)
			nvlFacade
		),
		fn supprimer		_this		_id 	=(
			deleteItem _this.facades_items 	_id
		),
		fn fermer 								=(
			debug "Fermer rollout"
			--- Actiualiser position pour reouverture prochaine ----
			if dialog_estOuvert do
				dialog_pos = getDialogPos dialog	
			dialog_estOuvert = false
			---- fermer la fenêtre ----
			try destroydialog dialog catch ()
		),
		fn ouvrir  			_id 		_this =(
			
			id_courant 			= _id
			facade_courante 	= datasMgr.set_datas_string 		_this.facades_items[id_courant]  	 facade_courante
			
			include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms"
			dialog = roll_urba_editeurFacades
			
			---- creation de la fenetre ----
			createDialog dialog 	style:				#(#style_resizing) \
											lockHeight:		true						\
											lockWidth:			true						\
											pos:					dialog_pos
			dialog_estOuvert = true
			
			---- initialisation de la fenetre ----
			dialog.m_prt	 	= this
			dialog.m_cible 	= _this
			dialog.initialiser ()
		),
		
		
		fn set_nom 	_nom 	_this =(
			facade_courante.nom = _nom
			actualiser _this
		),
		
		fn set_repetable		_state		_this =(
			facade_courante.repeter = _state
			actualiser _this
		),
		fn set_etirable			_state		_this=(
			facade_courante.etirer = _state
			actualiser _this
		),
		
		fn set_proba				_val		_this=(
			facade_courante.probabilite = _val
			actualiser _this
		),
		fn set_largeur			_val		_this=(
			facade_courante.longueur_min = _val
			actualiser _this
		),
		fn set_largeurMax		_val		_this=(
			facade_courante.longueur_max = _val
			actualiser _this
		),
		fn set_etages			_val		_this=(
			facade_courante.etages_nbre_min = _val
			actualiser _this
		),
		fn set_etagesMax		_val		_this=(
			facade_courante.etages_nbre_max = _val
			actualiser _this
		),
		
		fn set_largeurMaxState			state		_this =(
			facade_courante.longueur_use_max = state
			actualiser _this
		),
		fn set_etagesMaxState			state		_this	=(
			facade_courante.etages_use_max = state
			actualiser _this
		),
		
		fn ajouter_composant			_this		=(
			
			composant_courant							=	str_facade_composant ()
			append facade_courante.sequence 		 ( composant_courant.id )
			append _this.facades_composants		 ( datasMgr.get_datas_string  composant_courant )
			actualiser 	_this
			composant_courant
			
		),
		fn supprimer_composant			_id		_this	=(
			deleteItem facade_courante.sequence 	_id			
			actualiser _this
		),
		fn set_largeur_composant			state		_this	=(
		),
		fn set_largeurMax_composant				state		_this	=(
		),
		fn set_largeurMax_composantState			state		_this	=(
		),
-- 		fn lbx_modeles
		fn ajouter_modele				state		_this	=(
		),
		fn supprimer_modele				state		_this	=(
		),
			
			
		fn set_murs				val		_this	=(
			facade_courante.murs = val		
			actualiser 	_this
		)
		
)


----------- Creation des geometries poly ----------------
struct str_geo (
	
	fn vider 																			=(
		if (polyop.getNumFaces delegate) >0 do (
			local listeDesFaces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.deleteFaces delegate	listeDesFaces		delIsoVerts:true
			polyop.deleteIsoVerts delegate
		)
	),
	fn creerFace  		_listeDesPoints   nd: 								=(
		
		local  ndCible = if nd != unsupplied then nd else delegate
		local verts = polyop.getNumEdges ndCible
		
		-- les vertex --
		for pt in  _listeDesPoints do (
			polyop.createVert ndCible	pt
		)
		
		-- les edges --
		for i = 1 to _listeDesPoints.count do (
			local j= i+1
			if j > _listeDesPoints.count do j = 1
			polyop.createEdge ndCible (verts+i) (verts+j)
		)
		
		-- la face --
		local listeVertexPrFace = #()
		for i = 1 to _listeDesPoints.count  do 
			append listeVertexPrFace ( verts+i )
		
		
		polyop.createPolygon ndCible  listeVertexPrFace
		
	),
	fn creerFaceVerticale 	pt1 	pt2 	z 	hauteur							=(
		
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
	fn creerFacesContour	ptsContours	 altitude 		hauteur 	=(
		
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
			
			local nvlFace = creerFaceVerticale 		pt_1		pt_2 	altitude 	hauteur
			if nvlFace != undefined do
				appendIfUnique facesDuContour	nvlFace
		)
		
		facesDuContour
	)
	
) --- fin struct geo

----------- Tracé du batiment et autres manipulations----------------
struct str_trace (
		geo_ptr,
		-----------------  Opérations diverses ----------------------
		fn surface 							_trace 	=(
			--- on crée un poly avec le tracee  ------
			local 	nvNode = convertToPoly (mesh ())
			nvNode.EditablePoly.SetSelection #Face #{1..25}
			nvNode.EditablePoly.delete #Face
				
			geo_ptr.creerFace 	_trace 	nd:nvNode
				
			--- pour utiliser cette fonction : ------
			local result = polyop.getFaceArea  nvNode 1
			delete nvNode
			result
		),
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
		fn pointLePlusHautsurY 		_trace	=(
			local maxi = _trace[1].y
			local result_id = 1
			for i = 1 to _trace.count do (
				local pt = _trace[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn est_sensPositif 				_trace 	=(
			
			local result 				= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_trace
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _trace.count
			if id_pt_2 > _trace.count  do id_pt_2 = 1
			
			local	pt_1 		= _trace [	id_pt_1		]
			local	pt_ori 		= _trace [	id_pt_ori	]
			local	pt_2 		= _trace [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		fn reverse 						_trace 	=(
			local result =#()
			for i= _trace.count to 1 by -1 do 
				append result pt[i]
			result
		),
		
		
		-----------------  Optimisation ----------------------
		fn orthonormer 	_this		=(
			
			local mtrx_AP = _this.axeP_mtrx
			
			--- les pignons --
			for i = 1 to _this.trace_courant.count do (
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt = _this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = _this.trace_courant[j] *  inverse mtrx_AP 
				
				local estPignon = findItem _this.idtrace_pignons i != 0 
				if not estPignon then (
					
					local moyenneX = ( pt_suivant.x - pt.x ) /2					
					local vec_moyenne = [moyenneX,0,0] * _this.seuil_ortho / 100
					pt 			= _this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
					pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
					
					_this.trace_courant[i] = pt *   mtrx_AP 
					_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
				) 
			)
			--- les Gouttereaux  --
			for i = 1 to _this.trace_courant.count do (
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt = _this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = _this.trace_courant[j] *  inverse mtrx_AP 
				
				local estPignon = findItem _this.idtrace_pignons i != 0 
				if  estPignon then (
					
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					local vec_moyenne = [0,0,moyenneZ] * _this.seuil_ortho / 100
					pt 			= _this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
					pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
					
					_this.trace_courant[i] = pt *   mtrx_AP 
					_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
				) 
			)
			
	-- 			result
		),
		fn souder 			_this		=(
	-- 			local _this.trace_courant =  	_trace
	-- 			debug "souder"
	-- 			debug "nbre de point avant :" var:_this.trace_courant.count
			local i = 1
			while i <=_this.trace_courant.count do (
				local j= i+1
				if j > _this.trace_courant.count  do j =1
				local pt 			= _this.trace_courant[i]
				local ptSuivant 	= _this.trace_courant[j]
				if distance pt ptSuivant <= _this.seuil_souder do (
					deleteitem _this.trace_courant j
					_this.trace_courant[i] = ( pt + ptSuivant ) / 2
					i = 1
				)
				i+=i
			)
	-- 			debug "nbre de point apres :" var:_this.trace_courant.count
	-- 			result
		),
		fn optimiser 		_this		=(
	-- 			local result =  	_trace
			local i = 1
			while i <= _this.trace_courant.count do (
				
				local h = i - 1
				if h < 1  do h = _this.trace_courant.count
				local j= i+1
				if j > _this.trace_courant.count  do j =1
				local ptDAvant 	= _this.trace_courant[h]
				local pt 			= _this.trace_courant[i]
				local ptSuivant 	= _this.trace_courant[j]
				
				local vec1 = normalize (ptDAvant - pt)
				local vec2 = normalize (ptSuivant - pt)
				
				local anglePt = acos(dot vec1 vec2)			
				if 	anglePt >= 180 - _this.seuil_optimiser  then (
					deleteitem _this.trace_courant i
					i = 0
				)
				
				i +=1
			)

			result
		),
		
		
		-----------------  Axe P ----------------------
		fn mtrx_axeP			_trace  							=(
			
			local ptsEdgeLePlusLong 	= edge_lePlusGrand	_trace
			
			local axeVecteur 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])
			local axeMtrx				=  ( matrixFromNormal		axeVecteur )
			
			if axeMtrx.row1	==	[0,0,-1]  then 				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
			 else if axeMtrx.row1	==	[0,0,1] do
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
			
			axeMtrx		
		),
		fn BB_axeP			_trace  		_mtrxAxe  	=(
			
	-- 			local mtrxAxePrincipal	=	get.axeP_mtrx 	_spline	_idSpline
			
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
		fn vec_axeP			_this		_vec 				=(
			
			local mtrx_Direction = _this.axeP_mtrx.rotationpart as matrix3
			local vec_direction = [0,0,1] * mtrx_Direction
			
			local vec1_dir = normalize _vec	
			
			local valTest =  abs  (dot  vec_direction	vec1_dir ) 
			
			if valTest	 > cos 45 then 
				#parallele
			else 
				#perpendiculaire
			 
		),
	
		
		fn actualiser_pignonsEtGouttereaux  _this =(
			
			_this.idtrace_pignons 		=#()
			_this.idtrace_gouttereaux 	=#()
			
			for i =1 to _this.trace_courant.count do (
				local j = i+1
				if j > _this.trace_courant.count do j = 1
				
				local orientation = vec_axeP	_this		(_this.trace_courant[j]-_this.trace_courant[i])
				case orientation of (
					#perpendiculaire: 	append 	_this.idtrace_pignons			i
					#parallele: 			append 	_this.idtrace_gouttereaux	i
				)
				
			)
		),
		
		fn actualiser_axeP	  _this	=(
			
			local mtrxTmp 			= mtrx_axeP  _this.trace_original 	
			rotateZ	mtrxTmp		_this.axeP_orientation
			_this.axeP_mtrx 			= mtrxTmp		
			_this.axeP_BB				=	BB_axeP		_this.trace_courant 		_this.axeP_mtrx
			
			actualiser_pignonsEtGouttereaux _this
			
		),
		
		
		------------tracé du batiment ---------------
		fn fromSpline 		_shapeNvtrace 	= (
			
			local trace_absolu					=#()
			local subSplineOuvertes 		=#()
			local nvtraceTMP 					= copy _shapeNvtrace
			local id_premiertraceFerme 	= 0
			
			--- on ne prend que la premiere spline fermée-----
			convertToSplineShape nvtraceTMP
			local b_trouve = false
			for idSpline = 1 to (numSplines nvtraceTMP) while not b_trouve	do
				if isClosed  nvtraceTMP	idSpline	then	(
					id_premiertraceFerme = idSpline
					b_trouve = true
				)
			
			---- si on a trouvé la spline --------------------
			if id_premiertraceFerme != 0 do (
				
				---- mise a jour de trace_courant -----------
				for id_pt = 1 to ( numKnots 	nvtraceTMP 	id_premiertraceFerme ) do	 (
					ptSpline = ( getKnotPoint 	nvtraceTMP 	id_premiertraceFerme 	id_pt ) 
	-- 				ptSpline.z = 0
-- 					debug "ptSpline" var:ptSpline
					append trace_absolu 	 ptSpline
				)
				
				--- on fait tourner les spline dans le meme sens ----
				if not est_sensPositif 	trace_absolu 	 do
					trace_absolu = reverse		trace_absolu
			)
			
			--- suppression de tracée temp -------------
			delete nvtraceTMP
			
			trace_absolu
		),
	
		
		fn actualiser 	_this 	=(
			
			_this.trace_courant = _this.trace_original as array
			actualiser_axeP 	_this
			
			---- orthonormer -----------
			if _this.trace_ortho do
				orthonormer		_this
			
			---- souder -----------
			if _this.trace_souder do
				souder		_this
			
			---- optimiser -----------
			if _this.trace_optimiser do
				optimiser		_this
			
			----- calcul de la surface du trace_courant ------
			_this.surface = surface 		_this.trace_courant
			
			actualiser_axeP 	_this
		),
		fn definir	 	_shapeNvtrace  		_thisNode		=(
			
			local trace_absolu					= fromSpline 	_shapeNvtrace
			if trace_absolu.count > 0 do (
			
				_thisNode.trace_original 		=#()
				_thisNode.trace_courant			=#()
				
				_thisNode.transform = (matrix3 1)
				ResetPivot 			_thisNode
				
				---- centrer le pivot ----
				local pt_sommeDesPts = 0
				for pt in trace_absolu do
					pt_sommeDesPts += pt
				local pt_centre = pt_sommeDesPts / trace_absolu.count
				_thisNode.pos = pt_centre
				
				---- actualiser les tracés ----
				for pt in trace_absolu do (
					append _thisNode.trace_original			( pt * inverse _thisNode.transform )
					append _thisNode.trace_courant 		( pt * inverse _thisNode.transform )
				)
				
				--- Axe principal-------------------coordsys
				_thisNode.a_un_trace 			= true
				
				
			)
			actualiser  _thisNode
		)
		
) -- fin struct TRACE ---------

----------- Construction des batiments----------------------------------------------------------------------
struct str_construire (
	geo_ptr,
		------------ FACADES-------------------------
		fn ssBassement  	_this		&z	=(
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_ssBassement
			z += ep_ssBassement
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_dalle
			z += ep_dalle
			
			
		),
		fn RdC 					_this		&z	=(
			
			--- un etage ---
	-- 			local styleFacade = m_urba.facades.presets.get_parIdUnique 		_presetBat.rdc_facade
	-- 			creer_etage	_nodeBat	z 	_presetBat.niveaux_hauteur	styleFacade
	-- 			z += _presetBat.niveaux_hauteur
			
			geo_ptr.creerFacesContour	 _this.trace_courant		z 	_this.niveaux_hauteur			
			z += _this.niveaux_hauteur	
			
		),
		fn etages 				_this		&z	=(
			
			local niveaux_hauteur	= _this.niveaux_hauteur
			local niveaux_nbre		= _this.niveaux_nbre
			
			local facesDunEtage =#()
			
			if niveaux_nbre != 0 do (
				
				--- creation de l'etage modele ---------------------
				--- plancher ---
				if ep_dalle  != 0 do (
					local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	ep_dalle
					facesDunEtage  += nvlsFaces
					z += ep_dalle
				) 
				
				local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	niveaux_hauteur
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
					
					local trace_courant 		= _this.trace_courant
					
					--- dalle ---
					if ep_dalle  != 0 do (
						geo_ptr.creerFacesContour	_this.trace_courant 	z 	ep_dalle
						z += ep_dalle
					) 
					
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
		
		fn batiment 	_this =(
			
			---- creation de la surface de base -------
			geo_ptr.vider ()
			
			local zCourant = -( ep_ssBassement + ep_dalle )
			
			ssBassement 	_this	&zCourant
			RdC 				_this	&zCourant
			etages			_this	&zCourant
			toit				_this	&zCourant
			
			redrawViews () 
		)
	
	
) ---- fin struct construire ------------------





















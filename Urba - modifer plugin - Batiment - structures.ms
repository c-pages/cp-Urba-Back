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

	
struct str_enregistreurDeNode (
	private
	separateur_items 	= ";",
	separateur_tableaux = "§",
	
	public
	fn get_datas 		_node 		=(
		
		local modele_result 	= str_facade_modele ()
		local nodeTemp 		= copy  _node
		convertToPoly nodeTemp
		
		modele_result.verts 		= for i=1 to (polyop.getNumVerts  	nodeTemp )  	collect ( polyop.getVert  						nodeTemp 	i )		
		modele_result.edges		= for i=1 to (polyop.getNumEdges  	nodeTemp )  	collect ( polyop.getEdgeVerts  				nodeTemp 	i )
		modele_result.faces 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceVerts  				nodeTemp 	i )
		modele_result.SMs 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceSmoothGroup  	nodeTemp 	i )
		modele_result.matIDs	= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceMatID   			nodeTemp 	i )
		
		delete nodeTemp
		
		format "modele_result :%\n" modele_result
		modele_result
	),

	fn creer_objet		_modele		ndDest:	=(
		
		if ndDest == unsupplied do
			ndDest = delegate
		
		-- les vertex -- 
		local pts = _modele.verts
		for pt in  pts do 
			polyop.createVert ndDest	pt
			
		-- les edges -- 
		local edges = _modele.edges
		for edge_pts in  edges do 
			polyop.createEdge ndDest		edge_pts[1] 	edge_pts[2]
		
		-- les faces -- 
		local faces = _modele.faces
		for face_pts in  faces do 
			polyop.createPolygon	 ndDest		face_pts
		
		--- les smoothing group ----
		local SGs = _modele.SMs
		for i = 1 to  SGs.count do 
			polyop.setFaceSmoothGroup	 ndDest		i  SGs[i]
		
		--- les material ID ----
		local matIDs = _modele.matIDs
		for i = 1 to  matIDs.count do 
			polyop.setFaceMatID	 ndDest		i  matIDs[i]
		
	)
	
) --- fin struct enregistreur de nodes ----------






struct str_datasMgr (
	private
		separateur_params 			="§",
		separateur_mutation 		= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 			= "^",
	public
		fn get_datas_string 		_element	=(
			local txtResult = ""
			local propNames = getPropNames _element
			for param in propNames do (
				
-- 			format "param  %\n" param
				local prop = ( getProperty  _element 	param )
				local type = classof prop
-- 			format "type  %\n" type
				case type of (
					MAXScriptFunction:	()
					string:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
					array: (
						local tabString = ""
						for item in prop do (
							tabString += item as string + separateur_items
-- 			format "	item  %\n" item
							
						)
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					default:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				)
			)
-- 			format "txtResult  %\n" txtResult
			txtResult
			
		),
		fn set_datas_string 		_datas_string 	_element =(
			local datasTab = filterString _datas_string 		separateur_params
-- 			format "----------------> datasTab  %\n" datasTab
			local i =1
			local propNames = getPropNames _element
			for datas in datasTab do (
				local dataTab= filterString datas 	separateur_mutation
				local propNom = dataTab[1]
-- 			format "--> propNom  %\n" propNom
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
-- 							format "-->	array --> datas  %\n" datas
							local tabResult =#()
							for data in datas do (
								local data_exe = execute data
								if data_exe == undefined then 
									append tabResult ( data)
								else
									append tabResult ( data_exe )
							)
-- 							format "-->	array --> tabResult  %\n" tabResult
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
	
	
	public
		dialog,
	
	private
		dialog_pos = [1235,223],
		dialog_estOuvert = false,
		
		datasMgr = str_datasMgr (),
		
		params_aEnregistrer = #(	#nom, #etages_nbre_min, #etages_nbre_max, #longueur_min, #longueur_max, #murs, #repeter, #etirer, #sequence	),
	
	public
		presets 	= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\façades\\"		)	\
														fichier_categorie:		"Urba - Façades"	\
														fichier_extension:		"fcd"	\
														params_aEnregistrer:	params_aEnregistrer,
		scan 		= str_enregistreurDeNode (),
	
		facade_courante 			= str_facade (),
		id_courant = 0,
		composant_courant 	,
		modele_courant	,
	
	
	
	public
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
			result
		),
		
		fn get_composant			_idUnique	_this	=(
			local result
			local composants = get_composants 				_this	
			for compo in composants do
				if compo.id == _idUnique do result = compo
			result
		),
		
		fn afficher_composant 		_id	_this	=(
			composant_courant = get_composant 	facade_courante.sequence[_id]		_this
		),
		
		
		fn get_idComposant_fromIdUnique		_idUnique	_this	=(
			local composants = get_composants 	_this	
			local result = 0
			for i= 1 to 	composants.count	 do
				if composants[i].id == _idUnique do result = i
			result
		),
		
		
		fn actualiser_composant		_this =(
			
			local id_compo = get_idComposant_fromIdUnique		composant_courant.id	_this
			
			_this.facades_composants[id_compo] = (datasMgr.get_datas_string  composant_courant)
			_this.actualiser_rollouts ()
		),
		
		
		
		
		
		
		fn get_longueurMin_sequence	_this =(
			local result = 0.
			for idComp in facade_courante.sequence 	do (
				local comp = get_composant 	idComp	_this
				result += comp.longueur
			)
			result
		),
		
		fn get_sequence 		_facade		_this		=(
			local result =#()
			local composants = get_composants 				_this	
			for id_comp in _facade.sequence 	do (				
				append result (get_composant	id_comp	_this	)
			)
			result
		),
		
		fn get_sequence_courante 				_this		=(
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
		
		
		
		
		
		fn get_modeles 	_this =(
			local result =#()
			for modele_strg in _this.facades_modeles do (
				local modeleTmp =   str_facade_modele ()
				datasMgr.set_datas_string		modele_strg	modeleTmp
				append result	modeleTmp
			)
			result
		),
		
		fn get_modele		_idUnique	_this	=(
			local result
			local modeles = get_modeles 	_this
			for modele in modeles do
				if modele.id == _idUnique do result = modele
			result
		),
		
		fn get_modeles_courant 	_this =(
			local result =#()
			for modele_id in composant_courant.modeles_ids 	do 
				append result ( get_modele	 modele_id _this )
			result
		),
		
		
		fn get_idModele_fromIdUnique		_idUnique	_this	=(
			local modeles = get_modeles 	_this	
			local result = 0
			for i= 1 to 	modeles.count	 do
				if modeles[i].id == _idUnique do result = i
			result
		),
		
		fn afficher_modele 		_id	_this	=(
			modele_courant = get_modele 	composant_courant.modeles_ids[_id]		_this
		),
		
		
		
		
		
		
		
		
		fn positionnerPivot_modele	 _node =(
			local segmentsOuverts 	= polyop.getOpenEdges _node
			local pointsSegsOuverts 	=#()
			local pointsResult 			=[0,0,0]
			for seg in segmentsOuverts do (
				local ptsDuSegment = polyop.getVertsUsingEdge   _node	seg
				for pt in ptsDuSegment do
					appendIfUnique pointsSegsOuverts	pt
			)
			
			--- on cherche le point  ------
			format "pointsSegsOuverts : %\n" pointsSegsOuverts
			
			for idPt in pointsSegsOuverts do (
				
				if idPt == pointsSegsOuverts[1] then pointsResult = _node.verts[ idPt ].pos
				else (
					local pt =_node.verts[ idPt ].pos
					if pt.x < pointsResult.x do pointsResult = pt
					if pt.y < pointsResult.y do pointsResult = pt
					if pt.z < pointsResult.z do pointsResult = pt
				)
			)
			_node.pivot = pointsResult
			
		),
		fn preparer_modele 	_node	=(
			
				--- preparation du model -------
				local nvModel_node = copy _node 
				convertToPoly 	nvModel_node
				local  BB = nodeGetBoundingBox 	nvModel_node	(matrix3 1)
				positionnerPivot_modele 	nvModel_node
				nvModel_node.rotation = quat 0 0 0 1
				nvModel_node.pos  = [0,0,0]
				
				nvModel_node
		),
		
		
		fn actualiser_modele		_this =(
			
			local id_modele = get_idModele_fromIdUnique		modele_courant.id	_this
			
			_this.facades_modeles[id_modele] = (datasMgr.get_datas_string  modele_courant)
			_this.actualiser_rollouts ()
			
		),
		
		
		
		
		
		
		
		fn creer 						_this	=(
			local nvlFacade = str_facade ()
			nvlFacade.nom	+=	" " + (_this.facades_items.count + 1  ) as string
			append _this.facades_items (datasMgr.get_datas_string  nvlFacade)
			nvlFacade
		),
		fn supprimer	_id	_this		 	=(
			deleteItem _this.facades_items 	_id
		),
		
		fn est_ouvert =dialog_estOuvert,
		fn fermer 								=(
-- 			debug "Fermer rollout"
			--- Actiualiser position pour reouverture prochaine ----
			if dialog_estOuvert do
				dialog_pos = getDialogPos dialog	
			dialog_estOuvert = false
			---- fermer la fenêtre ----
			try destroydialog dialog catch ()
		),
		fn ouvrir  			_id 		_this =(
			
			id_courant 			= _id
			facade_courante = str_facade ()
			facade_courante 	= datasMgr.set_datas_string 		_this.facades_items[id_courant]  	 facade_courante
			
			if facade_courante.sequence.count>0 then (
				composant_courant = get_composant		facade_courante.sequence[1]	_this
				if composant_courant.modeles_ids.count >0 then
					modele_courant = get_modele		composant_courant.modeles_ids[1]		_this
			)
			else
				composant_courant = undefined
			
			
			include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms"
			dialog = roll_urba_editeurFacades
			
			---- creation de la fenetre ----
			createDialog dialog 	style:				#(#style_resizing) 	\
											lockHeight:		true						\
											lockWidth:		true						\
											pos:				dialog_pos
			dialog_estOuvert = true
			
			---- initialisation de la fenetre ----
			dialog.m_prt	 	= this
			dialog.m_cible 	= _this
			dialog.initialiser ()
		),
		
		
		
		
		
		
		
		--------- INTERFACE ----------------------
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
		fn set_longueur			_val		_this=(
			facade_courante.longueur_min = _val
			actualiser _this
		),
		fn set_longueurMax		_val		_this=(
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
		
		fn set_longueurMaxState			state		_this =(
			facade_courante.longueur_use_max = state
			actualiser _this
		),
		fn set_etagesMaxState			state		_this	=(
			facade_courante.etages_use_max = state
			actualiser _this
		),
		
		
		fn set_nom_composants	_nom	_this =(
			composant_courant.nom = _nom
			actualiser_composant		_this
		),
		fn ajouter_composant			_this		=(
			
			composant_courant							=	str_facade_composant ()
			append facade_courante.sequence 	( composant_courant.id )
			composant_courant.nom	+=	" " + facade_courante.sequence.count as string
			append _this.facades_composants		( datasMgr.get_datas_string  composant_courant )
			actualiser 	_this
			composant_courant
			
		),
		fn supprimer_composant			_id		_this	=(
			local id_compo = findItem 	facade_courante.sequence		composant_courant.id
			deleteItem facade_courante.sequence 	_id		
			deleteItem _this.facades_composants		id_compo
			actualiser _this
		),
		fn set_longueur_composant			val		_this	=(
			composant_courant.longueur = val
			actualiser_composant		_this
		),
		fn set_longueurMax_composant				val		_this	=(
			composant_courant.longueur_max = val
			actualiser_composant		_this
		),
		fn set_longueurMax_composantState			state		_this	=(
			composant_courant.longueur_maxEnable = state
			actualiser_composant		_this
		),
		
		fn ajouter_modele				state		_this	=(
			modele_courant	 = str_facade_modele ()
			append composant_courant.modeles_ids 			( modele_courant.id )
			append composant_courant.modeles_probas 	100
			modele_courant.nom	+=	" " + composant_courant.modeles_ids.count as string
			append _this.facades_modeles		( datasMgr.get_datas_string  modele_courant )
			actualiser_composant		_this
		),
		fn supprimer_modele				state		_this	=(
			
		),
		
		
		fn assigner_node 	_node	_this =(			
			debug "assigner_node"
			
			local nd_Tmp		=		preparer_modele		_node
			local  BB = nodeGetBoundingBox 	nd_Tmp	(matrix3 1)
			debug "assigner_node 	---->		BB" var:BB
			debug "assigner_node 	---->		composant_courant" var:composant_courant.nom
			debug "assigner_node 	---->		composant_courant.longueur" var:composant_courant.longueur

			local modeleTmp = 		scan.get_datas 		nd_Tmp
			composant_courant.longueur = BB[2].x - BB[1].x
			
			debug "assigner_node 	---->		composant_courant.longueur ----> 1 -> " var:composant_courant.longueur
			delete nd_Tmp
			debug "assigner_node 	---->		composant_courant.longueur ----> 2 -> " var:composant_courant.longueur
			
			debug "modeleTmp" var:modeleTmp
			modele_courant.verts	 	=	modeleTmp.verts	
			modele_courant.edges	 	=	modeleTmp.edges
			modele_courant.faces	 	=	modeleTmp.faces
			modele_courant.SMs	 		=	modeleTmp.SMs 
			modele_courant.matIDs	 	=	modeleTmp.matIDs
			
			
			actualiser_composant	_this
			actualiser_modele		_this
			
		),
		
		fn merge_modele 		_this =(			
			
			--- nouveau node -----
			local 	nvNode = convertToPoly (mesh ())
			polyop.deleteFaces	nvNode	(#{1..25} as array)
			
			
			scan.creer_objet		modele_courant	ndDest:nvNode

		),
		
		
		fn set_murs				val		_this	=(
			facade_courante.murs = val		
			actualiser 	_this
		),
		
		fn set_longueurMaxState				state		_this	=(
			facade_courante.longueur_use_max = state
			actualiser		_this
		),
		fn set_etagesMaxState			state		_this	=(
			facade_courante.etages_use_max = state
			actualiser		_this
		),
		fn set_longueurState				state		_this	=(
			facade_courante.longueur_use = state
			actualiser		_this
		),
		fn set_etagesState			state		_this	=(
			facade_courante.etages_use = state
			actualiser		_this
		),
		fn set_mode			state		_this	=(
			facade_courante.mode = state
			actualiser		_this
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
		
		
		local  ndCible 	= if nd != unsupplied then nd else delegate
		local verts 	= polyop.getNumVerts ndCible
		
		-- les vertex --
		for pt in  _listeDesPoints do 
				polyop.createVert ndCible	pt 
		
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
		
		local verts = polyop.getNumVerts delegate		
-- 		format "verts avant :%\n" verts
		
		polyop.createVert delegate	[pt2.x, pt2.y, z]	
-- 		format "result :%\n" result
		polyop.createVert delegate	[pt1.x, pt1.y, z]
		polyop.createVert delegate	[pt1.x, pt1.y, z + hauteur]
		polyop.createVert delegate	[pt2.x, pt2.y, z + hauteur]
		
-- 		format "polyop.getNumEdges delegate :%\n" (polyop.getNumEdges delegate)
		
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
			--- on creer une face sur le tracé ---------
			local faceTemp = geo_ptr.creerFace 	_trace 	--nd:nvNode
			
			--- pour utiliser cette fonction : ------
			local result = polyop.getFaceArea  delegate faceTemp
			
			--- on supprime la face, verts et edges créés--------
			polyop.deleteFaces 	delegate faceTemp
			
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
			
		),
		fn optimiser 		_this		=(
			
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
	
		fn est_pignon 		_id	_this	= findItem _this.idtrace_pignons 	_id 	!= 0,
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
				
				----- calcul de la surface du trace_courant ------
				_thisNode.surface = surface 		_thisNode.trace_courant
			)
			actualiser  _thisNode
		)
		
) -- fin struct TRACE ---------

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
			local longueurMinSequence 	= 0
			local sequence 					= _this.facades.get_sequence 		_facade		_this			
			for composant 	in sequence do	longueurMinSequence += composant.longueur
			
			local longueurFacade = distance _pt1 _pt2
-- 			debug "longueurFacade" var:longueurFacade
-- 			debug "longueurMinSequence" var:longueurMinSequence

			local pt1 			= 	_pt1
			local pt2		
			local nbrRepetitions 		
			local longueur_restant 			
			local longueur_espacement 	
			
			if longueurMinSequence > 0 then (
				case _facade.mode of (
					1:  	(	--- Repeter ----
						
						nbrRepetitions				= floor ( longueurFacade / longueurMinSequence )
						longueur_restant 			= longueurFacade - longueurMinSequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2	
						
							
					)
					2: 	(	--- Etirer ----
						
					)
					3: 	(	--- Centrer ----
					
						nbrRepetitions				= 1
						longueur_restant 			= longueurFacade - longueurMinSequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2	
					
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
						local modelsTmp = #()
						for modele_id in composant.modeles_ids do
							append modelsTmp 	modele_id
						
						local longueurAvantFin = distance _pt2	pt1
						
						---- si on a pas de model -----
						if modelsTmp.count == 0  then (
							pt2		=	pt1 + normDir * composant.longueur						
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this.niveaux_hauteur 
							pt1 = pt2
							
						) else if longueurAvantFin <  composant.longueur then (
							pt2		=	_pt2					
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this.niveaux_hauteur 
							pt1 = pt2
						
						
						) else (
							
							local modeleTmp_idUnique  	= modelsTmp[1]
							local modeleTmp_id				=	_this.facades.get_idModele_fromIdUnique		modeleTmp_idUnique		_this
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
					
				)  --- fin de la repetition
				
				--- le dernier espacement --------
				pt2		=	pt1 + normDir * longueur_espacement						
				geo_ptr.creerFaceVerticale 		pt1		pt2 	z 		_this.niveaux_hauteur 
				
			) else 
				geo_ptr.creerFaceVerticale 		_pt1		_pt2 	z 		_this.niveaux_hauteur 
	
			
		),
		
		
		fn etages 				_this				&z	=(
			
			
			local facesDunEtage =#()
			
			
			
			for n_etage = 0 to _this.niveaux_nbre  do (
				
				local facades_possibles =#()
				
				--- on filtre par etages ---------------
				for fcade in _this.facades.get_items 	_this	do (					
					if fcade.etages_use then (
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
			for modele in _this.facades.get_modeles 	_this	 do (
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




























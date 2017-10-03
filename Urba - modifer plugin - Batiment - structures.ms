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
		local nodeTemp 		=   _node
-- 		convertToPoly nodeTemp
		
		modele_result.verts 		= for i=1 to (polyop.getNumVerts  	nodeTemp )  	collect ( polyop.getVert  						nodeTemp 	i )		
		modele_result.edges		= for i=1 to (polyop.getNumEdges  	nodeTemp )  	collect ( polyop.getEdgeVerts  				nodeTemp 	i )
		modele_result.faces 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceVerts  				nodeTemp 	i )
		modele_result.SMs 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceSmoothGroup  	nodeTemp 	i )
		modele_result.matIDs	= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceMatID   			nodeTemp 	i )
		
		local  BB = nodeGetBoundingBox 	nodeTemp	(matrix3 1)
		modele_result.longueur 	=  BB[2].x - BB[1].x
		modele_result.hauteur 	=  BB[2].z - BB[1].z
-- 		delete nodeTemp
		
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
	
		m_prt,
		m_this,
		
		
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
				
-- 			format "get_datas_string-------------------------param  %\n" param
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
-- 			format "classof item    %\n" (classof item  )
							case classof item  of (
								string:	tabString += item 		as string + separateur_items
								Integer:	tabString += item 		as string + separateur_items
								Float:	tabString += item 		as string + separateur_items
								
								Point3:	tabString += item 		as string + separateur_items
								Array:	( 
									tabString += item 		as string + separateur_items
									
								)
								default:	(
-- 									format "---->Default\n" 
									tabString += item.id 	as string + separateur_items
								)
							)
						)
-- 			format "get_datas_string-------------------------tabString	%\n" tabString
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					Name:		(
						txtResult+=  param as string  + separateur_mutation	+	"#" + prop as string  + separateur_params
					)
					default:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				) -- fin scase --
				
			)
			format "get_datas_string-------------------------	txtResult	%\n" txtResult
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 	_this	=(
			local datasTab = filterString _datas_string 		separateur_params
			
-- 			format "set_datas_string-------------------------_datas_string  %\n" _datas_string
-- 			format "set_datas_string-------------------------_element  %\n" _element
			
			local i =1
			local propNames = getPropNames _element
			for datas in datasTab do (
				local dataTab		= filterString datas 	separateur_mutation
				local propNom 	= dataTab[1]
-- 				format "set_datas_string-------------------------propNom  %\n" propNom
				local type = classof ( getProperty _element propNom  )
-- 				format "set_datas_string------------------------- type  %\n"  type
				case type of (
					MAXScriptFunction:	()
					string:					(
						local data  = dataTab[2]
						if data   == undefined do data =""
						setProperty _element propNom data
						i+= 1
					)
					array: (
						if dataTab.count >1 do (
							local datas_liste  = filterString	dataTab[2] 	separateur_items
							local tabResult =#()
							format "set_datas_string--------------------datas_liste : %\n"  	datas_liste
							format "set_datas_string--------------------datas.count : %\n"  datas.count
							format "set_datas_string--------------------i : %\n"  i
							for data in datas_liste do (
								
								format "set_datas_string--------------------data : %\n"  data
								local data_exe 	= execute data
								
								--- string ---
								if data_exe 		== undefined then (
									
									append tabResult ( data)
									
								--- un objet -----------
								) else	if classof data_exe == Name then (
									format "set_datas_string---------------------------- un objet -----------\n" 
									
									---- un composant ------------
									if findString data "#FAC_CMP" != 0 then ( 
										format "set_datas_string--------------------------------------- un composant -----------\n" 
										local compoTmp =  ( m_prt.get_composant  ( data ) 	_this	)			
										format "set_datas_string-------------------------------------------------- compoTmp : %\n" 	 compoTmp
										append tabResult		compoTmp
									)
									---- un modele ------------
									else if findString data "#FAC_MOD" != 0 then ( 
										format "set_datas_string--------------------------------------- un modele -----------\n" 
										local compoTmp =  ( m_prt.get_modele  ( data ) 	_this	)									
										append tabResult		compoTmp
									)
									--- un id (name)------
									else (							
										format "set_datas_string--------------------------------------- un id name-----------\n" 
										append tabResult		data
										
									)
									format "set_datas_string--------------------------------------------------------tabResult :%\n"  tabResult
									
									
								--- Nombres ---
								) else 	(									
									append tabResult 	( data_exe)
								)
							)
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
			format "set_datas_string------------------------- FINNNNNNNNNNN	-> _element  %\n"  _element
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
		
		datasMgr = str_datasMgr 	m_prt:this,
		
		params_aEnregistrer = #(	#nom, #etages_nbre_min, #etages_nbre_max, #longueur_min, #longueur_max, #murs, #repeter, #etirer, #sequence	),
	
	public
		presets 	= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\façades\\"		)	\
														fichier_categorie:			"Urba - Façades"	\
														fichier_extension:			"fcd"	\
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
		
		fn charger 		 	_this =(
			presets.charger  facade_courante
			actualiser		_this 
		),
		
		fn enregistrer 	 =(
			presets.enregistrer  facade_courante
		),
		
		fn get_composants_total 				_this		=(
			local result =#()
			for comp in _this.facades_composants 	do (
				local nvComposant =   str_facade_composant ()
				datasMgr.set_datas_string		comp		nvComposant	_this
				append result nvComposant
			)
-- 			debug "get_composants_total"
-- 			debug "result" var:result
			result
		),
		
		
		fn get_composant			_idUnique	_this	=(
			local result
-- 			debug "get_composant - _idUnique" var:_idUnique
			local composants = get_composants_total 				_this	
			for compo in composants do
				if compo.id == _idUnique do result = compo
-- 			debug "get_composant - result" var:result
			result
		),
		
		fn get_composants 				_this		=(
			local result =#()			
			for comp in facade_courante.sequence 	do (
				append result ( get_composant comp.id _this )
			)
-- 			debug "get_composants"
-- 			debug "result" var:result
			result
		),
		
		fn afficher_composant 		_id	_this	=(
			composant_courant = get_composant 	facade_courante.sequence[_id]		_this
		),
		
		
		fn get_idComposant_fromIdUnique		_idUnique	_this	=(
			local composants = get_composants_total 	_this	
			local result = 0
			for i= 1 to 	composants.count	 do
				if composants[i].id == _idUnique do result = i
			result
		),
		
		/* 
		fn enregistrer_composant		_this =(
			
			local id_compo = get_idComposant_fromIdUnique		composant_courant.id	_this
			
			_this.facades_composants[id_compo] = (datasMgr.get_datas_string  composant_courant)
			_this.actualiser_rollouts ()
		),
		*/
		
		fn enregistrer_composant	 _composant	_this =(
			debug "enregistrer_composant"
			debug "_composant" var:_composant.nom
			
			local id_compo = get_idComposant_fromIdUnique		_composant.id		_this
			local string_compo = (datasMgr.get_datas_string  _composant)
			debug "string_compo" var:string_compo
			debug "id_compo" var:id_compo
			
			if id_compo != 0 then (
				debug "enregistrer_composant ---> MISE A JOUR : EXISTE DEJA" 
				_this.facades_composants[id_compo] =	string_compo
			) else (
				debug "enregistrer_composant ---> MISE A JOUR : NOUVEAU" 
				append	_this.facades_composants			string_compo
			)
			debug "enregistrer_composant ---> MISE A JOUR : OK" 
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
			debug "get_items"
			local result =#()
			for facde in _this.facades_items 	do (
				debug "facde" var:facde
				local nvlFacade =   str_facade ()
				datasMgr.set_datas_string		facde		nvlFacade	_this
				append result nvlFacade
			)
			debug "get_items - result" var:result
			result
		),
		
		
		
		
		
		fn get_modeles 	_this =(
			local result =#()
			for modele_strg in _this.facades_modeles do (
				local modeleTmp =   str_facade_modele ()
				datasMgr.set_datas_string		modele_strg	modeleTmp	_this
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
		
		
		fn enregistrer_modele		_modele	_this =(
			
			local id_modele = get_idModele_fromIdUnique		_modele.id	_this
			
			if id_modele != 0 then
				_this.facades_modeles[id_modele] = (datasMgr.get_datas_string  _modele)
			else
				append	_this.facades_modeles		(datasMgr.get_datas_string  _modele)
			
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
			facade_courante 	= datasMgr.set_datas_string 		_this.facades_items[id_courant]  	 facade_courante		_this
			
			
			include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms"
			dialog = roll_urba_editeurFacades
			
			---- creation de la fenetre ----
			createDialog dialog 	style:				#(#style_resizing) 	\
										pos:				dialog_pos
-- 										lockHeight:		true						\
-- 										lockWidth:		true						\
			dialog_estOuvert = true
			
			---- initialisation de la fenetre ----
			dialog.m_prt	 	= this
			dialog.m_cible 		= _this
			dialog.m_facade 	= facade_courante
			
			dialog.initialiser ()
			
		),
		
		
		
		
		
		--------- INTERFACE ----------------------
		fn valider_facade		_this =(
			_this.facades_items[id_courant] = ( datasMgr.get_datas_string  facade_courante )
			_this.actualiser_rollouts ()
			
			debug "valider_facade"	
			for compo in facade_courante.sequence do (
				debug "compo" var: compo
				
				enregistrer_composant	compo	 _this 
			)
			debug "valider_facade FIN OK?!?!,######################################################################################################"	
				
		),
		
		fn ajouter_modele				_composant	_node	_this	=(
			
			--- preparation du model -------
			local nd_Tmp 			=  _node
			local transformBack 	=	_node.transform
			positionnerPivot_modele 	nd_Tmp
			nd_Tmp.rotation = quat 0 0 0 1
			nd_Tmp.pos  = [0,0,0]
			
			--- creation de l'objet ----
			local nvModele = 		scan.get_datas 		nd_Tmp			
			if 	_composant.longueur < nvModele.longueur	do
				_composant.longueur = nvModele.longueur			
			nvModele.nom		+=	" " + _composant.modeles.count as string
			_node.transform 	= 		transformBack
			
			--- on le range dans les tableaux -----
			append _composant.modeles				nvModele
			append _composant.modeles_probas 	100
			
			--- on l'enregistre dans les parmatere du batiment -----
			enregistrer_modele		nvModele 	_this
			
		),
		
		fn ajouter_composant		_pos	 _type	_this =(
			
			local 		nvComposant 	= str_facade_composant 	type:_type
			
			insertItem 			nvComposant 		facade_courante.sequence 	( _pos + 1 )
			
			enregistrer_composant		nvComposant 	_this
			
			nvComposant
			
		)
		
		
		
		
		/* 
		fn ajouter_espacement		_pos		_this =(
			debug "ajouter_espacement"
			local 		nvComposant 	= str_facade_composant ()		
			nvComposant.type			= #Espacement
			insertItem 	nvComposant.id 		facade_courante.sequence 	(_pos+1)
			append _this.facades_composants (datasMgr.get_datas_string  nvComposant)
			actualiser _this
		),
		fn ajouter_longueurFixe		_pos	_this =(
			debug "ajouter_longueurFixe"
			local 		nvComposant 	= str_facade_composant ()		
			nvComposant.type			= #LongueurFixe
			insertItem 	nvComposant.id 		facade_courante.sequence 	(_pos+1)
			append _this.facades_composants (datasMgr.get_datas_string  nvComposant)
			actualiser _this
			
		),
		fn ajouter_modele			_pos		_this =(
			debug "ajouter_modele"			
			local 		nvComposant 	= str_facade_composant ()		
			nvComposant.type			= #Modele
			insertItem 	nvComposant.id 		facade_courante.sequence 	(_pos+1)
			append _this.facades_composants (datasMgr.get_datas_string  nvComposant)
			
			actualiser _this
		)
		*/
		
		
		/* 
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
			enregistrer_composant		_this
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
			enregistrer_composant		_this
		),
		fn set_longueurMax_composant				val		_this	=(
			composant_courant.longueur_max = val
			enregistrer_composant		_this
		),
		fn set_longueurMax_composantState			state		_this	=(
			composant_courant.longueur_maxEnable = state
			enregistrer_composant		_this
		),
		
		fn ajouter_modele				state		_this	=(
			modele_courant	 = str_facade_modele ()
			append composant_courant.modeles_ids 			( modele_courant.id )
			append composant_courant.modeles_probas 	100
			modele_courant.nom	+=	" " + composant_courant.modeles_ids.count as string
			append _this.facades_modeles		( datasMgr.get_datas_string  modele_courant )
			enregistrer_composant		_this
		),
		fn supprimer_modele				state		_this	=(
			
		),
		
		fn set_proba_modele				val		_this	=(
			
			local idModel = get_idModele_fromIdUnique	modele_courant.id	_this
			composant_courant.modeles_probas[idModel] = val
			enregistrer_composant		_this
		),
		
		fn assigner_node 	_node	_this =(			
			debug "assigner_node"
			
			--- preparation du model -------
			local nd_Tmp =  _node 
			
			positionnerPivot_modele 	nd_Tmp
			nd_Tmp.rotation = quat 0 0 0 1
			nd_Tmp.pos  = [0,0,0]

			local modeleTmp = 		scan.get_datas 		nd_Tmp
			if 	composant_courant.longueur < modeleTmp.longueur	do
				composant_courant.longueur = modeleTmp.longueur
			
			modele_courant.verts	 	=	modeleTmp.verts	
			modele_courant.edges	 	=	modeleTmp.edges
			modele_courant.faces	 	=	modeleTmp.faces
			modele_courant.SMs	 		=	modeleTmp.SMs 
			modele_courant.matIDs	 	=	modeleTmp.matIDs
			
			enregistrer_composant	_this
			enregistrer_modele		_this
			
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
		*/
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
				append result _trace[i]
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

























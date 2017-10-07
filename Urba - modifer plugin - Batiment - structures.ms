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
		
-- 		format "modele_result :%\n" modele_result
		modele_result
	),

	fn creer_objet		_modele		_this		ndDest:		transf_mtrx:	=(
		
		if ndDest == unsupplied do
			ndDest = _this.delegate
		
		local verts		
		if transf_mtrx != unsupplied then 
			local verts = for  pt in _modele.verts  collect pt *= transf_mtrx
		else verts = _modele.verts
		
			
		local vrts_avtOp 	= polyop.getNumVerts 		ndDest
		local faces_avtOp 	= polyop.getNumFaces 	ndDest
		
		-- les vertex -- 
		for vert in  verts do 
			polyop.createVert ndDest	vert
			
		-- les edges -- 
		local edges = _modele.edges
		for edge_pts in  edges do 
			polyop.createEdge ndDest		(vrts_avtOp + edge_pts[1] )	( vrts_avtOp + edge_pts[2] )
		
		-- les faces -- 
		local faces = _modele.faces
		for face_pts in  faces do (
			face_pts = for face_pt in face_pts collect ( vrts_avtOp + face_pt )
			polyop.createPolygon	 ndDest		face_pts
		)
		--- les smoothing group ----
		local SGs = _modele.SMs
		for i = 1 to  SGs.count do 
			polyop.setFaceSmoothGroup	 ndDest		( faces_avtOp + i )  SGs[i]
		
		--- les material ID ----
		local matIDs = _modele.matIDs
		for i = 1 to  matIDs.count do 
			polyop.setFaceMatID	 ndDest		( faces_avtOp + i )  matIDs[i]
		
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
				local prop = ( getProperty  _element 	param )
				local type = classof prop
				
-- format  "get_datas_string	--->	param  :%\n" param
-- format  "get_datas_string	--->	type  :%\n" type
-- format  "get_datas_string	--->	superClassof  :%\n" (superClassof prop )
				
				case type of (
					
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					
					--- les trucs qu'on prend en compte	------
					/* string:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					) */
					array: (
						local tabString = ""
						for item in prop do (
							
							case classof item  of (
								string:	tabString += item 		as string + separateur_items
								Integer:	tabString += item 		as string + separateur_items
								Float:	tabString += item 		as string + separateur_items
								
								Point3:	tabString += item 		as string + separateur_items
								Array:	( 
									tabString += item 		as string + separateur_items
									
								)
								---- les reste doit etre nos struct a nous ... -------
								default:	(
-- 									format "---->Default\n" 
									tabString += item.id 	as string + separateur_items
								)
							)
						)
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					Name:		(
						txtResult+=  param as string  + separateur_mutation	+	"#" + prop as string  + separateur_params
					)
					default:						(
					/* 	if superClassof prop == StructDef then
							txtResult+=  param as string  + separateur_mutation 	+	prop.id  + separateur_params
						else */
							txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				) -- fin scase --
				
			)
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 	_this	=(
			
-- 			stack ()
			
			local datasTab 	= filterString _datas_string 		separateur_params
			local propNames 	= getPropNames _element
			
			for datas in datasTab do (
				
				local dataTab		= filterString datas 	separateur_mutation
				local propNom 	= dataTab[1]
				local typeProp 	= classof ( getProperty _element propNom  )
				
-- format  "set_datas_string	--->	propNom :%\n" propNom
				case typeProp of (
					
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					
					--- les trucs qu'on prend en compte	------
					string:					(
						
-- 							--- on tente le struct ---
-- 							local data =  ( m_prt.get_parametre_parID	  dataTab[2] 	_this	)	
-- 							
-- 							--- si pas struct ---
-- 							if data == undefined do
							local data =   dataTab[2]
							
							if data   == undefined do data =""
							setProperty _element propNom data
					)
					array: (
 format  "set_datas_string	--->	ARRAY		propNom :%\n" propNom
						if dataTab.count >1 do (
							local datas_liste  = filterString	dataTab[2] 	separateur_items
							local tabResult =#()
							for data in datas_liste do (
								
								local data_exe 	= execute data
								
								if data_exe 		== undefined then (
								--------------- string ---------------
									append tabResult ( data)
								) else	if classof data_exe == Name then (	
								
								--------------- un objet ---------------
									local elemTmp =  ( m_prt.get_parametre_parID	  ( data ) 	_this	)	
									
									--- un id (name)------
									if elemTmp == undefined do
										elemTmp = data
									
-- format  "set_datas_string	--->	elemTmp :%\n" elemTmp
									
									
									append tabResult		elemTmp
									
								) else 	(						
								--------------- Nombres ---------------			
									append tabResult 	( data_exe)
								)
							)
							setProperty _element 	propNom 	tabResult
						)
					)
					default:						(
						if dataTab[2] != undefined do  (
							
							local data = execute dataTab[2]
							
							setProperty _element propNom data
						)
						
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
		constr_ptr,
	
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
		
	public
		facades_total				= #(), ---- les facades du batiment en struct---------------
		composants_total		= #(), ---- les composant du batiment en struct---------------
		modeles_total				= #(), ---- les modeles du batiment en struct---------------
		parametriques_total		= #(), ---- ---------------
		
		facade_courante 			= str_facade (),
		id_courant = 0,
		composant_courant 	,
		modele_courant	,
		
		
		
		
		--------------------------------------------------------------------------------------------------------
		----------------	 Accessions				 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------
		
		----------------	Composants 	----------------
	public
		fn get_composant_idUnique_param	_id _this =(
			local strg_param 	= _this.facades_composants[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_CMP_"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
		),
		fn get_composants_ids_param 	_this =(
			local result =#()
			for i = 1 to _this.facades_composants.count	 do (
				append result  ( get_composant_idUnique_param i	_this )
			)
			result
		),
		fn get_composant_idParam		_idUnique	_this	=(
			
			local composants_ids = get_composants_ids_param 	_this	
			local result = 0
			for i= 1 to 	composants_ids.count	 do
				if composants_ids[i] == _idUnique do result = i
			result
		),
		
		fn get_composant			_idUnique	_this	=(
			
			local result
			for compo in composants_total do
				if compo.id == _idUnique do result = compo
			result
			
		),
		
		
		
		----------------	Modeles	 ----------------
		fn get_modele_idUnique_param	_id 	_this =(
			local strg_param 	= _this.facades_modeles[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_MOD_"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
		),
		fn get_modeles_ids_param 	_this =(
			local result =#()
			for i = 1 to _this.facades_modeles.count	 do (
				append result  ( get_modele_idUnique_param i	_this )
			)
			result
		),
		fn get_modele_idParam		_idUnique	_this	=(
			
			local modeles_ids = get_modeles_ids_param 	_this	
			local result = 0
			for i= 1 to 	modeles_ids.count	 do
				if modeles_ids[i] == _idUnique do result = i
			result
		),
		fn get_modele		_idUnique	_this	=(
			local result
			for modele in modeles_total do
				if modele.id == _idUnique do result = modele
			result
		),
		
		
		
		----------------	Composants 	parametriques 	----------------
		fn get_parametrique_idUnique_param		_id 	_this =(
			local strg_param 	= _this.facades_parametriques[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_P"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
			
		),
		fn get_parametriques_ids_param 	_this =(
			local result =#()
			for i = 1 to _this.facades_parametriques.count	 do (
				append result  ( get_parametrique_idUnique_param 	i	_this )
			)
			result
		),
		fn get_parametrique_idParam		_idUnique	_this	=(
			
			local modeles_ids = get_parametriques_ids_param 	_this	
			local result = 0
			for i= 1 to 	modeles_ids.count	 do
				if modeles_ids[i] == _idUnique do result = i
			result
		),
		
		fn get_parametrique		_idUnique	_this	=(
			local result
			for param in parametriques_total do
				if param.id == _idUnique do result = param
			result
		),
		
		
		
		----------------	 get universelle 	---------------------
		fn get_parametre_parID	_iUnique		 _this =(
			
			---- un composant ------------
			local elemTmp =  ( get_composant  _iUnique 	_this	)	
			
			---- un modele ------------
			if elemTmp == undefined do 
				elemTmp = ( get_modele  _iUnique 	_this	)	
			
			---- un parametrique ------------
			if elemTmp == undefined do 
				elemTmp = ( get_parametrique  _iUnique 	_this	)	
			
			elemTmp
		),
		
		
		
		

		
		
		--------------------------------------------------------------------------------------------------------
		----------------	 PARAM  <---->  STRUCT 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------
	public
		----- pour recuperer les parametres du plug et en faire des trucs -----
		fn params_toStructs 	_this	=		(
			
			------ Modeles -------
			modeles_total				= #()
			for modele in _this.facades_modeles 	do (
				local nvModele =   str_facade_modele ()
				datasMgr.set_datas_string		modele		nvModele	_this
				append modeles_total 	nvModele
			)
			
			------ Parametriques -------
			parametriques_total				= #()
			for strg_param in _this.facades_parametriques 	do (
				local nvParam 					
				local idStrg 		= findstring 	strg_param		"#FAC_P"
				local type	 		= substring 	strg_param 	(idStrg+6)	  2 
				case type of (
					"MP": 	nvParam = str_facadeParam_murPlein ()
					"BS":		nvParam = str_facadeParam_baieSimple ()
					"BT":		nvParam = str_facadeParam_baie ()
				)
				datasMgr.set_datas_string			strg_param		nvParam		_this
				append parametriques_total 		nvParam
			)
			
			
			------ Composants -------
			composants_total		= #()
			for compo in _this.facades_composants 	do (
				local nvCompo =   str_facade_composant ()
				datasMgr.set_datas_string		compo		nvCompo	_this
				append composants_total 		nvCompo
				if nvCompo.type == #parametrique do
					nvCompo.param[1].actualiser 	nvCompo		constr_ptr
			)
			
			------ Façades -------
			facades_total				= #()
			for fac in _this.facades_items 	do (
				local nvfacade =   str_facade ()
				datasMgr.set_datas_string		fac		nvfacade	_this
				append facades_total 		nvfacade	
			)
			
		),
				----- ecires les structs dans les parametres  du plug -------------------------------------
		fn enregistrer_parametrique		_param	_this =(
			
			local id_param = get_parametrique_idParam		_param.id		_this
			
			if id_param != 0 then
				_this.facades_parametriques[id_param] = 	(datasMgr.get_datas_string  _param)
			else
				append	_this.facades_parametriques			(datasMgr.get_datas_string  _param)
			
		),
		fn enregistrer_modele		_modele	_this =(
			
			local id_modele = get_modele_idParam		_modele.id	_this
			
			if id_modele != 0 then
				_this.facades_modeles[id_modele] = 	(datasMgr.get_datas_string  _modele)
			else
				append	_this.facades_modeles			(datasMgr.get_datas_string  _modele)
			
		),
		
		fn enregistrer_composant	 _composant	_this =(
			
			local id_compo 			= get_composant_idParam		_composant.id		_this
			
			local string_compo 		= (datasMgr.get_datas_string  _composant)
			
			if id_compo != 0 then (
				_this.facades_composants[id_compo] =	string_compo
			) else (
				append	_this.facades_composants			string_compo
			)
			
		),
		
		fn enregistrer_facade		_facade		_this =(
			
			local id_compo 		= id_courant
			local string_compo 	= (datasMgr.get_datas_string  _facade )
			
			if id_courant != 0 then
				_this.facades_items[id_courant] = (datasMgr.get_datas_string  _facade)
			else
				append	_this.facades_items		(datasMgr.get_datas_string  _facade)
			
		),
		
		
		
		
		
		--------------------------------------------------------------------------------------------------------
		----------------	 Manipulations MODELE	 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------		
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
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		--------------------------------------------------------------------------------------------------------
		----------------	 Interface				 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------	
		fn valider_facade		_this =(
			
			local sequence_longueur = 0
			
			for compo in facade_courante.sequence do (
				
				sequence_longueur += compo.longueur
				
				for modele in compo.modeles do (
					enregistrer_modele	modele	 _this 
					
				)
				
				enregistrer_parametrique	compo.param[1]	 _this 
				enregistrer_composant		compo	 		_this 
			)
			
			facade_courante.sequence_longueur = sequence_longueur
			enregistrer_facade		facade_courante		_this 
-- 			debug "valider_facade FIN OK?!?!,######################################################################################################"	
			
			
			
			_this.actualiser_rollouts ()	
			_this.construire.batiment 	_this
			
		),
		
		
		
		
		
		
		--------------------------------------------------------------------------------------------------------
		----------------	 Constructeurs			 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------	
		fn creer_facade 						_this	=(
			local nvlFacade = str_facade ()
			
			nvlFacade.nom	+=	" " + (_this.facades_items.count + 1  ) as string
-- 			append _this.facades_items (datasMgr.get_datas_string  nvlFacade)
			append facades_total	nvlFacade
			nvlFacade
		),
		
		
		fn creer_modele				_composant	_node	_this	=(
			
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
			
			append modeles_total	nvModele
			
			
		),
		
		fn creer_composant		_pos	 _type	_this 		param_type:		=(	--- param_type: pour creation composant parametrique	--->	#MurPlein	, 	#BaieSimple, 
			debug "creer_composant"
			
			local nvComposant 	= str_facade_composant 	type:_type
			local nvParam
			case param_type as name of (
				#MurPlein:			nvParam 	= 	str_facadeParam_murPlein		()		
				#BaieSimple:		nvParam 	= 	str_facadeParam_baieSimple	() 
				#BaieTablette:	nvParam 	= 	str_facadeParam_baie	() 
			)
			if nvParam != undefined do (
				nvComposant.param = #( nvParam )
				nvComposant.param[1].initialiser 	nvComposant		_this.construire	
				append 		parametriques_total		nvComposant.param[1]
			)
			
			
			insertItem 	nvComposant 			facade_courante.sequence 	( _pos + 1 )			
			append 		composants_total	nvComposant
			
			nvComposant
			
		),
		
		fn supprimer	_id	_this		 	=(
			debug "supprimer -> TODO"
			/*
			deleteItem _this.facades_items 	_id
			*/
		),
		
		
		
			
		
		--------------------------------------------------------------------------------------------------------
		----------------	 FENETRE				 	----------------------------------------------------
		--------------------------------------------------------------------------------------------------------	
		fn est_ouvert = dialog_estOuvert,
		fn fermer 						_this		quiet:false	=(
-- 			debug "Fermer rollout"
			
-- 			stack  ()
			
			if not quiet do
				if queryBox "Enregistrer les modifications ?"	title:"Urba | Bâtiment | Façade" 	do 
					valider_facade 	_this
					
			
			--- Actiualiser position pour reouverture prochaine ----
			if dialog_estOuvert do
				dialog_pos = getDialogPos dialog	
			dialog_estOuvert = false
			---- fermer la fenêtre ----
			try destroydialog dialog catch ()
		),
		fn ouvrir  			_id 		_this =(
			
			id_courant 			= _id
			facade_courante 	= str_facade ()
			facade_courante 	= facades_total[_id]	--datasMgr.set_datas_string 		_this.facades_items[id_courant]  	 facade_courante		_this
			
			
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
			
		)
		
		
) ---------- fin struct FACADES ----------------------





struct	str_manipEdiPoly_creer	(
	
	
	fn points	_liste_pts_position	_this	=(
		local result = #()
		for pos_pts in _liste_pts_position do 			
			append result ( polyop.createVert 	_this.delegate		pos_pts )
		result
	),
	fn edges		_liste_pts_id		_this		fermer:false	=(
		local result = #()
		
		for i = 1 to _liste_pts_id.count - 1	 do 	(	
			local pt_id_1 = _liste_pts_id[i]
			local pt_id_2 = _liste_pts_id[i+1]
			append result ( polyop.createEdge 	_this.delegate	 pt_id_1	 pt_id_2 )
		)
		if fermer do (
			local pt_id_1 = _liste_pts_id[_liste_pts_id.count]
			local pt_id_2 = _liste_pts_id[1]
			append result ( polyop.createEdge 	_this.delegate	 pt_id_1	 pt_id_2 )
		)
		result
	),
	fn face		_liste_pts_id		_this		=(
		local result = polyop.createPolygon _this.delegate  _liste_pts_id
		result
	)
	
	/*
	--- RAJOUTER PT SUR EDGE ---------
	local nvVert = polyop.divideEdge 	<Poly poly> 	<int edge>	 <float fraction>
	*/
	
)



----------- Creation des geometries poly ----------------
struct str_geo (
	creer = str_manipEdiPoly_creer (),
	
	fn vider 											_this								=(
		if (polyop.getNumFaces _this.delegate) >0 do (
			local listeDesFaces = #{1..(polyop.getNumFaces _this.delegate)} as array
			polyop.deleteFaces _this.delegate	listeDesFaces		delIsoVerts:true
			polyop.deleteIsoVerts _this.delegate
		)
	),
	
	
	
	
	
	
	
	
	
	
	
	
	
	fn creerFace  		_listeDesPoints  	_this	 nd: 								=(
		
		
		local  ndCible 	= if nd != unsupplied then nd else _this.delegate
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
	
	
-- 	creerFaceVerticale 	pt1 	pt2 	( z + hauteur_modele )		_this 		ht:hauteurQuiReste	
-- 	_this.niveaux_hauteur 
	
	fn creerFaceVerticale 	pt1 	pt2 	z 	_this				ht:			=(
		
		local VERSION_BACK = true
		
		if not VERSION_BACK then (
			------------	NOUVELLE VERSION	----------------
			
			
		) else (  
			------------	VERSION BACK 	----------------
				
			local hauteur 
			if ht != unsupplied then	hauteur = ht
				else hauteur 	=	_this.niveaux_hauteur 
			
			local verts = polyop.getNumVerts _this.delegate		
	-- 		format "verts avant :%\n" verts
			
			polyop.createVert _this.delegate	[pt2.x, pt2.y, z]	
	-- 		format "result :%\n" result
			polyop.createVert _this.delegate	[pt1.x, pt1.y, z]
			polyop.createVert _this.delegate	[pt1.x, pt1.y, z + hauteur]
			polyop.createVert _this.delegate	[pt2.x, pt2.y, z + hauteur]
			
	-- 		format "polyop.getNumEdges delegate :%\n" (polyop.getNumEdges delegate)
			
			polyop.createEdge _this.delegate (verts+1) (verts+2)
			polyop.createEdge _this.delegate (verts+2) (verts+3)
			polyop.createEdge _this.delegate (verts+3) (verts+4)
			polyop.createEdge _this.delegate (verts+4) (verts+1)
			
			polyop.createPolygon _this.delegate  #((verts+4),(verts+3),(verts+2),(verts+1))
		)
	),
	fn creerFacesContour	ptsContours	 altitude 		hauteur 		_this	=(
		
		local VERSION_BACK = true
		
		if not VERSION_BACK then (
			------------	NOUVELLE VERSION	----------------
			
			
		) else (  
			------------	VERSION BACK 	----------------
			
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
				
				local nvlFace = creerFaceVerticale 		pt_1		pt_2 	altitude 	_this	ht:hauteur
				if nvlFace != undefined do
					appendIfUnique facesDuContour	nvlFace
			)
			
			facesDuContour
			
		)
	)
	
) --- fin struct geo

----------- Tracé du batiment et autres manipulations----------------
struct str_trace (
		geo_ptr,
		-----------------  Opérations diverses ----------------------
		fn surface 							_trace 	_this =(
			--- on creer une face sur le tracé ---------
			local faceTemp = geo_ptr.creerFace 	_trace  _this	--nd:nvNode
			
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
				_thisNode.surface = surface 		_thisNode.trace_courant	_thisNode
			)
			actualiser  _thisNode
		)
		
) -- fin struct TRACE ---------

























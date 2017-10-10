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
					"ES":		nvParam = str_facadeParam_espacement ()
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
				#Espacement:		nvParam 	= 	str_facadeParam_espacement	() 
				default:				()
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
	
		
		----- MURS -----------------
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
		
		
		
		
		-----------------  Optimisation ----------------------
		fn orthonormer 	_this		=(
			
			local mtrx_AP = _this.axeP_mtrx
			
			for i = 1 to _this.trace_courant.count do (
				
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt = _this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = _this.trace_courant[j] *  inverse mtrx_AP 
				local vec_moyenne 
				
				local estPignon = findItem _this.idtrace_pignons i != 0 
				if not estPignon then (
					local moyenneX = ( pt_suivant.x - pt.x ) /2					
					vec_moyenne = [moyenneX,0,0] * _this.seuil_ortho / 100
				) else  (
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					 vec_moyenne = [0,0,moyenneZ] * _this.seuil_ortho / 100
				) 
				
				pt 			= _this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				_this.trace_courant[i] = pt *   mtrx_AP 
				_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
			)
		/* 	--- les Gouttereaux  --
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
			) */
			
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
				dot
				i +=1
			)

			result
		),
		fn chercher_alignements		_idTest		_this		=(	
			
			local seuil 			= _this.seuil_aligner	
			local mtrx_AP 	= _this.axeP_mtrx
			local pt_test					= _this.trace_courant[_idTest]		* inverse  mtrx_AP
			local result =#()
			
			if est_pignon  	_idTest		_this	 then 	(
				----- PIGNONS --------
-- 	 					format 	"	---->PIGNONS\n"
					
				for i in _this.idtrace_pignons do (
					local j = i + 1
					if j > _this.trace_courant.count do j = 1
					local pt 					= _this.trace_courant[i]	* inverse  mtrx_AP
					
					local pt_suivant 			= _this.trace_courant[j]	* inverse  mtrx_AP
					
					if abs ( pt_test.z - pt.z ) < seuil do (
	-- 					format 	"	---->proches sur X !!!\n"
						appendIfUnique result i
					)
					if abs ( pt_test.z - pt_suivant.z ) < seuil do (
	-- 					format 	"	---->proches sur X Suiovant    !!!\n"
						appendIfUnique result i
					)
					
				)
				
			)	else 	(
				----- GOUTTEREAUX --------
-- 	 					format 	"	---->GOUTTEREAUX\n"
				
				for i in _this.idtrace_gouttereaux do (
					local j = i + 1
					if j > _this.trace_courant.count do j = 1
					local pt 					= _this.trace_courant[i]	* inverse  mtrx_AP
					
					local pt_suivant 			= _this.trace_courant[j]	* inverse  mtrx_AP
					
					if abs ( pt_test.x - pt.x ) < seuil do (
	-- 					format 	"	---->proches sur X !!!\n"
						appendIfUnique result i
					)
					if abs ( pt_test.x - pt_suivant.x ) < seuil do (
	-- 					format 	"	---->proches sur X Suiovant    !!!\n"
						appendIfUnique result i
					)
					
				)
				
			)

			result
		),
		fn aligner				_this		=(	
			
			local mtrx_AP 	= _this.axeP_mtrx
			
			for i = 1 to   _this.trace_courant.count  do (
				
				local aligns = 	chercher_alignements		i		_this	
				
				local pt_moyenne = [0,0,0]
				for id_align in aligns do 
					pt_moyenne += _this.trace_courant[id_align]	* inverse  mtrx_AP
				pt_moyenne /=  aligns.count
				
				for id_align in aligns where  not est_pignon  	id_align		_this	 do (
					local pt 			= _this.trace_courant[id_align]	* inverse  mtrx_AP  
					local j = id_align + 1
					if j > _this.trace_courant.count do j = 1
					local pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  
					local vec_moyenne1 	= pt_moyenne	 - pt
					local vec_moyenne2 	= pt_moyenne	 - pt_suivant
					local vec_align1 		= [vec_moyenne1.x,0,0] 
					local vec_align2 		= [vec_moyenne2.x,0,0] 
					
					pt 			= _this.trace_courant[id_align]	* inverse  mtrx_AP  	+ vec_align1 
					pt_suivant 	= _this.trace_courant[j]			* inverse  mtrx_AP  	+ vec_align2
					_this.trace_courant[id_align] = pt *   mtrx_AP 
					_this.trace_courant[j] = pt_suivant *   mtrx_AP 
					
				)
				
			)
		),
		
		
		
		
		
		
		
		fn intersection 	_pt_orig 	_pt_2 		_pt_seg_1 	_pt_seg_2  	_this	 =(
			local pt_result
			local seuil = 1
			
			local vec_proj		= _pt_orig - _pt_2
			local vec_seg		= _pt_seg_1 - _pt_seg_2
			
			local norm_proj		= normalize vec_proj
			local norm_seg		= normalize vec_seg
			local dot_proj_seg 	= dot norm_proj norm_seg
			
			
			--- si pas parallele -------------------------
			local a1, b1, a2, b2 
			local d1_vert = false
			local d2_vert = false
			if dot_proj_seg != 1 and dot_proj_seg != -1 do (
				
-- 				format "pas parallele"
				
				--- données pour les eaquations de droite y = ax + b ----
				-- droite projeté----------------------
				if (( _pt_orig.z *1000) as integer /1000  == ( _pt_2.z *1000) as integer /1000) then (
					-- horizontale --
					a1 = 0
					b1 	= _pt_orig.z 
				) else if (( _pt_orig.x *1000) as integer /1000  == ( _pt_2.x *1000) as integer /1000) then (
					-- verticale --s
					a1 	= 1
					b1 	= _pt_orig.z - _pt_orig.x
					d1_vert = true
				) else (
					a1 	= (_pt_orig.z - _pt_2.z ) / (_pt_orig.x - _pt_2.x)
					b1 	= _pt_orig.z - a1*_pt_orig.x
				)		
				-- droite reception
				if _pt_seg_1.z == _pt_seg_2.z then (
					-- horizontale --
					a2 = 0
					b2 	= _pt_seg_1.z 
				) else if _pt_seg_1.x == _pt_seg_2.x then (
					-- verticale --
					a2 	= 1
					b2 	= _pt_seg_1.z - _pt_seg_1.x
					d2_vert = true
				) else (
					a2 	= (_pt_seg_1.z - _pt_seg_2.z ) / (_pt_seg_1.x - _pt_seg_2.x)
					b2 	= _pt_seg_1.z - a2*_pt_seg_1.x
				)
				
				
				
				
				local x, y
-- 				if a1 != a2 then (
				if 	d1_vert then (
					if not d2_vert do (
						x =   _pt_orig.x
						y =   a2 * x + b2
					)
				) else 	if 	d2_vert then (
					if not d1_vert do (
						x =   _pt_seg_1.x
						y =   a1 * x + b1
					)
				) else (
						x =   ( b2 - b1 ) / (a1  - a2 )
						y =   a1 * x + b1
				)
-- 				)
				
				-- si on a un point on verifie la suite -----------------------------
				if x != undefined do (
					
-- 				format ", on a un point"
					local pt_proj  = [x,0,y]
					
					if distance pt_proj  	_pt_seg_1 > seuil  and distance pt_proj  	_pt_seg_2 > seuil  do (
						
-- 						format ", sup au seuil"
					
						if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
							
-- 							format ", on est dans le bon sens"
							local precision = 1000
							local dist_seg 		= ( ( distance _pt_seg_1 	_pt_seg_2 ) * precision as integer ) / precision
							local dist_ptProj 		= ( ( distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj ) * precision as integer ) / precision							
-- 							format "( dist_seg: %,  dist_ptProj:%)" dist_seg  dist_ptProj
							
							if  dist_ptProj  as string == dist_seg as string  do (
								format "PROJECTION ! \n"
-- 								format ", et on est dans le segment !"
								pt_result 	= pt_proj
							)
						)
					)
				)
				
-- 				format "\n"
			)
			pt_result
		),
		
		
		
		
		pts_concaves =#(),
		
		fn boucler 	_array	_id_item 		=(
-- 			format "boucler _id_item:% _array.count:%\n"  _id_item	 _array.count
-- 			number values
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
		
		fn scan_concaves 		_this =(
			
			local seuil 			= 1
			local mtrx_AP 	= _this.axeP_mtrx
			local trace 		= _this.trace_courant
			
			-- on vide la liste des points concaves -----------------
			pts_concaves =#()
			
			---- chercher les prolongations  des segments  sur le tracé -----------------
			
-- 			format "scan_concaves, trace count:%\n" trace.count
			for i = 1 to  trace.count 	do (
				
-- 			format "\nscan_concaves, ---------------> % <---- \n" i
				local pt_orig				= trace[ i ]	* 	inverse  	mtrx_AP  
				local id_direction_suiv	= boucler	trace ( i+1) 
				local id_direction_prec	= boucler	trace ( i-1)				
				local pt_suiv		=	trace[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
				local pt_prec		= 	trace[ id_direction_prec ] * 	inverse  	mtrx_AP
				
				for compteur_segment = 0 to trace.count - 4 do (
					
					local id_seg_1 = boucler trace	( i + compteur_segment + 2 ) 
					local id_seg_2 = boucler trace  ( i + compteur_segment + 2 + 1 )	
					local pt_seg_1		= trace[ id_seg_1 ]	* 	inverse  	mtrx_AP
					local pt_seg_2		= trace[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
					
					local est_dans_trace = false
					local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2		 _this
-- 						format "pt_proj ? :%\n" pt_proj
					if pt_proj != undefined   do	(
						format "------> pt_proj !!: %\n" i
						if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do
							appendIfUnique			 pts_concaves	i
					)
					local pt_proj2 = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	_this
					if pt_proj != undefined   do	(
						format "------> pt_proj !!: %\n" i
						if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do
							appendIfUnique		 pts_concaves	i
					)
				)
			)
			format "pts_concaves :%\n" pts_concaves
		),
		
		
		fn est_concave  _id =(
			findItem	pts_concaves	_id != 0
		),
		
		
		fn trouver_pt 		_arraydePts  	_pt 	 =(
			local result = 0
			local seuil = 1
			local i = 1
			while i <= _arraydePts.count and  result == 0 do (
				local pt  =_arraydePts[i]
				if distance 	pt  _pt < seuil do
					result = i
				i+=1
			)
-- 			format "pt_est_dejaPresent :%\n" result
			result
		),
		fn pt_est_dejaPresent 		_arraydePts  	_pt 	 =(
			local result = ( trouver_pt	_arraydePts	_pt ) != 0
			result
		),
		/* 
		fn subdiviser_back 		_this 		=(
			
-- 			local seuil 		=	10
			local mtrx_AP 	= _this.axeP_mtrx
			local seuil = 5
			local result
			local trace 		= _this.trace_courant
			local trace_temp =  for item in trace collect item
			
			
			---- chercher les prolongations  des segments  sur le tracé -----------------
			--global popo = #()
			
			for i = 1 to  _this.trace_courant.count 	do (
				
				--- les points -----
				local id_direction_suiv		=  boucler trace  (i+1)
				local id_direction_prec		= 	boucler trace  (i-1)
				local pt_orig		= _this.trace_courant[ i ]	* 	inverse  	mtrx_AP  
				local pt_suiv		=	_this.trace_courant[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
				local pt_prec		= _this.trace_courant[ id_direction_prec  ] * 	inverse  	mtrx_AP
				
				---- les segments a tester------------
				local compteur_segment = 0
				local est_trouve = false
				while compteur_segment <=  _this.trace_courant.count - 4 and not est_trouve do (
					
					--- le segment -----
					local id_seg_1 	= boucler trace  ( i + compteur_segment + 2 )
					local id_seg_2 	= boucler trace  ( i + compteur_segment + 2	 + 1	)
					local pt_seg_1	= _this.trace_courant[ id_seg_1 ]	* 	inverse  	mtrx_AP
					local pt_seg_2	= _this.trace_courant[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
					
					--- la projection 1 -------
					local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2	_this
					local est_dans_trace = false
					if pt_proj != undefined  do (
-- 						format "trace_temp: %\n" trace_temp
-- 						format "pt_seg_1: %\n" pt_seg_1
						if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
							
							if findItem trace_temp  ( pt_proj	* 	mtrx_AP ) == 0 do (
								local id_place = findItem trace_temp  ( pt_seg_1 * 	mtrx_AP )
								point pos:(pt_proj * _this.axeP_mtrx)	name:("pt: " + i  as string + " | " + "seg: " + id_seg_1 as string + "-" + id_seg_2 as string  + " id pl.:" + id_place as string )	size:100 
								insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
-- 								format "insertItem  % : %\n" ( pt_proj	* 	mtrx_AP ) ( id_place + 1 )
							)
							
							est_trouve = true
						)
					)
					
					--- la projection 2 -------
					local pt_proj = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	_this
					if pt_proj != undefined  do (
						
						if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
							local id_place = findItem trace_temp  id_seg_1
							
							if not est_trouve do
									if findItem trace_temp  ( pt_proj	* 	mtrx_AP ) == 0 do (
										local id_place = findItem trace_temp  ( pt_seg_1 * 	mtrx_AP )
								point pos:(pt_proj * _this.axeP_mtrx)	name:("pt: " + i  as string + " | " + "seg: " + id_seg_1 as string + "-" + id_seg_2 as string  + " id pl.:" + id_place as string )	size:100 
										insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
-- 										format "trace_temp: %\n" trace_temp
-- 										format "insertItem  % : %\n" ( pt_proj	* 	mtrx_AP ) ( id_place + 1 )
									)
								
							est_trouve = true
						)
					)
					
					compteur_segment +=  1
				)
					
			)
			_this.trace_courant = trace_temp
			
			trace_temp
		),
		 */
		
		
		
		fn subdiviser		_this 		=(
			
			format "--------------subdiviser---------------------\n"
			
			local mtrx_AP 	= _this.axeP_mtrx
			local seuil = 5
			local result
			local trace 		= _this.trace_courant
			local trace_temp =  for item in trace collect item
			
			local est_subdivise_total = false
			while not est_subdivise_total do (
				
				format "\n	--->	SUBDIVISION ---------------------\---------------------\---------------------\---------------------\---------------------\---------------------\	\n" 
				local est_subdivise = false
				local est_trouve = false
				
				local i = 1
				while i <=  trace_temp.count and not est_trouve do (
					
					format "\n		------------------------------------------	i: % 	------------------------------------\n"  i
					local id_direction_suiv		=  boucler trace_temp  (i+1)
					local id_direction_prec		= 	boucler trace_temp  (i-1)
					
					local pt_orig		= 	trace_temp[ i ]	* 	inverse  	mtrx_AP  
					local pt_suiv		=	trace_temp[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
					local pt_prec		= 	trace_temp[ id_direction_prec  ] * 	inverse  	mtrx_AP
					
					---- les segments a tester------------
					local compteur_segment = 0
					while compteur_segment <  trace_temp.count  - 2 and not est_trouve do (
						
						--- le segment -----
						local id_seg_1 	= boucler trace_temp  ( i + compteur_segment + 1 )
						local id_seg_2 	= boucler trace_temp  ( i + compteur_segment + 1	 + 1	)
						
						local pt_seg_1	= trace_temp[ id_seg_1 ]	* 	inverse  	mtrx_AP
						local pt_seg_2	= trace_temp[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
						
						format "			------	id_seg_1: %\n"  id_seg_1
						--- la projection 1 -------
						local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2	_this	
						
-- 						if i == 17 or i == 20 do format "--->	pt_proj i :%	\n" pt_proj
						
						if pt_proj != undefined  do (	
							if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
								local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
								point pos:(pt_proj * mtrx_AP)	name:("pt: " + i  as string + " | " + "seg: " + id_seg_1 as string + "-" + id_seg_2 as string  + " id pl.:" + id_place as string )	size:100 
								insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
								format "\n	--->	### projection -  i:%	sur %-%	###  -> id_place:%\n"  i	 id_seg_1	 id_seg_2 id_place
								format "	--->	### ( pt_seg_1 * 	mtrx_AP ): %	### \n"  ( pt_seg_1 * 	mtrx_AP )
								format "	--->	### trace_temp: %	### \n"  trace_temp
								est_subdivise = est_trouve = true
							)
						)
						
						--- la projection 2 -------
						local pt_proj = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	_this
						if pt_proj != undefined  do (	
							if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
								local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
								point pos:(pt_proj * mtrx_AP)	name:("pt: " + i  as string + " | " + "seg: " + id_seg_1 as string + "-" + id_seg_2 as string  + " id pl.:" + id_place as string )	size:100 
								insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
								format "\n	--->	### projection -  i:%	sur %-%	###  -> id_place:%\n"  i	 id_seg_1	 id_seg_2 id_place
								format "	--->	### ( pt_seg_1 * 	mtrx_AP ): %	### \n"  ( pt_seg_1 * 	mtrx_AP )
								format "	--->	### trace_temp: %	### \n"  trace_temp
								est_subdivise = est_trouve = true
							)
						)
						
						compteur_segment +=  1
					) -- fin while compteur_segment
					
-- 					format "sortie WHILE - compteur_segment -  i:%	- est_subdivise:%\n"  i est_subdivise
					i += 1
					
				) -- fin while i  --
				
-- 				format "sortie WHILE - i \n" 
				if not est_subdivise do est_subdivise_total = true
				
			) -- fin while not est_subdivise_total
			
-- 					format "sortie WHILE - est_subdivise_total -\n"
			_this.trace_courant = trace_temp
			
		),
		
		
		fn decouper 		_this 		=(
			
			--- on subdivise en petits rectangles en rajoutant les points projetés au tracé --------
			subdiviser 		_this
			
			--  points concaves -----------------
-- 			scan_concaves 	_this
			
			
			/* 
			
			local rects_result =#()
			local ids_result =#()
			
			local seuil 		=	10
			local mtrx_AP 	= _this.axeP_mtrx
			local trace 		= _this.trace_courant
-- 			local trace_temp =  for item in trace collect item
			
			
			
			---- chercher les prolongations  des segments  sur le tracé -----------------
			global popo = #()
			
					format "----------->_this.trace_courant.count :%\n"   _this.trace_courant.count 
			for i = 1 to  _this.trace_courant.count 	do (
				
				local seuil = 1
				local result
				local trace_temp = _this.trace_courant
-- 				format "	---->i:% \n" i 
				
				local pt_orig			= _this.trace_courant[ i ]	* 	inverse  	mtrx_AP  
				local id_direction_suiv		=  boucler trace  (i+1)
				local id_direction_prec		= boucler trace  (i-1)
				
				local pt_suiv		=	_this.trace_courant[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
				local pt_prec		= _this.trace_courant[ id_direction_prec  ] * 	inverse  	mtrx_AP
				
				--- si point projeté sur tracée -------------
				if est_concave  i  do (
					
					format "----------->est_concave  i :%\n"  i
					local id_rect_3 = i + 3 		--- 	( dernier point du rectangle possible )
					
					if id_rect_3 >	_this.trace_courant.count do id_rect_3 -= _this.trace_courant.count	
					local pt_rect_3	=	_this.trace_courant[ id_rect_3 ] 	* 	inverse  	mtrx_AP
					
					format "pt_orig:%\n"   pt_orig
					format "pt_rect_3:%\n"   pt_rect_3
					
					if abs ( pt_rect_3.x - pt_orig.x) < seuil or abs ( pt_rect_3.z - pt_orig.z ) < seuil do (
						
						
						local id_rect_1 =boucler trace  ( i + 1 )		
						local id_rect_2 = boucler trace  ( i + 2 )		
						local pt_rect_1 = _this.trace_courant[ id_rect_1 ] 	* 	inverse  	mtrx_AP	
						local pt_rect_2 = _this.trace_courant[ id_rect_2 ] 	* 	inverse  	mtrx_AP
						local sp = splineShape name:("i: " + i as string )
						addnewSpline sp
						addKnot sp 1 #corner #line ( pt_orig			* 	mtrx_AP )
						addKnot sp 1 #corner #line ( pt_rect_1		* 	mtrx_AP )
						addKnot sp 1 #corner #line ( pt_rect_2		* 	mtrx_AP )
						addKnot sp 1 #corner #line ( pt_rect_3		* 	mtrx_AP )
						close sp 1
						updateShape sp
						append popo	sp
						
					)
					
				)
					
					
					
					
			)
			format "ids_result :%\n"	ids_result
			ids_result 
			*/
		),
		
	
	
		
		
		
		------------tracé du batiment ---------------
		fn fromSpline 		_shapeNvtrace 	= (
			
			local trace_absolu					=#()
			local subSplineOuvertes 		=#()
			local nvtraceTMP 					=  copy _shapeNvtrace
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
			
			---- aligner -----------
			if _this.trace_aligner do
				aligner 		_this 	
			
			actualiser_axeP 	_this
			
			
			decouper 		_this 		
			
		),
		fn definir	 	_shapeNvtrace  		_thisNode		=(
			
			local trace_absolu					= fromSpline 	_shapeNvtrace
			if trace_absolu.count > 0 do (
				
				-- on vide les tableaux ----
				_thisNode.trace_original 			=#()
				_thisNode.trace_courant			=#()
				_thisNode.idtrace_pignons 		=#()
				_thisNode.idtrace_gouttereaux 	=#()
				
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

























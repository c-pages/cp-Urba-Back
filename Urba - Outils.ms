/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA
	Générateur de ville
	
##########################################################################################################################
	
	Outils
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [27/07/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/




------- diverses struct porteuses de parametres ----------
struct str_params_batiment (
	tracee,
	idSpline
)

struct str_styleVille (
	tracee,
	idSpline
)


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  MODELISATION et autre --------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
struct str_urba_outils (
	
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="Urba | Outils",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	m_urba,
	
	ep_ssBassement = 100,
	ep_dalle = 20,
	
	
	-------- Customs attributs / modifiers------------------------------------------------
	fn ajouterModifier_batiment 	_node	=(
		
		--- le modifier ----
		local tmpMod = emptymodifier ()
		tmpMod.name = "Urba | Bâtiment"
		addModifier _node tmpMod
		
		--- Definition	CA ---------------------
		local batimentCA_def= attributes batimentCA		(
			parameters main rollout:params			(
				
				tracee	type:#maxObjectTab 	tabSize:1 			tabSizeVariable:false
				idSpline	type: #integer 			--ui:ui_largeur 				default:60.
				
				
				/* hitPoints type:#float ui:hits default:10
				cost type:#float ui:cost default:100
				sound type:#string */
			)
			 
			rollout params "Paramètres" 
			(

				spinner 'spn_etages_min' "" pos:[43,51] width:110 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
				label 'lbl_elem_largeur' "  min.:" pos:[4,50] width:34 height:15 align:#left
				
				
				spinner 'spn_etages_max' "" pos:[43,66] width:110 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
				label 'lbl14' "  max.:" pos:[4,65] width:37 height:15 align:#left
					
				spinner 'spn_etages_hauteur' "" pos:[43,81] width:110 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				label 'lbl18' "  Haut.:" pos:[4,80] width:38 height:15 align:#left
				spinner 'spn_rdc_hauteur' "" pos:[43,120] width:110 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
				label 'lbl19' "  Haut.:" pos:[4,119] width:38 height:15 align:#left
					
				dropdownList 'ddl_toiture' "" pos:[45,7] width:109 height:21 align:#left
				label 'lbl22' "Toiture:" pos:[5,11] width:38 height:15 align:#left
				dropdownList 'ddl_etages' "" pos:[45,31] width:109 height:21 align:#left
				label 'lbl23' "Etages:" pos:[5,35] width:38 height:15 align:#left
				dropdownList 'ddl_rdc' "" pos:[45,100] width:109 height:21 align:#left
				label 'lbl24' "RdC:" pos:[5,104] width:25 height:15 align:#left
			)
		) -- fin CA
		
		---- ajouter le CA
		CustAttributes.add 	tmpMod 	batimentCA_def	--#Unique BaseObject : false
		
	),
	fn ajouterModifier_ville 	_node	=(
		
		--- le modifier ----
		local tmpMod = emptymodifier ()
		tmpMod.name = "Urba | Ville"
		addModifier _node tmpMod
		
		
		--- Definition	CA ---------------------
		villeCA_def= attributes villeCA		(
			parameters main rollout:params			(
				/* hitPoints type:#float ui:hits default:10
				cost type:#float ui:cost default:100
				sound type:#string */
			)
			 
			rollout params "Paramètres"
			(
				/* spinner hits "Hit Points" type: #float
				spinner cost "Cost" type: #float
				dropdownlist sound_dd "Sound" items:# ("boom","sparkle","zap","fizzle")
				 
				on sound_dd selected i do sound = sound_dd.items [i] */
			)
		) -- fin CA
		
		
		---- ajouter le CA
		CustAttributes.add 	tmpMod 	villeCA_def	
	),
	
	
	
	
	
	
	
	
	-------- Divers ------------------------------------------------
	
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
	
	fn get_largeurNodeModele 	_nd	=(
		local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
		local largeur = BB[2].x -  BB[1].x 
		largeur
	),
	fn get_hauteurNodeModele 	_nd	=(
		local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
		local hauteur = BB[2].z -  BB[1].z 
		hauteur
	),
	
	fn get_paramsBatiment 	_nodeBat =(
		
		local porteurDeParams = str_params_batiment ()
		
		porteurDeParams.tracee 		= _nodeBat.modifiers[1].tracee[1].node
		porteurDeParams.idSpline		= _nodeBat.modifiers[1].idSpline
		
		porteurDeParams
	),
	
	fn get_surfSplineBB 	tracee	idSpline	= (
		
		
		local result 	= 0
		
		local minX 	= 100000000000000000000.
		local maxX = -100000000000000000000.
		local minY 	= 100000000000000000000.
		local maxY = -100000000000000000000.
		
		for id_knot_tracee = 1 to (numKnots tracee 	idSpline)   do	(
			knt = getKnotPoint tracee 	idSpline 	id_knot_tracee
			if knt.x < minX 	do minX 	= knt.x
			if knt.x > maxX do maxX 	= knt.x
			if knt.y < minY 	do minY 	= knt.y
			if knt.y > maxY do maxY 	= knt.y
		)
		
		result = ( maxX - minX ) * ( maxY - minY )	/	10000
		
		result
	),
	
	fn get_surfBB 	_nodeBat	= (
		
		local param 		= get_paramsBatiment	_nodeBat		
		local tracee 		= param.tracee
		local idSpline		= param.idSpline
		get_surfSplineBB	tracee	idSpline

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
		
		debug "pointLePlusHautsurY"	var:result_id
		result_id
	),

	fn estPolygone_sensPositif 	shp	idSpline =(
		
		local result 			= true
		local id_pointHaut 	= pointLePlusHautsurY  	shp	idSpline 
		
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
	
	fn preparerShape 	_tracee	=(
		
		local subSplineOuvertes =#()
		
		--- on ne garde que les shape fermé et on tounre tout ds le mm sens-----
		for idSpline = 1 to (numSplines _tracee) do
			if isClosed  _tracee	idSpline	then	(				
				--- on fait tourner les spline dans le meme sens ----
				if not estPolygone_sensPositif 	_tracee 	idSpline do
					reverse		_tracee	idSpline				
			) else (
				insertItem  idSpline	subSplineOuvertes 	1
			)
		
		---- on supprimer les spline ouvertes --
		for id in subSplineOuvertes do
			deleteSpline _tracee	id
		
		---- on ajoute le custom attribut au tracee--
		ajouterModifier_ville	_tracee
		
	),
	
	
	
	
	nomModelTemp,
	
	fn preparer_modelFacade 	_node	_elementFacade	=  (
		
		nomModelTemp = ""
		
		---- fenetre pour le nom du model ----------
		rollout roll_getNomModele "" width:269 height:61
		(
			editText 'edt_nom' "" pos:[94,10] width:159 height:16 align:#left
			button 'btn_annuler' "Annuler" pos:[157,35] width:49 height:16 align:#left
			
			
			button 'btn_valider' "Valider" pos:[205,35] width:49 height:16 align:#left
			label 'lbl44' "Nom du modèle:" pos:[14,11] width:80 height:18 align:#left
			
			fn actualiser =(
				btn_valider.enabled = not edt_nom.text == "" 
			)
			
			on roll_getNomModele 	close 	do ()
			on roll_getNomModele 	open 		do (
				actualiser ()
				setFocus edt_nom
			)
			on edt_nom 			changed _txt 	do actualiser ()
			
			on edt_nom 			entered _txt 	do (
				nomModelTemp = edt_nom.text 
				destroyDialog roll_getNomModele
			)
			
			on btn_valider pressed do	(
				nomModelTemp = edt_nom.text 
				destroyDialog roll_getNomModele
			)
			on btn_annuler pressed do destroyDialog roll_getNomModele
			
		)
		
		createDialog	roll_getNomModele		 modal:true	 	escapeEnable:false
		
		
		
		
		if nomModelTemp != "" do (		
			
			--- preparation du model -------
			local nvModel_node = copy _node 
			convertToPoly 	nvModel_node
			local  BB = nodeGetBoundingBox 	nvModel_node	(matrix3 1)
			nvModel_node.pivot = BB[1]
			nvModel_node.rotation = quat 0 0 0 1
			nvModel_node.pos  = [0,0,0]
			
			--- sauvegarde du fichier MAX ------
			
			local nomFichier =	GetDir  #userScripts	+	"\cp-Urba\lib\facades\\" + nomModelTemp + ".max"
			saveNodes 		nvModel_node	 nomFichier	quiet:true
			delete nvModel_node
			
			
			---- creation du preset Model -----
			local nvModele 		= m_urba.facades.modeles.creer_preset ()
			nvModele.nom 		= nomModelTemp
			nvModele.fichier 		= nomFichier
			
			m_urba.facades.modeles.sauvegarder nvModele
			
			---- maj de l'element de facade -----
			_elementFacade.model = 	nvModele.idUnique
			m_urba.facades.elementsDeFacade.sauvegarder 	_elementFacade
			
			nvModel
			
		)
		
		
	),
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	-------- Modelisation Fondamentale-------------------------
	fn creerPolyVide =(
		nvNode = convertToPoly (mesh ())
		nvNode.EditablePoly.SetSelection #Face #{1..25}
		nvNode.EditablePoly.delete #Face
		
		nvNode
	),
	
	fn creerFace  _object		_listeDesPoints  =(
		
		local verts = _object.verts.count
		
		-- les vertex --
		for pt in  _listeDesPoints do 
			polyop.createVert _object	pt
		
		
		-- les edges --
		for i = 1 to _listeDesPoints.count - 1 do 
			polyop.createEdge _object (verts+i) (verts+i+1)
		polyop.createEdge _object (verts+_listeDesPoints.count) (verts+1)
		
		-- la face --
		local listeVertexPrFace = #()
		for i = 1 to _listeDesPoints.count  do 
			append listeVertexPrFace ( verts+i )
		polyop.createPolygon _object  listeVertexPrFace
		
		_object
	),
	
	fn creerFaceVerticale 	_object	pt1 	pt2 	z 	hauteur	=(
		
		local verts = _object.verts.count
-- 		lo
		polyop.createVert _object	[pt2.x, pt2.y, z]	
		polyop.createVert _object	[pt1.x, pt1.y, z]
		polyop.createVert _object	[pt1.x, pt1.y, z + hauteur]
		polyop.createVert _object	[pt2.x, pt2.y, z + hauteur]
		
		polyop.createEdge _object (verts+1) (verts+2)
		polyop.createEdge _object (verts+2) (verts+3)
		polyop.createEdge _object (verts+3) (verts+4)
		polyop.createEdge _object (verts+4) (verts+1)
		
		polyop.createPolygon _object  #((verts+4),(verts+3),(verts+2),(verts+1))
		
		_object
		
	),
	
	fn creerFacesContour	 _nodeBat	 		altitude 		hauteur =(
		
		local param 		= get_paramsBatiment	_nodeBat		
		local tracee 		= param.tracee
		local idSpline		= param.idSpline
		
		for id_pt = 1 to ( numKnots 	tracee 	idSpline )  - 1 do	 (
			knt_1 = getKnotPoint 	tracee 	idSpline 	id_pt
			knt_2 = getKnotPoint 	tracee 	idSpline 	( id_pt + 1 )
			creerFaceVerticale 	_nodeBat	knt_1		knt_2 	altitude 	hauteur
		)
		
		knt_1 = getKnotPoint 	tracee 	idSpline 	(numKnots 	tracee 	idSpline)
		knt_2 = getKnotPoint 	tracee 	idSpline 	1
		creerFaceVerticale 	_nodeBat		knt_1		knt_2 	altitude 	hauteur
		
	),
	
	fn choisir_styleBatiment		_tracee 	_idSpline		_styleVille =(
		
		local surfaceBat 			= get_surfSplineBB		_tracee 	_idSpline
		local id_stylesPossible	=	#()
		local id_styleBatChoisi
		
-- 		debug "surfaceBat" var:surfaceBat
		
		for i = 1 to _styleVille.batiments.count do 
			if _styleVille.surfaces_min[i] <= surfaceBat	and _styleVille.surfaces_max[i] >= surfaceBat	do
				append id_stylesPossible	i
			
-- 		debug "id_stylesPossible" var:id_stylesPossible
		
		
		-- si plusieurs styles sont possibles --
		if id_stylesPossible.count > 1 then (	
			
			local probaTotal = 0
			for id_style in id_stylesPossible do
				probaTotal += 	_styleVille.probabilites[id_style]
			
-- 			debug "probaTotal" var:probaTotal
			local randomProba = random	0.	probaTotal
-- 			debug "randomProba" var:randomProba
			
			local probaMinTmp 	= 0
			local probaMaxTmp 	= 0
			
			for id_style in id_stylesPossible do (
				probaMaxTmp = probaMinTmp + _styleVille.probabilites[id_style]
				if randomProba >= probaMinTmp and randomProba <= probaMaxTmp do (
					id_styleBatChoisi = _styleVille.batiments[ id_style ]
				)
				probaMinTmp = probaMaxTmp
			)
			
			
		-- si un seul style est possible --
		) else if id_stylesPossible.count == 1 then (
			
			id_styleBatChoisi = _styleVille.batiments[ id_stylesPossible[1] ]
			
		)
		
		
		
		m_urba.batiments.presets.get_parIdUnique 	id_styleBatChoisi
		
		
	),
	
	
	
	listeDesPresetsModels	= #(),
	listeDesNodesModels	= #(),
	
	
	fn supprimer_modelesImportes =(
		for nd in  listeDesNodesModels do
			delete nd
		listeDesPresetsModels	= #()
		listeDesNodesModels	= #()
	),
	
	fn trouver_nodeModel	_model 	=(
		if listeDesNodesModels.count >0 then (
			debug "trouver_nodeModel"
			debug "_model" var:_model
			local id = findItem 	listeDesPresetsModels		_model
			debug "id" var:id
	-- 		debug "listeDesNodesModels" var:listeDesNodesModels
	-- 		debug "listeDesNodesModels[id]" var:listeDesNodesModels[id]
			listeDesNodesModels[id]
		) else undefined
	),
	
	
	fn collecter_modeles 	_presetVille	=(
		debug "collecter_modeles"
		
		--- collect des presets des models ----
		listeDesPresetsModels	= #()
		
		debug  "_presetVille.batiments" var:_presetVille.batiments
		
		for bat_idU in _presetVille.batiments do (
			local bat = m_urba.batiments.presets.get_parIdUnique		bat_idU
			
			debug  "bat" var:bat
			
			if bat.rdc_facade != "" do (
				
				
				local facadeTmpRdC 		= m_urba.facades.presets.get_parIdUnique		bat.rdc_facade
				local facadeTmpEtages		= m_urba.facades.presets.get_parIdUnique		bat.etages_facade
				local listeDeElements		= facadeTmpRdC.elements + facadeTmpEtages.elements
				debug  "listeDeElements" var:listeDeElements
				
				for elem_idU in listeDeElements do (
					local elem = m_urba.facades.elementsDeFacade.get_parIdUnique		elem_idU
					
				debug  "elem" var:elem
					if elem.type == 3 do (
						local modelTmp = m_urba.facades.modeles.get_parIdUnique		elem.model
						appendIfUnique listeDesPresetsModels	modelTmp
						debug "modelTmp" var:modelTmp
						
					)
				)
			)
		)
		
		debug "listeDesPresetsModels" var:listeDesPresetsModels
		
		-- merger les modeles ---
		listeDesNodesModels 				= #()
		for presetModel in listeDesPresetsModels do (
			
			local selectBack = selection
			
			mergeMAXFile 	presetModel.fichier	#select 	#noRedraw	quiet:true
			local modelImport = selection[1]
			
			append listeDesNodesModels 	modelImport
			
			select selectBack
		)
		debug "listeDesNodesModels" var:listeDesNodesModels
		
	),
	
	
	
	-------- Generation des facades ------------------------------------------------------
	fn creer_facade		_nodeBat	_knt_1		_knt_2 	_altitude 	_hauteur	_styleFacade	=(
		
		---- ANALYSE de la SEQUENCE d'élements de facades ------
		local largeurTotal 			= distance		_knt_1	_knt_2
		local nbrElemExtensibles 	= 0
		local largeurFixMin 			= 0
		local largeurExtensible 		= 0
		
		for idElem in _styleFacade.elements do (
			local presetElement			= m_urba.facades.elementsDeFacade.get_parIdUnique idElem
			case presetElement.type of (
				1: (	----	extensible ----
						nbrElemExtensibles += 1
				)
				2: (	----	largeur fixe ----
						largeurFixMin += presetElement.largeur
				)
				3: (	----	model ----
					local presetModel	= m_urba.facades.modeles.get_parIdUnique 		presetElement.model
					local ndModel 		= trouver_nodeModel	presetModel
					largeurFixMin +=	get_largeurNodeModele		ndModel
					
				)
				4: (	----	groupe ouverture ----
						
				)
				5: (	----	groupe fermeture ----
						
				)
			)
		)
		
		largeurExtensible = ( largeurTotal - largeurFixMin )	/	nbrElemExtensibles
		
		
		
		
		---- CREATION des GEOMETRIES ----------------------
		if largeurTotal > largeurFixMin	then (
			
			local pt1 		= 	_knt_1
			local pt2		
			local normDir	=	normalize (_knt_2 - _knt_1)
			local rot 		= get_angle_vecteur		normDir
			local nvxNodes = #()
			
			
			for idElem in _styleFacade.elements do (
				local presetElement			= m_urba.facades.elementsDeFacade.get_parIdUnique idElem
				case presetElement.type of (
					1: (	----	EXTENSIBLE ----
							pt2		=	pt1 + normDir * largeurExtensible
							creerFaceVerticale 	_nodeBat	pt1 	pt2 	_altitude 		_hauteur	
						)
					2: (	----	largeur FIXE ----
							pt2		=	pt1 + normDir * presetElement.largeur
							creerFaceVerticale 	_nodeBat	pt1 	pt2 	_altitude		_hauteur	
						)
					3: (	----	MODEL ----
							
							-- placer le model -----
							local presetModel	= m_urba.facades.modeles.get_parIdUnique 		presetElement.model
							local modelSource 	= trouver_nodeModel		presetModel
							
							local nv_modele 		= copy modelSource
							append nvxNodes 	nv_modele
							
							rotate nv_modele (angleaxis rot [0,0,1])
							nv_modele.pos 				= (pt1) 
							nv_modele.pos.z 				= _altitude
							
							-----	facette du dessus -----
							pt2 = pt1 + normDir * (get_largeurNodeModele		modelSource)
							
							local hauteurQuiReste = _hauteur	- ( get_hauteurNodeModele modelSource )
							debug "(pt1.z + ( get_hauteurNodeModele modelSource ) )" var:(pt1.z + ( get_hauteurNodeModele modelSource ) )
							debug "hauteurQuiReste" var:hauteurQuiReste
						
							creerFaceVerticale 	_nodeBat	pt1 	pt2 	(_altitude + ( get_hauteurNodeModele modelSource ) )		hauteurQuiReste	
							
						
						)
					) -- fin case
					
					pt1 = pt2
				)
			
			
			----	on attache tout les nodes créés	----
			for nd in  nvxNodes do 
				polyop.attach		_nodeBat	nd
			
			
		) else (
			debug  "		*********************************************************************"	
			creerFaceVerticale 	_nodeBat	_knt_1 	_knt_2 	_altitude 		_hauteur	
		)
		
		
		
		
-- 		---- on supprime les models importés ---
-- 		for model in listeDesModels do
-- 			delete model
	),
	
	
	
	
	-------- Generation des facades ------------------------------------------------------
	fn creer_etage		_nodeBat 	_altitude 	_hauteur	_styleFacade	=(
		
		local param 		= get_paramsBatiment	_nodeBat		
		local tracee 		= param.tracee
		local idSpline		= param.idSpline
		
		for id_pt = 1 to ( numKnots 	tracee 	idSpline )  - 1 do	 (
			knt_1 = getKnotPoint 	tracee 	idSpline 	id_pt
			knt_2 = getKnotPoint 	tracee 	idSpline 	( id_pt + 1 )
			creer_facade		_nodeBat	knt_1		knt_2 	_altitude 	_hauteur	_styleFacade
		)
		
		knt_1 = getKnotPoint 	tracee 	idSpline 	(numKnots 	tracee 	idSpline)
		knt_2 = getKnotPoint 	tracee 	idSpline 	1
		creer_facade		_nodeBat	knt_1		knt_2 	_altitude 	_hauteur	_styleFacade
		
	),

	
	
	
	
	-------- Generation des parties des batiments --------------------------------------
	fn creer_RdC 	_nodeBat	&z	_styleBat	=(
		debug "_styleBat" var:_styleBat
		
		/* --- plancher ---
		if ep_dalle  != 0 do (
			creerFacesContour	_nodeBat	z 	ep_dalle
			z += ep_dalle
		)  */
		
		--- un etage ---
		local styleFacade = m_urba.facades.presets.get_parIdUnique 		_styleBat.rdc_facade
		creer_etage	_nodeBat	z 	_styleBat.rdc_hauteur	styleFacade
		z += _styleBat.rdc_hauteur
		
	),
	fn creer_etages 	_nodeBat	&z	_styleBat	=(
		
		-- le nombre d'étages --
		local nbrEtages = random 		_styleBat.etages_min 		_styleBat.etages_max
		
		for i = 1 to nbrEtages do (
			
			--- plancher ---
			if ep_dalle  != 0 do (
				creerFacesContour	_nodeBat	z 	ep_dalle
				z += ep_dalle
			) 
			
			--- un etage ---
			local styleFacade = m_urba.facades.presets.get_parIdUnique 		_styleBat.etages_facade
			creer_etage	_nodeBat	z 	_styleBat.etages_hauteur		styleFacade
			z += _styleBat.etages_hauteur
			
		)
		
	),
	fn creer_toitTerrasse 	_nodeBat	&z	=(
		
		local listeDesPoints = #()
		for i = 1 to numKnots tracee 	id_subSpline do (
			pt = getKnotPoint tracee 	id_subSpline 	i 
			pt.z = z
			
			insertItem   pt listeDesPoints 1
-- 			append listeDesPoints  pt
		)
		creerFace listeDesPoints
	),
	fn creer_ssBassement  _nodeBat	&z	=(s
		creerFacesContour	 _nodeBat	z 	ep_ssBassement
		z += ep_ssBassement
	),
	
	
	
	
	
	
	
	
	fn creer_batiment  	_tracee		_idSpline	_styleVille	 =(
		
		debug "creer_batiment"
		
		--------- choisr style de batiment ---------
		local styleBat = choisir_styleBatiment 		_tracee		_idSpline			_styleVille
		
		--------- si on a un style, on construit le bat ----------------
		if styleBat != undefined then (
			
			debug "	----->	styleBat" var:styleBat.nom
			
			---- creation du node -----
			local nvBatiment 	= creerPolyVide ()		
			nvBatiment.name 	= uniqueName "Urba | Batiment - "
			nvBatiment.parent 	= _tracee
			
			---- on ajoute le modifer --
			ajouterModifier_batiment		nvBatiment
			nvBatiment.modifiers[1].tracee[1] 	= 	( nodeTransformMonitor node:_tracee 	forwardTransformChangeMsgs:false )
			nvBatiment.modifiers[1].idSpline		=	_idSpline
			
			--------- la position d'origine  en Z ---------
			local zCourant 	= 		_tracee.pos.z	- ep_ssBassement
			
			--- construction du ploy ------
			creer_ssBassement	nvBatiment		&zCourant
			creer_rdc 				nvBatiment		&zCourant		styleBat
			creer_etages			nvBatiment		&zCourant		styleBat
			
		) else (
		
			debug "	----->	Pas de style possible, batiment non construit" 
			
		)
		
		nvBatiment
		
	)
	
	
) -- fin struct -------------------------------






















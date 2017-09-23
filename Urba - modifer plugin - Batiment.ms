

		unregisterRedrawViewsCallback 	VPafficher_axePrincipal

plugin geometry urba_batiment
name:"Urba | Batiment"
classID:#(685325,452281)
category:"CP"
extends:Editable_poly replaceUI:true version:1
(
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Batiment Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	
	
	
	local traceeLogo = #([14.1994,37.717,0], [14.1994,-189.586,0], [287.927,-189.586,0], [287.927,139.601,0], [174.501,253.027,0], [174.501,479.879,0], [61.0754,479.879,0], [61.0754,366.453,0], [-52.3504,479.879,0], [-392.628,139.601,0], [-392.628,-189.586,0], [-118.9,-189.586,0], [-118.9,37.717,0])

	local ep_ssBassement = 	-100
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- Structures  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
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
			format "pt:%\n" pt
			)
			
			-- les edges --
			for i = 1 to _listeDesPoints.count - 1 do 
				polyop.createEdge delegate (verts+i) (verts+i+1)
			polyop.createEdge delegate (verts+_listeDesPoints.count) (verts+1)
			
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
			format "hauteur" var:hauteur
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
		fn edge_lePlusGrand		_spline 	_idSpline 	=(
			local 	longueurEdgeMax = 0
			local	resultEdgeId
			for i = 1 to ( numKnots _spline 	_idSpline) - 1 do (
				local pt 			= getKnotPoint _spline 	_idSpline 	i
				local pt_suivant	= getKnotPoint _spline 	_idSpline 	(i+1)
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultEdgeId = i
				)
			)
			resultEdgeId
		),
		fn mtrx_axePrincipal  			_spline 	_idSpline  	=(
			
			local edgeLePlusLong 	= get.edge_lePlusGrand	_spline 	_idSpline 
			local pts 					= #(	getKnotPoint _spline 	_idSpline 	edgeLePlusLong, 
													getKnotPoint _spline 	_idSpline 	( edgeLePlusLong + 1) )
			local axeVecteur 		= 	normalize (pts[2] - pts[1])
			local axeMtrx				=  /* inverse */  ( matrixFromNormal		axeVecteur )

			
			if axeMtrx.row1	==	[0,0,-1]  then (
				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx

			) else if axeMtrx.row1	==	[0,0,1] do (
				
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
			)
			
			axeMtrx		
		),
		fn BB_axePrincipal  		_spline 	_idSpline  	=(
			
			local mtrxAxePrincipal	=	get.mtrx_axePrincipal 	_spline	_idSpline
			
			local pt1 = ( getKnotPoint _spline 	_idSpline 	1 ) * inverse mtrxAxePrincipal
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to ( numKnots _spline 	_idSpline) do (
				local pt = ( getKnotPoint _spline 	_idSpline 	i ) * inverse mtrxAxePrincipal
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
			#([xMin, yMin, zMin]*  mtrxAxePrincipal, [xMax, yMax, zMax]*  mtrxAxePrincipal)
			
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
			
		)
		
	) ---- fin struct GET ------------------
	
	
	
	
	struct construire (
		
		fn ssBassement  	_tracee	&z	=(
			geo.creerFacesContour	 _tracee		z 	ep_ssBassement
			z += ep_ssBassement
		),
		
		fn creer_RdC 				_tracee	&z	_presetBat	=(
			
			
			--- un etage ---
			local styleFacade = m_urba.facades.presets.get_parIdUnique 		_presetBat.rdc_facade
			creer_etage	_nodeBat	z 	_presetBat.rdc_hauteur	styleFacade
			z += _presetBat.rdc_hauteur
			
		)
		
	) ---- fin struct construire ------------------
	

	
	
	
	
	
	
	
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- Fonctions  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	------ AFFICHAGE - ViewPort------------
	fn		VPafficher_axePrincipal		 =(
		
		
		gw.setTransform (matrix3 1)
		
		for o in objects where classof o ==urba_batiment  do (
			if o.afficheAxe do (
				local BB_axeP 	= o.BB_axePrincipal
				local mtrx_axeP	= o.mtrx_axePrincipal 
				translate mtrx_axeP BB_axeP[1]
				
				local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
				local largeur 		=	diag_axeP.x
				local longeur 		= 	diag_axeP.z
				
				
				---- dessin de l'Axe-----------------
				local ptAxe_1 = (  [largeur/2,0,0]  *  mtrx_axeP )
				local ptAxe_2 = (  [largeur/2,0,longeur + 0 ]  *  mtrx_axeP )
				
				gw.setColor	#line	blue
				gw.Polyline #( ptAxe_1, ptAxe_2 )	false
				
				
				---- dessin du BB-----------------
				local ptBB_1 = (  [0,0,0]  *  mtrx_axeP )
				local ptBB_2 = (  [0,0,longeur]  *  mtrx_axeP )
				local ptBB_3 = (  [largeur ,0,longeur]  *  mtrx_axeP )
				local ptBB_4 = (  [largeur ,0,0]  *  mtrx_axeP )
				
				gw.setColor	#line	yellow
				gw.Polyline #( ptBB_1, ptBB_2, ptBB_3, ptBB_4 )	true
				
			)
		)
		gw.enlargeUpdateRect #whole  
	

	)
	
	
	
	fn VPactiver_axeP =(
		
		unregisterRedrawViewsCallback 	VPafficher_axePrincipal
		registerRedrawViewsCallback 	VPafficher_axePrincipal 	
	)
	fn VPvider	=(
		unregisterRedrawViewsCallback 	VPafficher_axePrincipal
	)
		
	
	
	
	
	
	
	fn set_tracee	 	_nvTracee 	=(
		
		local subSplineOuvertes 		=#()
		local nvTraceeTMP 				= copy _nvTracee
		local id_premierTraceeFerme 	= 0
		
		
		
		
		--- on ne prend que la premiere spline fermée-----
		convertToSplineShape nvTraceeTMP
		local b_trouve = false
		for idSpline = 1 to (numSplines nvTraceeTMP) while not b_trouve	do
			if isClosed  nvTraceeTMP	idSpline	then	(
				id_premierTraceeFerme = idSpline
				b_trouve = true
			)
		
		---- si on a trouvé la spline --------------------
		if id_premierTraceeFerme != 0 do (
			
			--- on fait tourner les spline dans le meme sens ----
			if not get.est_sensPositif 	nvTraceeTMP 	id_premierTraceeFerme do
				reverse		nvTraceeTMP	id_premierTraceeFerme
			
			---- mise a jour de tracee -----------
			this.tracee = #()	
			for id_pt = 1 to ( numKnots 	nvTraceeTMP 	id_premierTraceeFerme ) do	 (
				ptSpline = ( getKnotPoint 	nvTraceeTMP 	id_premierTraceeFerme 	id_pt )
				append this.tracee 	ptSpline
			)
			
		
			--- Axe principal-------------------
			this.mtrx_axePrincipal	=		get.mtrx_axePrincipal	nvTraceeTMP 	id_premierTraceeFerme
			this.BB_axePrincipal		=		get.BB_axePrincipal		nvTraceeTMP 	id_premierTraceeFerme
			
			
			
			
		)
		
		
		
		
		
		
		--- suppression de tracée temp -------------
		delete nvTraceeTMP
		
	)
	
	fn init_surfaceDeBase 	= (
		
		---- creation de la surface de base -------
		geo.vider ()
		geo.creerFace  this.tracee
		
		----- calcul de la surface du tracee ------
		this.surface = get.surface ()
		this.roll_infos.actualiser ()
		
		
	)
	
	
	fn creerBatiment =(
		
		---- creation de la surface de base -------
		init_surfaceDeBase ()
		
		---- ssBassement ------
		local zCourant = 0
		construire.ssBassement 	this.tracee	&zCourant
		
		redrawviews ()
	)
	
	
	
	
	fn tourner_axeP	 =(
		
		local mtrxTmp = this.mtrx_axePrincipal
		
		rotateZ	mtrxTmp	90
		this.mtrx_axePrincipal = mtrxTmp
		
	)
	
	
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	tool create	(
		on mousePoint click do	(
			nodeTM.translation = worldPoint
			#stop
		)
	)
	
	
	
	
	
	
	
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- Parametres  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	parameters params_main rollout:roll_params			(
		
		tracee					type:#point3Tab 		tabSize:0 			tabSizeVariable:true
		
		
		mtrx_axePrincipal		type:#matrix3	
		BB_axePrincipal		type:#point3Tab		tabSize:2			tabSizeVariable:false
		
		
		/* 
		idSpline	type: #integer 			--ui:ui_largeur 				default:60.
		
		--- param pour preset batiment -----					
		style						type: #string		--- l'idUnique du preset du batiment -----
		
		etages					type: #integer 	ui:spn_etages
		etages_hauteur 		type: #float 		ui:spn_etages_hauteur					
		rdc_hauteur 			type: #float		ui:spn_rdc_hauteur			
		 */
		
	)	
	parameters params_infos rollout:roll_infos			(
		
		surface			type: #float 		default:0.	
		afficheAxe		type:#boolean		default:false	ui:ckb_afficheAxe
	)
	
	
	
	parameters params_rdc rollout:roll_rdc			(
		
		rdc_hauteur	type: #float 		default:250.	ui:spn_hauteur
		
	)
	
	parameters params_etages rollout:roll_etages			(
		
		etages_hauteur	type: #float 		default:250.	ui:spn_hauteur
		etages_nbre		type: #integer		default:1		ui:spn_nbres
		
	)
	
	
	
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	rollout roll_params "Paramètres" 
	(
		
		fn shape_filt 		obj = superclassof obj == shape
		
		button 'btn_vider' "Vider" pos:[140,17] width:30 height:16 align:#left
		pickbutton 'btn_pick_tracee' "Pick shape" pos:[5,2] width:165 height:16 filter:shape_filt align:#left
		
		button 'btn_construire' "Construire" pos:[5,17] width:55 height:16 align:#left
		
		fn actualiser =(
			
		)
		
		
		on roll_params open do
			actualiser ()
		on btn_vider pressed do
		(
					geo.vider()
					redrawviews ()
				)
		on btn_pick_tracee picked _nvTracee 	do
		(
					$.pos = [0,0,0]
					set_tracee	_nvTracee
					init_surfaceDeBase ()
					redrawviews ()
				)
		on btn_construire pressed do	creerBatiment ()
				
	)
	
	
	rollout roll_presets "Presets"
	(
		dropdownList 'ddl_style' "" pos:[51,1] width:111 height:21 align:#left
		label 'lbl_style' "Preset" pos:[5,5] width:38 height:15 align:#left
		
		fn actualiser =(
			
			--- liste des bats -----
			local listTmp =#()
			for bat in urba.batiments.presets.get () do
				append listTmp bat.nom
			ddl_style.items = listTmp
			
			local batTmp  = urba.batiments.presets.get_parIdUnique	style
			ddl_style.selection = urba.batiments.presets.trouver_ID	batTmp
		)
		
		on roll_presets open do
			actualiser ()
	)
	
	
	rollout roll_rdc "RdC" 
	(
		dropdownList 'ddl_facade' "" pos:[51,1] width:111 height:21 align:#left
		label 'lbl_facade' "Façade:" pos:[5,5] width:38 height:15 align:#left
		spinner 'spn_hauteur' "" pos:[50,22] width:111 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl_hateur' "Hauteur:" pos:[5,22] width:45 height:15 align:#left
	)
	
	
	rollout roll_etages "Etages" 
	(
		dropdownList 'ddl_facade' "" pos:[51,1] width:111 height:21 align:#left
		label 'lbl_facade' "Façade:" pos:[5,5] width:38 height:15 align:#left
		label 'lbl_nbre' "Nbre.:" pos:[5,21] width:38 height:15 align:#left
		
		spinner 'spn_nbres' "" pos:[50,22] width:111 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		
		spinner 'spn_hauteur' "" pos:[50,38] width:111 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl_hauteur' "Hauteur:" pos:[5,38] width:45 height:15 align:#left
	)
	
	
	rollout roll_Toiture "Toiture" 
	(
		dropdownList 'ddl_toiture' "" pos:[51,1] width:111 height:21 align:#left
		label 'lbl_facade' "Toiture:" pos:[5,5] width:38 height:15 align:#left
	)
	
	
	rollout roll_infos "Infos" width:162 height:113
	(
		label 'lbl16' "Surface:" pos:[4,2] width:43 height:14 align:#left
		label 'lbl_surface' "" pos:[52,2] width:103 height:16 align:#left --enabled:false
 --enabled:false
		checkbutton 'ckb_afficheAxe' "Axe principale" pos:[7,22] width:75 height:16 align:#left
		button 'btn_rotation' "+90" pos:[17,53] width:25 height:16 align:#left
 --enabled:false
		fn actualiser =(
			lbl_surface.text = ( surface / 10000 ) as string + " m²"
		)

		on roll_infos open do
			actualiser()
		on ckb_afficheAxe changed state do
		(
					case state of (
						true: 	VPactiver_axeP 	()
						false:		VPvider ()
					)
					
				)
		on btn_rotation pressed  do
	(
		tourner_axeP ()
		)
	)
	
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- evenements  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	on load do (
		format "load du plug: % \n" this
	)
	on clone _original do 
		format "clone du plug :%\n" _original
		
	
	
	on create do (
		format "creation du plug\n"
		
		--- le dessin du logo --------
		tracee = traceeLogo
		
		init_surfaceDeBase ()
	)
	
) --- fin du plug ----------


/*
-- delete objects


test = urba_batiment_poly ()
select test

clearlistener ()



*/







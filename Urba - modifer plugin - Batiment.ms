/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale
	
##########################################################################################################################
	
	Plugin Batiment
	
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


unregisterRedrawViewsCallback 	fn_VP_afficher_axePrincipal

---------------presse papier ---------
global urba_clipboard_batiment = ""
	
plugin geometry 	urba_batiment
name:"Batiment"
classID:#(685325,452281)
category:"CP | Urba"
extends:Editable_poly replaceUI:true version:0
(
	
	
	
	--------------- imports  ----------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp - GLOBAL\Enregistreur De Node.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - presets.ms"
	
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Batiment Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	---- les rollouts ------------------
	local roll_global, roll_niveaux,  roll_presets,   roll_toiture, roll_infos , roll_facades 
	
	---- le model dessiné d'un batiment vide ------------------
	local traceLogo = #([14.1994,37.717,0], [14.1994,-189.586,0], [287.927,-189.586,0], [287.927,139.601,0], [174.501,253.027,0], [174.501,479.879,0], [61.0754,479.879,0], [61.0754,366.453,0], [-52.3504,479.879,0], [-392.628,139.601,0], [-392.628,-189.586,0], [-118.9,-189.586,0], [-118.9,37.717,0])

	local params_aEnregistrer = #(	#niveaux_hauteur, #niveaux_hauteur, #niveaux_nbre, 
												#toit_pente, #toit_type, #toit_hauteur ,
												#trace_optimiser, #trace_souder, #trace_ortho, #seuil_optimiser, #seuil_souder, #seuil_ortho )
	
	---- constantes------------------
	local ep_ssBassement 	= 	100
	local ep_dalle 			= 20
	local ep_mur	 			= 20
	local ep_couvertine	 	= 5
	
	
	local murs_types = #("Gouttereaux", "Pignons", "Gouttereaux + Pignons")
	
	local presets = str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\batiments\\"		)	\
														fichier_categorie:			"Urba - Bâtiment"	\
														fichier_extension:			"btm"	\
														params_aEnregistrer:	params_aEnregistrer

	local nodeScanner = str_enregistreurDeNode ()
	
	--------------- Structures  ----------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures.ms"
	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	--------------- Fonctions  ----------------------------------------------------------------------------------------------------------------------	
	-------------------------------------------------------------------------------------------------------------------------------------------------
	
	------ AFFICHAGE - ViewPort------------
	fn	fn_VP_afficher_axePrincipal		 =(
		
		gw.setTransform (matrix3 1)
		
		
		for o in selection where classof o == urba_batiment  do (
			
			local largeurFleche = 100
			local BB_axeP 	= o.BB_axePrincipal
			local mtrx_axeP	= o.mtrx_axePrincipal 
			local mtrx_axeP2	= o.mtrx_axePrincipal 
				
-- format "fn_VP_afficher_axePrincipal:%\n"  BB_axeP
			translate mtrx_axeP 	BB_axeP[1]
-- 			translate mtrx_axeP 	o.pos
-- 			mtrx_axeP 	= mtrx_axeP * o.transform
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP ) - (BB_axeP[1]  * inverse mtrx_axeP  )
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
-- 				
-- format "largeur:%		longeur:%		mtrx_axeP:%\n" largeur longeur  mtrx_axeP

				
-- 			gw.Marker 	( BB_axeP[1] * o.transform )	#Circle  	color:yellow
-- 			gw.Marker 	 ( (  [largeur,0,0]    *  mtrx_axeP  * o.transform) 	)	#Circle  	color:blue
-- 			gw.Marker 	 ( BB_axeP[2] * o.transform )	#Circle  	color:yellow
-- 			gw.Marker 	 ( [BB_axeP[2].x, BB_axeP[1].y, BB_axeP[1].z] * o.transform )	#Circle  	color:blue
				
			------ l'AXE----------------
			if o.affiche_axe do (
				---- dessin de l'Axe-----------------
				local ptAxe_1 =  [largeur/2,0,0]  *   mtrx_axeP   * o.transform
				local ptAxe_2 =  [largeur/2,0,longeur - largeurFleche ]  *     mtrx_axeP    * o.transform
-- 				local ptAxe_1 =  [0,0,0]  *   mtrx_axeP   * o.transform
-- 				local ptAxe_2 =  [0,0,0 ]  *     mtrx_axeP    * o.transform
				
-- format "ptAxe_1:%		ptAxe_2:%\n" ptAxe_1 ptAxe_2  

				gw.setColor	#line	yellow
				gw.Polyline #( ptAxe_1, ptAxe_2 )	false
				
				---- dessin de la fleche de l'axe -----------------
				local ptFleche_1 = (  [largeur/2,0,longeur + 0 ]  ) *  mtrx_axeP    * o.transform
				local ptFleche_2 = (  [largeur/2,0,longeur + 0 ]   + [largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				local ptFleche_3 = (  [largeur/2,0,longeur + 0 ]   + [-largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				
				gw.Polyline #( ptFleche_1, ptFleche_2, ptFleche_3 )	true
			)
			
		
			for i = 1 to o.trace.count do (
				local j = i + 1
				if j > o.trace.count do j = 1
				local pt = o.trace[i] *  o.transform 
				local pt_suivant = o.trace[j] *  o.transform 
				
			---- les pignons et gouttereaux -----
				local col = red
				local estPignon = findItem o.idtrace_pignons i != 0 
				if estPignon then (
					if o.affiche_pignons do (
						gw.setColor	#line	blue
						gw.polyline #( pt, pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)else (
					if o.affiche_gouttereaux do (
						gw.setColor	#line	red
						gw.polyline #( pt,pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)
			---- les points du trace -----
				if o.affiche_trace do (
					gw.text 		(pt + [0,0,10]) 	(i as string)  	color:yellow
-- 					gw.Marker 	pt 	#hollowBox 	color:yellow
				)
			
				
				
			)
			
			
						

			
		)
		gw.enlargeUpdateRect #whole  


	)
	fn VP_toggle	=(
		unregisterRedrawViewsCallback 	fn_VP_afficher_axePrincipal
		if 	 this.affiche_axe or  this.affiche_trace or  this.affiche_pignons or  this.affiche_gouttereaux   do
			registerRedrawViewsCallback 		fn_VP_afficher_axePrincipal 	
	)

	
	fn actualiser_rollouts =(
-- 		roll_trace.actualiser ()
		roll_global.actualiser ()
-- 		roll_presets.actualiser ()
-- 		roll_rdc.actualiser ()
-- 		roll_etages.actualiser ()
		roll_facades.actualiser ()
		roll_toiture.actualiser ()
		roll_infos.actualiser ()
	)
	fn actualiser_cacherGeo =(
		if this.cache_geometrie then (
			local faces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.setHiddenFaces 	delegate 	faces
		) else
			polyop.unHideAllFaces 	delegate
	)
	
	
	
	
	

	fn maj_pignonsEtGouttereaux =(
		
		this.idtrace_pignons 		=#()
		this.idtrace_gouttereaux 	=#()
		
		for i =1 to this.trace.count do (
			local j = i+1
			if j > this.trace.count do j = 1
			
			local orientation = get.orientation_axeP	this	(this.trace[j]-this.trace[i])
			case orientation of (
				#perpendiculaire: append 	this.idtrace_pignons			i
				#parallele: 			append 	this.idtrace_gouttereaux	i
			)
			
		)
	)
	fn init_geometrie 	= (
		
		---- creation de la surface de base -------
		geo.vider ()
		geo.creerFace  this.trace
		
		----- calcul de la surface du trace ------
		this.surface = get.surface ()
		this.roll_infos.actualiser ()
		
		
	)
	fn creerBatiment =(
		
		---- creation de la surface de base -------
		init_geometrie ()
		
		local zCourant = -( ep_ssBassement + ep_dalle )
		
		construire.ssBassement 	this	&zCourant
		construire.RdC 				this	&zCourant
		construire.etages				this	&zCourant
		construire.toit					this	&zCourant
		
		redrawviews ()
	)
	
	
		
	fn optimiser_trace =(
-- 		local traceTmp =  this.trace_original as array
		
		this.trace = this.trace_original as array
		maj_pignonsEtGouttereaux  ()
		
		---- orthonormer -----------
		if this.trace_ortho do
			optimiser.ortho		this
		
		---- souder -----------
		if this.trace_souder do
			optimiser.souder		this
		
		---- optimiser -----------
		if this.trace_optimiser do
			 optimiser.optimiser		this
		
		maj_pignonsEtGouttereaux ()
		
		creerBatiment ()
	)
	
	fn tourner_axeP	  =(
		
		local mtrxTmp 			= get.mtrx_axePrincipal	this.trace_original 	
		rotateZ	mtrxTmp			this.rotation_axeP
		this.mtrx_axePrincipal 	= mtrxTmp		
		this.BB_axePrincipal		=		get.BB_axePrincipal		this.trace 		this.mtrx_axePrincipal
		maj_pignonsEtGouttereaux ()
		
		--- recreation du batiment -----
		creerBatiment ()
	)
	fn set_trace	 	_nvtrace  _thisNode	=(
		
		_thisNode.transform = (matrix3 1)
		ResetPivot 			_thisNode
		
		this.trace_original 				=#()
		this.trace							=#()
		local trace_absolu				=#()
		local subSplineOuvertes 		=#()
		local nvtraceTMP 				= copy _nvtrace
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
			
			--- on fait tourner les spline dans le meme sens ----
			if not get.est_sensPositif 	nvtraceTMP 	id_premiertraceFerme do
				reverse		nvtraceTMP	id_premiertraceFerme
			
			---- mise a jour de trace -----------
			for id_pt = 1 to ( numKnots 	nvtraceTMP 	id_premiertraceFerme ) do	 (
				ptSpline = ( getKnotPoint 	nvtraceTMP 	id_premiertraceFerme 	id_pt ) 
-- 				ptSpline.z = 0
				debug "ptSpline" var:ptSpline
				append trace_absolu 	ptSpline
			)
			
			---- centrer le pivot ----
			local pt_sommeDesPts = 0
			for pt in trace_absolu do
				pt_sommeDesPts += pt
			local pt_centre = pt_sommeDesPts / trace_absolu.count
			_thisNode.pos = pt_centre
			
			---- actualiser les tracés ----
			for pt in trace_absolu do (
				append this.trace_original	( pt * inverse _thisNode.transform )
				append this.trace 			( pt * inverse _thisNode.transform )
			)
			
			--- Axe principal-------------------coordsys
			this.a_un_trace 			= true
			this.mtrx_axePrincipal	=		get.mtrx_axePrincipal	this.trace 	
			this.BB_axePrincipal		=		get.BB_axePrincipal		this.trace 		this.mtrx_axePrincipal
			
			maj_pignonsEtGouttereaux ()
			
		)
		
		--- suppression de tracée temp -------------
		delete nvtraceTMP
		
		optimiser_trace ()
		actualiser_rollouts ()
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
	
	--------------- Parametres  et rollouts ----------------------------------------------------------------------------------------------------------------------	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollouts.ms"
	
	--------------- evenements  ----------------------------------------------------------------------------------------------------------------------	
	on load 						do 	(
		format "load du plug: % \n" this
		VP_toggle ()
	)
	on clone 	_original 	do 	format "clone du plug :%\n" _original
	on create do (
		format "creation du plug: Urba | Batiment\n"		
		--- le dessin du logo --------
		trace = traceLogo
		init_geometrie ()
	)
	
	on update do	(
		format "update du plug: Urba | Batiment\n"	
		if version == 0 then 		format "maj de le version 0->1\n"	
	)
	
) --- fin du plug ---




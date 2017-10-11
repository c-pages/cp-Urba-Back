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


-- unregisterRedrawViewsCallback 	fn_VP_afficher_axePrincipal

(
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"
)	






---------------presse papier ---------
global urba_clipboard_batiment = ""


(
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
)

	
plugin geometry 	urba_batiment
name:"Batiment"
classID:#(685325,452281)
category:"CP | Urba"
extends:Editable_poly replaceUI:true version:0
(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Batiment Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)
	
	--------------- IMPORTS  ----------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp - GLOBAL\Enregistreur De Node.ms"	

	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - presets.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - tracé.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Construire.ms"
	
	
	--------------- PRé-DéCLARATIONS  ----------------------------------------------------------------------------------------------------------------------
	----  rollouts ------------------
	local roll_global, roll_niveaux,  roll_presets,   roll_toiture, roll_infos , roll_facades 
	
	----  structures ------------------
-- 	local geo,  trace,  construire
	
	--------------- MEMBRES  ----------------------------------------------------------------------------------------------------------------------
	---- le model dessiné d'un batiment vide ------------------
	local traceLogo = #([14.1994,37.717,0], [14.1994,-189.586,0], [287.927,-189.586,0], [287.927,139.601,0], [174.501,253.027,0], [174.501,479.879,0], [61.0754,479.879,0], [61.0754,366.453,0], [-52.3504,479.879,0], [-392.628,139.601,0], [-392.628,-189.586,0], [-118.9,-189.586,0], [-118.9,37.717,0])

	local params_aEnregistrer = 	#(		/*  ----	Global  	----  */		#niveaux_hauteur, #niveaux_nbre, #axeP_orientation,
													/*  ----	Toiture 	----  */		#toit_pente, #toit_type, #toit_hauteur ,
													/*  ----	Tracé  	----  */		#trace_optimiser, #trace_souder, #trace_ortho, #seuil_optimiser, #seuil_souder, #seuil_ortho ,
													/*  ----	 Facades  	----  */		#facades_composants , #facades_items, #facades_modeles, #facades_parametriques
											)
	
	
	
	local murs_types = #("Gouttereaux", "Pignons", "Gouttereaux + Pignons")
	
	--------------- import des STRUCTURES  ----------------------------------------------------------------------------------------------------------------------
	
	
	local geo 			= 	str_geo 			()
	local construire	=	str_construire	geo_ptr:geo
	local facades		=	str_facades	constr_ptr:construire
	local trace			=	str_trace 		geo_ptr:geo
	
	local presets 	= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\batiments\\"		)	\
																fichier_categorie:		"Urba - Bâtiment"	\
																fichier_extension:		"btm"	\
																params_aEnregistrer:	params_aEnregistrer

	local nodeScanner = str_enregistreurDeNode ()
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------	
	------ Affichage - ViewPort------------
	fn	fn_VP_afficher_axePrincipal		 =(
		
		gw.setTransform (matrix3 1)
		
		
		for o in selection where classof o == urba_batiment  do (
			
			local largeurFleche = 100
			local BB_axeP 	= o.axeP_BB
			local mtrx_axeP	= o.axeP_mtrx 
			local mtrx_axeP2	= o.axeP_mtrx 
				
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
			
		
			for i = 1 to o.trace_courant.count do (
				local j = i + 1
				if j > o.trace_courant.count do j = 1
				local pt = o.trace_courant[i] *  o.transform 
				local pt_suivant = o.trace_courant[j] *  o.transform 
				
				---- les pignons et gouttereaux -----
				local col = red
				local estPignon = o.trace.est_pignon i o
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
				---- les points du trace_courant -----
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
	fn actualiser_cacherGeo =(
		if this.cache_geometrie then (
			local faces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.setHiddenFaces 	delegate 	faces
		) else
			polyop.unHideAllFaces 	delegate
	)
	------ Rollouts------------
	fn actualiser_rollouts =(
-- 		debug "actualiser_rollouts 0"
		
		roll_global.actualiser 	()		
-- 		debug "actualiser_rollouts 1"
		
		roll_facades.actualiser 	()
-- 		debug "actualiser_rollouts 2"
		
		roll_toiture.actualiser	()
-- 		debug "actualiser_rollouts 3"
		
		roll_infos.actualiser 		()
-- 		debug "actualiser_rollouts : OK"
		
	)
	
	
	
	fn assigner_trace 	_nvtrace	_node	= (
		
		trace.definir		_nvtrace	_node
		trace.actualiser	this
		construire.batiment this
		
	)
	
	
	
	
	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------	
	tool create (	
		on mousePoint click do	(	
			nodeTM.translation = worldPoint
			#stop	
		)
	)
	
	--------------- import des PARAMETRES  et rollouts ----------------------------------------------------------------------------------------------------------------------	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollouts.ms"
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------	
	on load 						do 	(
		debug "load du plugin" 
		VP_toggle ()
-- 		facades.params_toStructs		this
	)
	on clone 	_original 	do (
		debug "clone du plugin" 
		facades.params_toStructs		this
-- 		initialiser ()
	)
	on create do (
		debug "creation du plugin"		
		--- le dessin du logo --------
		trace_courant = traceLogo
		geo.creerFace trace_courant		this
	)
	
	on update do	(
		debug "update du plugin"	
-- 		facades.params_toStructs		this
-- 		if version == 0 then 		format "maj de le version 0->1\n"	
	)
	
) --- fin du plug ---

/* 


-- debug_mode =false
debug_mode =true

for obj in objects do if superclassof obj == GeometryClass and obj != $'triple002'  and obj != $'Porte002'  and obj != $'Porte003' do delete obj
bat1 = urba_batiment ()
clearlistener ()
for obj in helpers do delete obj

bat1.assigner_trace 	$Shape002	bat1
-- bat1.assigner_trace 	$Shape009	bat1

-- bat1.facades.creer_facade 	bat1

select bat1

bat1.pos = [0,0,0]









ray <pos_point3> <dir_point3>
intersectRay 










$.construire.batiment $




$.facades.modeles_total
$.facades_modeles[1]
$.facades.composants_total


$.facades.get_composants $

$.facades.composants_total


$.facades_parametriques[1]



 */





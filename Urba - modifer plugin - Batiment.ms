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





try unregisterRedrawViewsCallback 		$.fn_VP_afficher_axePrincipal 	
catch ()



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
													/*  ----	Tracé  	----  */		#trace_optimiser, #trace_souder, #trace_ortho, #seuil_optimiser, #seuil_souder, #seuil_ortho , #trace_aligner, #trace_decouper, #seuil_aligner ,
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
				
			translate mtrx_axeP 	BB_axeP[1]
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP ) - (BB_axeP[1]  * inverse mtrx_axeP  )
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
-- 				
			------ l'AXE----------------
			if o.affiche_axe do (
				---- dessin de l'Axe-----------------
				local ptAxe_1 =  [largeur/2,0,0]  *   mtrx_axeP   * o.transform
				local ptAxe_2 =  [largeur/2,0,longeur - largeurFleche ]  *     mtrx_axeP    * o.transform

				gw.setColor	#line	yellow
				gw.Polyline #( ptAxe_1, ptAxe_2 )	false
				
				---- dessin de la fleche de l'axe -----------------
				local ptFleche_1 = (  [largeur/2,0,longeur + 0 ]  ) *  mtrx_axeP    * o.transform
				local ptFleche_2 = (  [largeur/2,0,longeur + 0 ]   + [largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				local ptFleche_3 = (  [largeur/2,0,longeur + 0 ]   + [-largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				
				gw.Polyline #( ptFleche_1, ptFleche_2, ptFleche_3 )	true
			)
			
			
			
			--- sous tracés -------------
			if o.affiche_ssTraces do (
				local sousTraces = o.sousTraces
				local barycentre = [0,0,0]
				for i = 1 to sousTraces.count do (
-- 					format "o.sousTraces.count :%\n"	o.sousTraces.count
					local sousTrace = o.trace.datasMgr.get_string_to_array	 	sousTraces[i]
					
					for id_pt = 1 to sousTrace.count do (
						local id_ptSuiv = id_pt + 1
						if id_ptSuiv > sousTrace.count do id_ptSuiv = 1
						local id_ssTrace 				= sousTrace[ id_pt ]
						local id_ssTrace_suivant 	= sousTrace[ id_ptSuiv ]
						
						local pt 			= o.trace_courant[ id_ssTrace  ] 		*  o.transform 
						local pt_suivant 	= o.trace_courant[ id_ssTrace_suivant  ]  	*  o.transform 
						gw.setColor	#line	gray
						gw.polyline #( pt, pt_suivant )	false
						barycentre += pt
					)
						
					local pt_0 = o.trace_courant[ sousTrace[ 1 ] ]
					local pt_1 = o.trace_courant[ sousTrace[ 2 ] ]
					local pt_2 = o.trace_courant[ sousTrace[ 4 ] ]
					
					barycentre /= sousTraces.count
					
					local surf = ( distance pt_1 pt_0 ) * ( distance pt_2 pt_0 ) / 10000
					gw.text 		barycentre	( surf as string + " m²" )  	color:gray
					
					
					
				)
			)
				
				
	-- 			gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
			
			
			
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
					gw.text 		(pt + [0,0,10]) 	(i as string /* + ":" + ( o.trace_courant[i] * inverse o.axeP_mtrx ) as string */ )  	color:yellow
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
-- 		trace.params_toStructs 	this	 
-- 		facades.params_toStructs		this
	)
	on clone 	_original 	do (
		debug "clone du plugin" 
		facades.params_toStructs		this
-- 		trace.params_toStructs 	this	
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

bat1.assigner_trace 	$Shape032	bat1
-- bat1.assigner_trace 	$Shape009	bat1

-- bat1.facades.creer_facade 	bat1


select bat1


bat1.pos = [0,0,0]
bat1.sousTraces


try unregisterRedrawViewsCallback 		bat1.fn_VP_afficher_axePrincipal 	
catch ()








$.VP_toggle ()



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





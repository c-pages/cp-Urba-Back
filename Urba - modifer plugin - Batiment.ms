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




struct str_facade_modele (
		
		id			= "",
		nom 		=	"Modèle",
		
		verts 	=#(),
		edges	=#(),
		faces		=#(),		
		SMs		=#(),
		matIDs	=#(),
		
		longueur 	= 0.,
		hauteur		=	0.,
		
		on create do (
			local result ="FAC_MOD_"
			for i= 1 to 10 do (
				result += ( random 0 9 ) as string
			)
			id = result
		)

)
struct str_facade_composant (
		
		id							= "",
		nom 						=	"Composant de façade",
		longueur				=	0,
		longueur_max		=	0,
		longueur_maxEnable		=	false,
		modeles_ids			=	#(),
		modeles_probas		=	#(),
		etirable					=	false,
	
	
		on create do (
			local result ="FAC_CMP_"
			for i= 1 to 10 do (
				result += ( random 0 9 ) as string
			)
			id = result
		)
	
)

struct str_facade (
	
		nom 						=	"Facade",
		
		mode						=	1,			---- (repeter, etrier, centrer)
		murs						=	1,			---- (les deux ,gouttereaux, pignons )
		
		
		etages_use			=	false,
		etages_nbre_min	= 	0,
		etages_nbre_max	=	0,
		etages_use_max	=	false,
		
		longueur_use			=	false,
		longueur_min		=	0,
		longueur_max		=	0,
		longueur_use_max	=	false,
		
		probabilite 			= 100.,
		repeter					=	true,
		etirer					=	false,
		
		sequence				=	#()
		
		
		
)

---------------presse papier ---------
global urba_clipboard_batiment = ""



	
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
	
	--------------- PRé-DéCLARATIONS  ----------------------------------------------------------------------------------------------------------------------
	----  rollouts ------------------
	local roll_global, roll_niveaux,  roll_presets,   roll_toiture, roll_infos , roll_facades 
	
	----  structures ------------------
-- 	local geo,  trace,  construire
	
	--------------- MEMBRES  ----------------------------------------------------------------------------------------------------------------------
	---- le model dessiné d'un batiment vide ------------------
	local traceLogo = #([14.1994,37.717,0], [14.1994,-189.586,0], [287.927,-189.586,0], [287.927,139.601,0], [174.501,253.027,0], [174.501,479.879,0], [61.0754,479.879,0], [61.0754,366.453,0], [-52.3504,479.879,0], [-392.628,139.601,0], [-392.628,-189.586,0], [-118.9,-189.586,0], [-118.9,37.717,0])

	local params_aEnregistrer = 	#(		/*  ----	Global  	----  */		#niveaux_hauteur, #niveaux_nbre, 
													/*  ----	Toiture 	----  */		#toit_pente, #toit_type, #toit_hauteur ,
													/*  ----	Tracé  	----  */		#trace_optimiser, #trace_souder, #trace_ortho, #seuil_optimiser, #seuil_souder, #seuil_ortho ,
													/*  ----	 Facades  	----  */		#facades_composants , #facades_items, #facades_modeles
											)
	
	---- constantes------------------
	local ep_ssBassement 	= 	100
	local ep_dalle 				= 20
	local ep_mur	 			= 20
	local ep_couvertine	 	= 5
	
	
	local murs_types = #("Gouttereaux", "Pignons", "Gouttereaux + Pignons")
	
	--------------- import des STRUCTURES  ----------------------------------------------------------------------------------------------------------------------
	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures.ms"
	
	local geo 			= 	str_geo 			()
	local facades		=	str_facades		()
	local trace		=	str_trace 			geo_ptr:geo
	local construire	=	str_construire	geo_ptr:geo
	
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
		roll_global.actualiser 	()
		roll_facades.actualiser ()
		roll_toiture.actualiser	()
		roll_infos.actualiser 	()
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
	)
	on clone 	_original 	do (
		debug "clone du plugin" 
-- 		initialiser ()
	)
	on create do (
		debug "creation du plugin"		
		--- le dessin du logo --------
		trace_courant = traceLogo
		geo.creerFace trace_courant
	)
	
	on update do	(
		debug "update du plugin"	
-- 		if version == 0 then 		format "maj de le version 0->1\n"	
	)
	
) --- fin du plug ---

/* 


for obj in objects do if superclassof obj == GeometryClass and obj != $'triple002'  and obj != $'Porte002'  and obj != $'Porte003' do delete obj
bat1 = urba_batiment ()
clearlistener ()
bat1.assigner_trace 	$Shape009	bat1
bat1.facades.creer 	bat1
-- Sphere radius:143.349 smooth:on segs:32 chop:0 slice:off sliceFrom:0 sliceTo:0 mapcoords:on recenter:off pos:[11188.5,-13914.2,0] isSelected:on
select bat1






debug_mode = true







 */





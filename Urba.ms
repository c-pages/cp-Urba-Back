/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA
	Générateur de ville
	
##########################################################################################################################
	
	Fichier principale
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [27/07/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/


(
global urba
	
----- scripts globaux -------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"
include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"
include "$userScripts\cp - GLOBAL\Manager de presets.ms"
	
----- scripts externes -------------
include "$userScripts\cp-Urba\Urba - Structures.ms"
include "$userScripts\cp-Urba\Urba - Outils.ms"
	
include "$userScripts\cp-Urba\Urba - Villes.ms"
include "$userScripts\cp-Urba\Urba - Batiments.ms"
include "$userScripts\cp-Urba\Urba - Facades.ms"
include "$userScripts\cp-Urba\Urba - Toitures.ms"
	
-- include "$userScripts\cp-Urba\Urba - Construction.ms"
-- include "$userScripts\cp-Urba\Urba - Edit.ms"


------------------------------------------------------------------------------
----------	FENETRE								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba "urba " width:279 height:85
(
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba rollout"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	
	
	
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	local m_prefs			---- pointeur vers les preferences "Fenetre"de labib ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	
	fn shape_filt 		obj = superclassof obj == shape
	
	------------  UI	----------------------------------------------------------------------------------	
	ImgTag 'ui_titre' "" pos:[16,4] width:66 height:18 align:#left
	
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	dropdownList 'ddl_villes' "" pos:[16,26] width:159 height:21 align:#left
	
	checkbutton 'ckb_toiture' "T" pos:[234,26] width:21 height:21 align:#left
	checkbutton 'ckb_ville' "V" pos:[174,26] width:21 height:21 align:#left
	checkbutton 'ckb_batiment' "B" pos:[194,26] width:21 height:21 align:#left
	checkbutton 'ckb_facade' "F" pos:[214,26] width:21 height:21 align:#left
	
	pickButton 'btn_generer' "Générer" pos:[16,46] width:239 height:21 align:#left	filter:shape_filt	message:"Choisir le tracée"
	
	------------  Fonctions	----------------------------------------------------------------------------------
	fn actualiser =(
		
		local listTmp =#()
		local presets_villes = m_prt.villes.presets.get ()
		
		for preset in presets_villes do
			append listTmp 	preset.nom
		ddl_villes.items = listTmp
		
		local enable = false
		if presets_villes.count > 0 do
			enable = true		
		
		ckb_ville.checked = m_prt.villes.estOuvert () 
		ckb_batiment.checked = m_prt.batiments.estOuvert () 
		ckb_facade.checked = m_prt.facades.estOuvert () 
		ckb_toiture.checked = m_prt.toitures.estOuvert () 
		
		btn_generer.enabled = enable
		
	)
	
	
	
	fn reagencer taille: 	=(
		
		Local LargeurBtn = 20
		
		if taille == unsupplied do taille = [ roll_urba.width, roll_urba.height ]
		ui_btnFermer.pos.x		=	taille.x - ( LargeurBtn )
		
	)
	
	
	
	---- Gere l'état du bouton  fermer -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]
		)
	)
	
	
	
	
	---- Initialisation de la fenetre  -----
	fn initialiser  ptr_parent= (
		
		debug "initialiser"
		
		-- se raccrocher à labib --
		m_prt = ptr_parent
		
		-- le titre --
		m_titre 	= str_label 	m_ui:ui_titre			m_texte:m_prt.m_titre
		m_titre.setCouleur 			m_prt.col_fenetreTxt
		m_titre.setCouleurFond 	m_prt.col_fenetreFond
		
		-- le drag --
		m_drag 		= str_drag 	m_prt:roll_urba
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		b_initialisation = true
		
	)
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	

	on roll_urba resized _taille 	do
		reagencer ()
	on roll_urba moved _pos 	do
		m_prt.m_pos	= _pos
	on roll_urba lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba mouseMove _pos 	do
		m_drag.suivreSouris ()
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos
	on ui_btnFermer click do
		m_prt.fermer ()
	
	
	on ckb_ville changed state do
	(
		if m_prt.villes.estOuvert () then
			m_prt.villes.fermer()
		else (
			m_prt.villes.ouvrir pos:( GetDialogPos roll_urba + [ (GetDialogSize  roll_urba ).x ,0] )

			m_prt.villes.selectionner_id	 ddl_villes.selection
		)
	)
	on ckb_batiment changed state do
	(
			if m_prt.batiments.estOuvert () then
				m_prt.batiments.fermer()
			else
				m_prt.batiments.ouvrir()
		
		)
	on ckb_facade changed state do
	(
			if m_prt.facades.estOuvert () then
				m_prt.facades.fermer()
			else
				m_prt.facades.ouvrir()
		
		)
	on ckb_toiture changed state do
	(
		if m_prt.toitures.estOuvert () then
			m_prt.toitures.fermer()
		else (
			m_prt.toitures.ouvrir pos:( GetDialogPos roll_urba + [ (GetDialogSize  roll_urba ).x ,0] )

-- 			m_prt.toitures.selectionner_id	 ddl_villes.selection
		)
	)
	
	
	on btn_generer picked 	_shape do m_prt.generer	_shape	ddl_villes.selection
	
	
)
	
------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba (
	
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	----------------------------------------------------------------------------------------------------------
	------------  Membres	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	public
		
		---- pointeurs ----
		m_dialog				= roll_urba ,		---- le rollout ----
		
		---- props de la fenetre -----
		m_titre 				= "Urba ",
		m_pos 					= [100,100],
		m_taille 				= [300, 300],
		m_estOuvert 		= false,
		
		--	Couleurs ui claire -----
		col_fenetreFond			= color 68 68 68, 		---- MAX 	----
		col_fenetreTxt			= color 240  240 240, 	----  		----
		
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer= #( 	openbitmap ico_btnFermer_R, openbitmap ico_btnFermer_S, openbitmap ico_btnFermer_P ),
		
		fichier_presets		= "$userScripts\cp-Urba\urba_presets.ini",
		
		
		---- STRUCTURES ----	
	public
		
		villes 			= str_urba_villes 			m_urba:this,
		batiments 	= str_urba_batiments 	m_urba:this,
		facades 		= str_urba_facades 		m_urba:this,
		toitures 		= str_urba_toitures 		m_urba:this,
		
		outils = str_urba_outils		m_urba:this,
		
	private
		
		
		tracee_origine,	---- le tracee piqué par l'utilisateur
		tracee,				---- la copie du tracee que l'on va manipuler
		
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	public
		fn actualiser = m_dialog.actualiser (),
		
		fn estOuvert = m_estOuvert,
		fn ouvrir =(
			debug "ouvrir"
			m_estOuvert 		= true
			
			---- creation de la fenetre ----
			createDialog m_dialog 	fgcolor:				col_fenetreFond 	\
											style:				#(#style_resizing) \
											pos:					m_pos		\
											lockHeight:			true	 \	
											lockWidth:			true
			
			--- chargement des presets ------
			villes.presets.charger ()
			batiments.presets.charger ()
			facades.elementsDeFacade.charger ()			
			facades.presets.charger ()
			toitures.presets.charger ()
			facades.modeles.charger ()		
			
			---- fenetre ----
			m_dialog.initialiser 	this
			m_dialog.actualiser ()
			
		),
		
		fn fermer  silence:false =(		---- silence : fermer sans modifier l'état des preferences ---	
			debug "fermer"
			m_estOuvert 		= false
			---- maj des preferences ----	
			if not silence do (
			)
			
			villes.fermer ()
			batiments.fermer ()
			facades.fermer ()	
			toitures.fermer ()	
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		
		fn toggleOuverture =(
			
			if m_estOuvert
				then fermer ()
				else	ouvrir ()
			
		),
		
		
		
		------------------------------------------------------------------------------------------------------------
		fn generer 		_shape 	_idVille	= with redraw off (
			
			max create mode
			
			---- Status bar --------------------
			progressStart "Urba: Génération de la ville ..." 
			
			--- recup preset de la ville ---------
			local presetVille = ( villes.presets.get_preset	_idVille )			
			
			---- Gestion du tracee ------------
			tracee_origine	=	_shape
			tracee 			= copy	tracee_origine
			tracee.name 	= uniqueName	"Urba - Tracee "
			outils.preparerShape tracee
			
			---- import des models utilisés -----
			outils.collecter_modeles 	presetVille
			
			-- Création des batiments --
			for idSpline = 1 to (numSplines tracee) do	
				outils.creer_batiment	tracee	idSpline		presetVille
			
			---- suppression des imports--------
			outils.supprimer_modelesImportes ()
			
			-- status bar ---
			progressEnd() 
			
			select tracee
			
		),
		
		
		
		------------  Evenements	--------------------------------------------------------------------------------
		on create do (
			debug "Structure créée."
		)
	
	
) -- fin struct urba -----



---------------		DEBUG	-----------------------------------------
--- on vire les objets en trop
for obj in objects do
	if obj != $Line001 and obj != $Box001	do delete obj


try urba.fermer () catch ()
clearListener ()
global urba  	=	str_urba () --	m_labib:Labib
urba.ouvrir ()
urba

--- on vire les objets en trop
for obj in objects do
	if obj != $Line001 and obj != $Box001	do delete obj
---------------		DEBUG	-----------------------------------------


)


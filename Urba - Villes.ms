/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	FENETRE TYPE	( sert de model de base, n'est pas importé dans le script )	
	sans barre de titre, draggable et bouton fermer
	
	Remplacer (ctr + h): 'urba_villes' par:  'maFenetreAMoi'.
	il y a des parties a decommenter :"--- a décommenter ---"
	Noms des variables 
	-	roll_urba_villes :			le nom de la fenetre
	-	urba_villes_pos :			le parametre des prefs stockant la pos de la fenetre
	-	urba_villes_estOuvert :	le nom du parametre ouvert dans les preferences ( labib.prefs.fenetre. ' urba_villesOuvert )
	-	str_urba_villes:			le nom de la struicture de controle de la fenetre
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'été)
	- Une interface souple et simple
########################################################################################################################*/

-- (




------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"

-- include "$userScripts\cp-Urba\Urba - Structures - 2.ms"
include "$userScripts\cp-Urba\Urba - Ville - edition.ms"

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_villes "urba_villes" width:279 height:246
(
		

	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
-- 	local m_log
	
	local villeCourante
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[259,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
-- 	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left

	edittext 'edt_ville_nom' "" pos:[118,47] width:147 height:16 align:#left
	label 'lbl_ville_nom' "Nom:" pos:[11,47] width:66 height:15 align:#left
	
	
	listbox 'lbx_bats' "" pos:[10,81] width:253 height:10 align:#left
	
	
	
	button 'btn_supprimer_bat' "-" pos:[248,65] width:16 height:16 align:#left
	button 'btn_ajouter_bat' "+" pos:[233,65] width:16 height:16 align:#left

	label 'lbl_batiments' "Bâtiments:" pos:[11,66] width:105 height:14 align:#left
	spinner 'spn_proba' "" pos:[118,218] width:147 height:16 align:#left

	
	label 'lbl_proba' "Probabilité:" pos:[13,218] width:81 height:14 align:#left


	button 'btn_supprimer_ville' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_ville' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_villes' "" pos:[9,22] width:216 height:21 align:#left

-- 	button 'btn_annuler' "Annuler" pos:[12,222] width:90 height:16 align:#left
-- 	button 'btn_enregistrerSous' "sous" pos:[227,222] width:34 height:16 align:#left
-- 	button 'btn_enregistrer' "Enregistrer" pos:[147,222] width:81 height:16 align:#left
	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	
	fn actualiser = (
		local listTmp =#()
		for elem in m_prt.mgr.elements do
			append listTmp elem.nom
		ddl_villes.items = listTmp
		
		
		
		local enable = true
		if m_prt.m_id_villeCourante != 0 then (
			villeCourante  = m_prt.mgr.elements[ m_prt.m_id_villeCourante ]
			edt_ville_nom.text = villeCourante.nom
		) else (
			enable = false
		)	
		
		edt_ville_nom.enabled 			= enable
		lbl_ville_nom.enabled 			= enable
		lbl_proba.enabled 				= enable
		spn_proba.enabled 				= enable
		lbl_batiments.enabled 			= enable
		btn_supprimer_bat.enabled 	= enable
		btn_ajouter_bat.enabled 		= enable
		btn_supprimer_ville.enabled 	= enable
		lbx_bats.enabled 					= enable
		
		
		if 
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_villes		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Villes"
		m_titre.setCouleur (color 255	255	255)
		/* 
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		 */
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	
	
		---- Drag ----
	
	---- Fermer ----
	
	
	
	
	
	on roll_urba_villes lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_villes lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_villes mouseMove _pos 	do
		m_drag.suivreSouris ()
	
	
	
	on btn_ajouter_ville pressed  do m_prt.ajouter_ville ()
	
	
	on edt_ville_nom changed  txt do (
		villeCourante.nom = txt
		actualiser ()
		urba.m_dialog.actualiser ()
	)
	
	on ddl_villes selected  _val do (
		m_prt.m_id_villeCourante = _val
		actualiser ()
		)
	
	
	---- Fermer ----
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
	
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba_villes (
	private
		m_estOuvert 			= false,
		
		
		------------  Membres	----------------------------------------------------------------------------------
	public
		
		m_id_villeCourante 	= 0,
		
		mgr 			= 	str_urba_preset_ville_MGR (),
		edition 		= str_urba_ville_edition (),
		
		---- pointeurs ----
		m_dialog				= roll_urba_villes ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color 68  68 68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Pressé ----
									),
		
		------------  Fonctions	----------------------------------------------------------------------------------
		public
		
		fn estOuvert = m_estOuvert,
			
		---- fenetre -----
		fn ouvrir =(			
			m_estOuvert 		= true
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 		\
											fgcolor:				col_fenetreTxt 		\
											style:				#(#style_resizing) 	\
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		
		
		
		
		
		
		fn ajouter_ville =(
			mgr.ajouter ()
			if not m_estOuvert do ouvrir ()
			m_id_villeCourante = mgr.elements.count		
			m_dialog.actualiser ()	
			m_dialog.ddl_villes.selection = m_dialog.ddl_villes.items.count
			
		),
		fn afficher 	_id =(
			m_id_villeCourante = _id
			m_dialog.actualiser ()
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)

-- try 
-- 	destroydialog test.m_dialog 
-- catch ()

-- test = str_urba_villes ()
-- test.ouvrir ()



-- )







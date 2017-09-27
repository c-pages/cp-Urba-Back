/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	FENETRE TYPE	( sert de model de base, n'est pas importé dans le script )	
	sans barre de titre, draggable et bouton fermer
	
	Remplacer (ctr + h): 'urba_editeurFacades' par:  'maFenetreAMoi'.
	il y a des parties a decommenter :"--- a décommenter ---"
	Noms des variables 
	-	roll_urba_editeurFacades :			le nom de la fenetre
	-	urba_editeurFacades_pos :			le parametre des prefs stockant la pos de la fenetre
	-	urba_editeurFacades_estOuvert :	le nom du parametre ouvert dans les preferences ( labib.prefs.fenetre. ' urba_editeurFacadesOuvert )
	-	str_urba_editeurFacades:			le nom de la struicture de controle de la fenetre
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'été)
	- Une interface souple et simple
########################################################################################################################*/

(




------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_editeurFacades "urba_editeurFacades" width:200 height:200
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_editeurFacades.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
-- 	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left

	GroupBox 'grp_prop' "Propriétés" pos:[5,145] width:165 height:146 align:#left
	label 'lbl_repetable' "Répétable" pos:[26,233] width:55 height:15 align:#left
	checkbox 'chk_repetable' "" pos:[11,234] width:14 height:14 align:#left
	label 'lbl_etirable' "Etirable" pos:[103,233] width:42 height:15 align:#left
	checkbox 'chk_etirable' "" pos:[88,234] width:14 height:14 align:#left
	spinner 'spn_proba' "" pos:[87,218] width:80 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	label 'lbl_proba' "Probabilité:" pos:[11,218] width:67 height:15 align:#left
	
	label 'lbl_nbre' "Nbre.:" pos:[5,1] width:38 height:15 align:#left
	spinner 'spn_nbres' "" pos:[87,2] width:85 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	spinner 'spn_largeur' "" pos:[87,158] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_largeur' "Largeur (min):" pos:[11,158] width:73 height:15 align:#left
	spinner 'spn_largeurMax' "" pos:[87,173] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_etages' "" pos:[87,188] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_etages' "Etages (min):" pos:[11,188] width:71 height:15 align:#left
	spinner 'spn_etagesMax' "" pos:[87,203] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	
	
	dropdownList 'ddl_appliquerA' "" pos:[11,264] width:153 height:21 selection:3 align:#left  --	items:murs_types
		label 'lbl_appliquerA' "Appliquer à:" pos:[11,249] width:111 height:15 align:#left
	
	
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
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
		m_titre.setCouleur (color 0 0 0)
		m_titre.setCouleurFond ( color 200 200 200 )
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
	on roll_urba_editeurFacades lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_editeurFacades lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_editeurFacades mouseMove _pos 	do
		m_drag.suivreSouris ()
	
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
struct str_urba_editeurFacades (
	
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog				= roll_urba_editeurFacades ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
-- 		col_fenetreFond		= color 68  68 68, 	----  ----
		col_fenetreFond		= color 149 149 149, 	----  ----
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
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----
			createDialog m_dialog 	fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
-- 			bgcolor:				col_fenetreFond 	 \
											
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
						
		),
		
		fn fermer  =(	
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)

try 
	test.fermer ()
catch ()
global test
test = str_urba_editeurFacades ()
test.ouvrir ()



)






